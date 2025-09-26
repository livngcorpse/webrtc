import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketEmit {
  static SocketEmit? _instance;
  IO.Socket? _socket;

  SocketEmit._internal();

  factory SocketEmit() {
    _instance ??= SocketEmit._internal();
    return _instance!;
  }

  void setSocket(IO.Socket socket) {
    _socket = socket;
  }

  // Legacy methods for backward compatibility
  void sendSdpForBroadcase(String sdp) {
    if (_socket?.connected ?? false) {
      _socket!.emit('SEND-CSS', {'sdp': sdp});
      debugPrint('Sent SDP for broadcast');
    } else {
      debugPrint('Socket not connected - cannot send SDP for broadcast');
    }
  }

  void sendSdpForReceive(String sdp, String socketId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('RECEIVE-CSS', {
        'sdp': sdp,
        'socketId': socketId,
      });
      debugPrint('Sent SDP for receive to $socketId');
    } else {
      debugPrint('Socket not connected - cannot send SDP for receive');
    }
  }

  // Modern meeting methods
  void joinMeeting(String meetingId, {String? userName}) {
    if (_socket?.connected ?? false) {
      _socket!.emit('join-meeting', {
        'meetingId': meetingId,
        'userName': userName ?? 'Anonymous',
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Joined meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot join meeting');
    }
  }

  void leaveMeeting(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('leave-meeting', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Left meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot leave meeting');
    }
  }

  void sendOffer(String targetId, Map<String, dynamic> offer) {
    if (_socket?.connected ?? false) {
      _socket!.emit('offer', {
        'targetId': targetId,
        'offer': offer,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Sent offer to $targetId');
    } else {
      debugPrint('Socket not connected - cannot send offer');
    }
  }

  void sendAnswer(String targetId, Map<String, dynamic> answer) {
    if (_socket?.connected ?? false) {
      _socket!.emit('answer', {
        'targetId': targetId,
        'answer': answer,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Sent answer to $targetId');
    } else {
      debugPrint('Socket not connected - cannot send answer');
    }
  }

  void sendIceCandidate(String targetId, Map<String, dynamic> candidate) {
    if (_socket?.connected ?? false) {
      _socket!.emit('ice-candidate', {
        'targetId': targetId,
        'candidate': candidate,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Sent ICE candidate to $targetId');
    } else {
      debugPrint('Socket not connected - cannot send ICE candidate');
    }
  }

  // Chat functionality
  void sendChatMessage(String meetingId, String message) {
    if (_socket?.connected ?? false) {
      _socket!.emit('chat-message', {
        'meetingId': meetingId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Sent chat message to meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot send chat message');
    }
  }

  // Participant status updates
  void updateParticipantStatus({
    required String meetingId,
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isScreenSharing,
  }) {
    if (_socket?.connected ?? false) {
      final statusUpdate = <String, dynamic>{
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (isAudioMuted != null) statusUpdate['isAudioMuted'] = isAudioMuted;
      if (isVideoMuted != null) statusUpdate['isVideoMuted'] = isVideoMuted;
      if (isScreenSharing != null)
        statusUpdate['isScreenSharing'] = isScreenSharing;

      _socket!.emit('participant-status-update', statusUpdate);
      debugPrint('Updated participant status for meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot update participant status');
    }
  }

  // Screen sharing
  void startScreenShare(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('start-screen-share', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Started screen share for meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot start screen share');
    }
  }

  void stopScreenShare(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('stop-screen-share', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Stopped screen share for meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot stop screen share');
    }
  }

  // Recording functionality
  void startRecording(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('start-recording', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Started recording for meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot start recording');
    }
  }

  void stopRecording(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('stop-recording', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Stopped recording for meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot stop recording');
    }
  }

  // Meeting management (host functions)
  void muteAllParticipants(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('mute-all-participants', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Muted all participants in meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot mute all participants');
    }
  }

  void kickParticipant(String meetingId, String participantId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('kick-participant', {
        'meetingId': meetingId,
        'participantId': participantId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Kicked participant $participantId from meeting: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot kick participant');
    }
  }

  void endMeetingForAll(String meetingId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('end-meeting-for-all', {
        'meetingId': meetingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Ended meeting for all participants: $meetingId');
    } else {
      debugPrint('Socket not connected - cannot end meeting for all');
    }
  }

  // Utility methods
  bool get isConnected => _socket?.connected ?? false;

  String? get socketId => _socket?.id;

  void disconnect() {
    _socket?.disconnect();
    debugPrint('Socket disconnected');
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    debugPrint('Socket disposed');
  }
}
