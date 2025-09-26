import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MeetingService extends GetxService {
  static MeetingService get instance => Get.find<MeetingService>();

  // WebRTC Configuration
  static const Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
    'iceCandidatePoolSize': 10,
  };

  // Media Constraints
  static const Map<String, dynamic> _mediaConstraints = {
    'audio': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
      'googEchoCancellation': true,
      'googAutoGainControl': true,
      'googNoiseSuppression': true,
    },
    'video': {
      'facingMode': 'user',
      'width': {'min': 640, 'ideal': 1280, 'max': 1920},
      'height': {'min': 480, 'ideal': 720, 'max': 1080},
      'frameRate': {'min': 10, 'ideal': 30, 'max': 60},
    },
  };

  // Socket connection
  IO.Socket? _socket;
  String? _socketId;

  // Local media
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;

  // Peer connections
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};

  // Callbacks
  Function(String participantId, RTCVideoRenderer renderer)?
      onParticipantJoined;
  Function(String participantId)? onParticipantLeft;
  Function(bool connected)? onConnectionChanged;
  Function(String error)? onError;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLocalRenderer();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  Future<void> _initializeLocalRenderer() async {
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
  }

  Future<bool> initializeLocalMedia() async {
    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      _localRenderer?.srcObject = _localStream;
      return true;
    } catch (e) {
      onError?.call('Failed to access camera/microphone: $e');
      return false;
    }
  }

  Future<void> connectToMeeting(String serverUrl, String? meetingId) async {
    try {
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .build(),
      );

      _socket!.onConnect((_) {
        debugPrint('Socket connected');
        _socketId = _socket!.id;
        onConnectionChanged?.call(true);
        _setupSocketListeners();

        if (meetingId != null) {
          _socket!.emit('join-meeting', {'meetingId': meetingId});
        }
      });

      _socket!.onDisconnect((_) {
        debugPrint('Socket disconnected');
        onConnectionChanged?.call(false);
        _cleanup();
      });

      _socket!.onError((error) {
        debugPrint('Socket error: $error');
        onError?.call('Connection error: $error');
      });

      _socket!.connect();
    } catch (e) {
      onError?.call('Failed to connect to meeting: $e');
    }
  }

  void _setupSocketListeners() {
    _socket!.on('participant-joined', (data) => _handleParticipantJoined(data));
    _socket!.on('participant-left', (data) => _handleParticipantLeft(data));
    _socket!.on('offer', (data) => _handleOffer(data));
    _socket!.on('answer', (data) => _handleAnswer(data));
    _socket!.on('ice-candidate', (data) => _handleIceCandidate(data));
  }

  Future<void> _handleParticipantJoined(dynamic data) async {
    final String participantId = data['participantId'];
    debugPrint('Participant joined: $participantId');

    try {
      // Create peer connection for new participant
      final peerConnection = await _createPeerConnection(participantId);
      _peerConnections[participantId] = peerConnection;

      // Create renderer for remote stream
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      _remoteRenderers[participantId] = renderer;

      // Add local stream to peer connection
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          peerConnection.addTrack(track, _localStream!);
        });
      }

      // Create and send offer
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      _socket!.emit('offer', {
        'targetId': participantId,
        'offer': offer.toMap(),
      });

      onParticipantJoined?.call(participantId, renderer);
    } catch (e) {
      onError?.call('Failed to handle participant joined: $e');
    }
  }

  void _handleParticipantLeft(dynamic data) {
    final String participantId = data['participantId'];
    debugPrint('Participant left: $participantId');

    _peerConnections[participantId]?.close();
    _peerConnections.remove(participantId);

    _remoteRenderers[participantId]?.dispose();
    _remoteRenderers.remove(participantId);

    onParticipantLeft?.call(participantId);
  }

  Future<void> _handleOffer(dynamic data) async {
    final String senderId = data['senderId'];
    final Map<String, dynamic> offerData = data['offer'];

    try {
      final peerConnection = await _createPeerConnection(senderId);
      _peerConnections[senderId] = peerConnection;

      // Create renderer for remote stream
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      _remoteRenderers[senderId] = renderer;

      // Set remote description
      final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
      await peerConnection.setRemoteDescription(offer);

      // Add local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          peerConnection.addTrack(track, _localStream!);
        });
      }

      // Create and send answer
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      _socket!.emit('answer', {
        'targetId': senderId,
        'answer': answer.toMap(),
      });

      onParticipantJoined?.call(senderId, renderer);
    } catch (e) {
      onError?.call('Failed to handle offer: $e');
    }
  }

  Future<void> _handleAnswer(dynamic data) async {
    final String senderId = data['senderId'];
    final Map<String, dynamic> answerData = data['answer'];

    try {
      final peerConnection = _peerConnections[senderId];
      if (peerConnection != null) {
        final answer =
            RTCSessionDescription(answerData['sdp'], answerData['type']);
        await peerConnection.setRemoteDescription(answer);
      }
    } catch (e) {
      onError?.call('Failed to handle answer: $e');
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    final String senderId = data['senderId'];
    final Map<String, dynamic> candidateData = data['candidate'];

    try {
      final peerConnection = _peerConnections[senderId];
      if (peerConnection != null) {
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        await peerConnection.addCandidate(candidate);
      }
    } catch (e) {
      onError?.call('Failed to handle ICE candidate: $e');
    }
  }

  Future<RTCPeerConnection> _createPeerConnection(String participantId) async {
    final peerConnection = await createPeerConnection(_rtcConfiguration);

    peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        final renderer = _remoteRenderers[participantId];
        if (renderer != null) {
          renderer.srcObject = event.streams[0];
        }
      }
    };

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      _socket!.emit('ice-candidate', {
        'targetId': participantId,
        'candidate': candidate.toMap(),
      });
    };

    peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Peer connection state for $participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        // Handle connection failure
        _handleConnectionFailure(participantId);
      }
    };

    return peerConnection;
  }

  void _handleConnectionFailure(String participantId) {
    debugPrint('Connection failed for participant: $participantId');
    _peerConnections[participantId]?.close();
    _peerConnections.remove(participantId);
    _remoteRenderers[participantId]?.dispose();
    _remoteRenderers.remove(participantId);
    onParticipantLeft?.call(participantId);
  }

  // Media controls
  void toggleAudio() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        audioTracks[0].enabled = !audioTracks[0].enabled;
      }
    }
  }

  void toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        videoTracks[0].enabled = !videoTracks[0].enabled;
      }
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks[0]);
      }
    }
  }

  void leaveMeeting() {
    _socket?.emit('leave-meeting');
    _cleanup();
  }

  void _cleanup() {
    // Close all peer connections
    _peerConnections.forEach((key, connection) {
      connection.close();
    });
    _peerConnections.clear();

    // Dispose all renderers
    _remoteRenderers.forEach((key, renderer) {
      renderer.dispose();
    });
    _remoteRenderers.clear();

    // Dispose local stream and renderer
    _localStream?.dispose();
    _localRenderer?.dispose();

    // Disconnect socket
    _socket?.disconnect();
    _socket?.dispose();
  }

  // Getters
  RTCVideoRenderer? get localRenderer => _localRenderer;
  Map<String, RTCVideoRenderer> get remoteRenderers => _remoteRenderers;
  bool get isConnected => _socket?.connected ?? false;
  String? get socketId => _socketId;

  // Audio/Video state getters
  bool get isAudioEnabled {
    if (_localStream == null) return false;
    final audioTracks = _localStream!.getAudioTracks();
    return audioTracks.isNotEmpty && audioTracks[0].enabled;
  }

  bool get isVideoEnabled {
    if (_localStream == null) return false;
    final videoTracks = _localStream!.getVideoTracks();
    return videoTracks.isNotEmpty && videoTracks[0].enabled;
  }
}
