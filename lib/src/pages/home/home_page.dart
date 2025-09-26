import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as RTC;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_boilerplate/src/pages/home/widgets/remote_view_card.dart';
import 'package:get_boilerplate/src/services/socket_emit.dart';
import 'package:get_boilerplate/src/controllers/meeting_controller.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart' hide navigator;

Map<String, dynamic> configuration = {
  'iceServers': [
    {"urls": "stun:stun.l.google.com:19302"},
    {"urls": "stun:stun1.l.google.com:19302"},
    {"urls": "stun:stun.jacknathan.tk:3478"},
    {
      "urls": "turn:turn.jacknathan.tk:3478",
      "username": "ducanhzed",
      "credential": "1507200a",
    },
  ],
  'sdpSemantics': "unified-plan",
  'iceCandidatePoolSize': 10,
};

Socket? socket;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final MeetingController _meetingController = Get.put(MeetingController());

  List<Map<String, dynamic>> socketIdRemotes = [];
  late RTC.RTCPeerConnection _peerConnection;
  late RTC.MediaStream _localStream;
  final RTC.RTCVideoRenderer _localRenderer = RTC.RTCVideoRenderer();
  bool _isSend = false;
  bool _isFrontCamera = true;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeRenderers();
    _createPeerConnection().then((pc) async {
      _peerConnection = pc;
      await _getUserMedia();
      if (_localStream.getTracks().isNotEmpty) {
        for (var track in _localStream.getTracks()) {
          await _peerConnection.addTrack(track, _localStream);
        }
      }
    }).catchError((error) {
      debugPrint('Error initializing peer connection: $error');
    });
    _connectAndListen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    try {
      _peerConnection.close();
      _localStream.dispose();
      _localRenderer.dispose();
      socket?.disconnect();
      socket?.dispose();

      for (var remote in socketIdRemotes) {
        remote['stream']?.dispose();
        remote['pc']?.close();
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _cleanupResources();
        break;
      default:
        break;
    }
  }

  void _handleAppPaused() {
    // Mute audio/video when app goes to background
    _toggleAudio(mute: true);
  }

  void _handleAppResumed() {
    // Optionally unmute when app comes back
    if (_isAudioMuted) {
      _toggleAudio(mute: false);
    }
  }

  Future<void> _switchCamera() async {
    if (_localStream.getVideoTracks().isEmpty) return;

    try {
      final videoTrack = _localStream.getVideoTracks()[0];
      await videoTrack.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  void _toggleAudio({bool? mute}) {
    if (_localStream.getAudioTracks().isEmpty) return;

    final shouldMute = mute ?? !_isAudioMuted;
    final audioTrack = _localStream.getAudioTracks()[0];
    audioTrack.enabled = !shouldMute;

    setState(() {
      _isAudioMuted = shouldMute;
    });

    _meetingController.setAudioMuted(shouldMute);
  }

  void _toggleVideo() {
    if (_localStream.getVideoTracks().isEmpty) return;

    final videoTrack = _localStream.getVideoTracks()[0];
    videoTrack.enabled = !_isVideoMuted;

    setState(() {
      _isVideoMuted = !_isVideoMuted;
    });

    _meetingController.setVideoMuted(_isVideoMuted);
  }

  Future<RTC.RTCPeerConnection> _createPeerConnectionAnswer(
      String socketId) async {
    try {
      RTC.RTCPeerConnection pc = await RTC.createPeerConnection(configuration);

      pc.onTrack = (RTC.RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          int index = socketIdRemotes
              .indexWhere((item) => item['socketId'] == socketId);
          if (index != -1) {
            socketIdRemotes[index]['stream'].srcObject = event.streams[0];
          }
        }
      };

      pc.onConnectionState = (RTC.RTCPeerConnectionState state) {
        debugPrint('Peer connection state for $socketId: $state');
        if (state == RTC.RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          // Handle connection failure
          _handleConnectionFailure(socketId);
        }
      };

      pc.onIceConnectionState = (RTC.RTCIceConnectionState state) {
        debugPrint('ICE connection state for $socketId: $state');
      };

      pc.onRenegotiationNeeded = () {
        _createOfferForReceive(socketId);
      };

      return pc;
    } catch (e) {
      debugPrint('Error creating peer connection: $e');
      rethrow;
    }
  }

  void _handleConnectionFailure(String socketId) {
    // Remove failed connection
    setState(() {
      socketIdRemotes.removeWhere((item) => item['socketId'] == socketId);
    });

    // Optionally attempt reconnection
    _attemptReconnection(socketId);
  }

  void _attemptReconnection(String socketId) {
    // Implement reconnection logic if needed
    debugPrint('Attempting to reconnect to $socketId');
  }

  void _connectAndListen() async {
    try {
      setState(() {
        _isConnecting = true;
      });

      const urlConnectSocket = 'https://tugomu.tk';
      socket = io(
        urlConnectSocket,
        OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .build(),
      );

      socket?.onConnect((_) {
        debugPrint('Socket connected');
        setState(() {
          _isConnecting = false;
        });
        _meetingController.setConnectionStatus(ConnectionStatus.connected);

        socket?.on('NEW-PEER-SSC', (data) async {
          await _handleNewPeer(data);
        });

        socket?.on('SEND-SSC', (data) async {
          await _handleSendSSC(data);
        });

        socket?.on('RECEIVE-SSC', (data) async {
          await _handleReceiveSSC(data);
        });
      });

      socket?.onDisconnect((_) {
        debugPrint('Socket disconnected');
        setState(() {
          _isConnecting = false;
        });
        _meetingController.setConnectionStatus(ConnectionStatus.disconnected);
      });

      socket?.onError((error) {
        debugPrint('Socket error: $error');
        setState(() {
          _isConnecting = false;
        });
        _meetingController.setConnectionStatus(ConnectionStatus.failed);
      });

      socket?.connect();
    } catch (e) {
      debugPrint('Error connecting to socket: $e');
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _handleNewPeer(dynamic data) async {
    try {
      String newUser = data['socketId'];
      RTC.RTCVideoRenderer stream = RTC.RTCVideoRenderer();
      await stream.initialize();

      setState(() {
        socketIdRemotes.add({
          'socketId': newUser,
          'pc': null,
          'stream': stream,
        });
      });

      final pcRemote = await _createPeerConnectionAnswer(newUser);
      final index =
          socketIdRemotes.indexWhere((item) => item['socketId'] == newUser);
      if (index != -1) {
        socketIdRemotes[index]['pc'] = pcRemote;
        await pcRemote.addTransceiver(
          kind: RTC.RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTC.RTCRtpTransceiverInit(
            direction: RTC.TransceiverDirection.RecvOnly,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling new peer: $e');
    }
  }

  Future<void> _handleSendSSC(dynamic data) async {
    try {
      List<String> listSocketId =
          (data['sockets'] as List<dynamic>).map((e) => e.toString()).toList();

      for (int index = 0; index < listSocketId.length; index++) {
        String user = listSocketId[index];
        RTC.RTCVideoRenderer stream = RTC.RTCVideoRenderer();
        await stream.initialize();

        setState(() {
          socketIdRemotes.add({
            'socketId': user,
            'pc': null,
            'stream': stream,
          });
        });

        final pcRemote = await _createPeerConnectionAnswer(user);
        final socketIndex =
            socketIdRemotes.indexWhere((item) => item['socketId'] == user);
        if (socketIndex != -1) {
          socketIdRemotes[socketIndex]['pc'] = pcRemote;
          await pcRemote.addTransceiver(
            kind: RTC.RTCRtpMediaType.RTCRtpMediaTypeVideo,
            init: RTC.RTCRtpTransceiverInit(
              direction: RTC.TransceiverDirection.RecvOnly,
            ),
          );
        }
      }

      await _setRemoteDescription(data['sdp']);
    } catch (e) {
      debugPrint('Error handling SEND-SSC: $e');
    }
  }

  Future<void> _handleReceiveSSC(dynamic data) async {
    try {
      int index = socketIdRemotes.indexWhere(
        (element) => element['socketId'] == data['socketId'],
      );
      if (index != -1) {
        await _setRemoteDescriptionForReceive(index, data['sdp']);
      }
    } catch (e) {
      debugPrint('Error handling RECEIVE-SSC: $e');
    }
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _setRemoteDescription(String sdp) async {
    try {
      RTC.RTCSessionDescription description =
          RTC.RTCSessionDescription(sdp, 'answer');
      await _peerConnection.setRemoteDescription(description);
    } catch (e) {
      debugPrint('Error setting remote description: $e');
    }
  }

  Future<void> _setRemoteDescriptionForReceive(
      int indexSocket, String sdp) async {
    try {
      RTC.RTCSessionDescription description =
          RTC.RTCSessionDescription(sdp, 'answer');
      await socketIdRemotes[indexSocket]['pc']
          .setRemoteDescription(description);
    } catch (e) {
      debugPrint('Error setting remote description for receive: $e');
    }
  }

  Future<void> _createOffer() async {
    try {
      RTC.RTCSessionDescription description =
          await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(description);

      var session = parse(description.sdp!);
      String sdp = write(session, null);
      await _sendSdpForBroadcast(sdp);
    } catch (e) {
      debugPrint('Error creating offer: $e');
    }
  }

  Future<void> _createOfferForReceive(String socketId) async {
    try {
      int index =
          socketIdRemotes.indexWhere((item) => item['socketId'] == socketId);
      if (index != -1 && socketIdRemotes[index]['pc'] != null) {
        RTC.RTCSessionDescription description =
            await socketIdRemotes[index]['pc'].createOffer();
        await socketIdRemotes[index]['pc'].setLocalDescription(description);

        var session = parse(description.sdp!);
        String sdp = write(session, null);
        await _sendSdpOnlyReceive(sdp, socketId);
      }
    } catch (e) {
      debugPrint('Error creating offer for receive: $e');
    }
  }

  Future<RTC.RTCPeerConnection> _createPeerConnection() async {
    try {
      RTC.RTCPeerConnection pc = await RTC.createPeerConnection(configuration);

      pc.onRenegotiationNeeded = () {
        if (!_isSend) {
          _isSend = true;
          _createOffer();
        }
      };

      pc.onConnectionState = (RTC.RTCPeerConnectionState state) {
        debugPrint('Main peer connection state: $state');
      };

      pc.onIceConnectionState = (RTC.RTCIceConnectionState state) {
        debugPrint('Main ICE connection state: $state');
      };

      return pc;
    } catch (e) {
      debugPrint('Error creating main peer connection: $e');
      rethrow;
    }
  }

  Future<void> _sendSdpForBroadcast(String sdp) async {
    SocketEmit().sendSdpForBroadcase(sdp);
  }

  Future<void> _sendSdpOnlyReceive(String sdp, String socketId) async {
    SocketEmit().sendSdpForReceive(sdp, socketId);
  }

  Future<void> _getUserMedia() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': {
          'facingMode': 'user',
          'width': {'min': 640, 'ideal': 1280, 'max': 1920},
          'height': {'min': 480, 'ideal': 720, 'max': 1080},
          'frameRate': {'min': 10, 'ideal': 30, 'max': 60},
        },
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error getting user media: $e');
      // Handle permission denied or other errors
      _showErrorDialog(
          'Camera/Microphone access denied. Please grant permissions to join the meeting.');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _endCall() {
    _cleanupResources();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video area
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black,
              child: socketIdRemotes.isEmpty
                  ? _buildWaitingView()
                  : RemoteViewCard(
                      remoteRenderer: socketIdRemotes[0]['stream'],
                    ),
            ),

            // Remote participants thumbnails
            if (socketIdRemotes.length > 1)
              Positioned(
                bottom: isLandscape ? 80 : 120,
                left: 12,
                right: 12,
                child: SizedBox(
                  height: isLandscape ? size.height * 0.2 : size.width * 0.25,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: socketIdRemotes.length - 1,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: RemoteViewCard(
                            remoteRenderer: socketIdRemotes[index + 1]
                                ['stream'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Local video preview
            Positioned(
              top: 16,
              right: 16,
              child: _buildLocalVideoPreview(size, isLandscape),
            ),

            // Connection status
            if (_isConnecting)
              Positioned(
                top: 16,
                left: 16,
                child: _buildConnectionStatus(),
              ),

            // Control buttons
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildControlButtons(size),
            ),

            // Participant count
            Positioned(
              top: 16,
              left: 16,
              child: _buildParticipantCount(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Waiting for other participants...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalVideoPreview(Size size, bool isLandscape) {
    final previewSize = isLandscape ? size.height * 0.3 : size.width * 0.3;

    return GestureDetector(
      onTap: _switchCamera,
      child: Container(
        width: previewSize,
        height: previewSize * 1.33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
          color: Colors.grey[900],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _localRenderer.textureId == null
              ? const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white54,
                    size: 32,
                  ),
                )
              : RTCVideoView(
                  _localRenderer,
                  mirror: _isFrontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Connecting...',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '${socketIdRemotes.length + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isAudioMuted ? Icons.mic_off : Icons.mic,
            isActive: !_isAudioMuted,
            onPressed: () => _toggleAudio(),
            backgroundColor: _isAudioMuted ? Colors.red : Colors.grey[800]!,
          ),
          _buildControlButton(
            icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
            isActive: !_isVideoMuted,
            onPressed: _toggleVideo,
            backgroundColor: _isVideoMuted ? Colors.red : Colors.grey[800]!,
          ),
          _buildControlButton(
            icon: Icons.switch_camera,
            isActive: true,
            onPressed: _switchCamera,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            isActive: true,
            onPressed: _endCall,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.blue : Colors.grey[800]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
