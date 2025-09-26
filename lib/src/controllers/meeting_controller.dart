import 'dart:async';
import 'package:get/get.dart';

enum ConnectionStatus { disconnected, connecting, connected, failed }

class MeetingController extends GetxController {
  // Observable states
  final RxBool isAudioMuted = false.obs;
  final RxBool isVideoMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxInt participantCount = 1.obs;
  final Rx<ConnectionStatus> connectionStatus =
      ConnectionStatus.disconnected.obs;
  final RxString meetingId = ''.obs;
  final RxString meetingDuration = '00:00'.obs;

  // Meeting participants
  final RxList<Participant> participants = <Participant>[].obs;

  // Meeting state
  final RxBool isMeetingStarted = false.obs;
  final RxBool isScreenSharing = false.obs;
  final RxBool isRecording = false.obs;

  // Timer for meeting duration
  Timer? _meetingTimer;
  int _secondsElapsed = 0;

  @override
  void onInit() {
    super.onInit();
    _startMeetingTimer();
  }

  void _startMeetingTimer() {
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      final hours = (_secondsElapsed ~/ 3600).toString().padLeft(2, '0');
      final minutes =
          ((_secondsElapsed % 3600) ~/ 60).toString().padLeft(2, '0');
      final secs = (_secondsElapsed % 60).toString().padLeft(2, '0');
      meetingDuration.value =
          hours == '00' ? '$minutes:$secs' : '$hours:$minutes:$secs';
    });
  }

  void _stopMeetingTimer() {
    _meetingTimer?.cancel();
    _meetingTimer = null;
    _secondsElapsed = 0;
    meetingDuration.value = '00:00';
  }

  // Audio controls
  void setAudioMuted(bool muted) {
    isAudioMuted.value = muted;
  }

  void toggleAudio() {
    isAudioMuted.value = !isAudioMuted.value;
  }

  // Video controls
  void setVideoMuted(bool muted) {
    isVideoMuted.value = muted;
  }

  void toggleVideo() {
    isVideoMuted.value = !isVideoMuted.value;
  }

  // Speaker controls
  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
  }

  void setSpeaker(bool enabled) {
    isSpeakerOn.value = enabled;
  }

  // Connection management
  void setConnectionStatus(ConnectionStatus status) {
    connectionStatus.value = status;
  }

  // Participant management
  void addParticipant(Participant participant) {
    if (!participants.any((p) => p.id == participant.id)) {
      participants.add(participant);
      participantCount.value = participants.length + 1; // +1 for self
    }
  }

  void removeParticipant(String participantId) {
    participants.removeWhere((p) => p.id == participantId);
    participantCount.value = participants.length + 1; // +1 for self
  }

  void updateParticipant(
    String participantId, {
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isScreenSharing,
    String? connectionQuality,
  }) {
    final index = participants.indexWhere((p) => p.id == participantId);
    if (index != -1) {
      final participant = participants[index];
      participants[index] = participant.copyWith(
        isAudioMuted: isAudioMuted ?? participant.isAudioMuted,
        isVideoMuted: isVideoMuted ?? participant.isVideoMuted,
        isScreenSharing: isScreenSharing ?? participant.isScreenSharing,
        connectionQuality: connectionQuality ?? participant.connectionQuality,
      );
    }
  }

  Participant? getParticipant(String participantId) {
    try {
      return participants.firstWhere((p) => p.id == participantId);
    } catch (e) {
      return null;
    }
  }

  // Meeting controls
  void startMeeting(String meetingId) {
    this.meetingId.value = meetingId;
    isMeetingStarted.value = true;
    _startMeetingTimer();
  }

  void endMeeting() {
    isMeetingStarted.value = false;
    participants.clear();
    participantCount.value = 1;
    connectionStatus.value = ConnectionStatus.disconnected;
    _stopMeetingTimer();

    // Reset all states
    isAudioMuted.value = false;
    isVideoMuted.value = false;
    isScreenSharing.value = false;
    isRecording.value = false;
    meetingId.value = '';
  }

  // Screen sharing
  void toggleScreenShare() {
    isScreenSharing.value = !isScreenSharing.value;
  }

  void setScreenSharing(bool sharing) {
    isScreenSharing.value = sharing;
  }

  // Recording
  void toggleRecording() {
    isRecording.value = !isRecording.value;
  }

  void setRecording(bool recording) {
    isRecording.value = recording;
  }

  // Network quality management
  final RxString networkQuality = 'Good'.obs;

  void updateNetworkQuality(String quality) {
    networkQuality.value = quality;
  }

  // Chat functionality (for future implementation)
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final RxInt unreadMessageCount = 0.obs;

  void addChatMessage(ChatMessage message) {
    chatMessages.add(message);
    if (message.senderId != 'self') {
      unreadMessageCount.value++;
    }
  }

  void markMessagesAsRead() {
    unreadMessageCount.value = 0;
  }

  // Meeting statistics
  Duration get meetingDurationAsDuration {
    return Duration(seconds: _secondsElapsed);
  }

  String get formattedMeetingDuration => meetingDuration.value;

  // Helper methods
  bool get hasParticipants => participants.isNotEmpty;

  bool get isConnected => connectionStatus.value == ConnectionStatus.connected;

  bool get isHost {
    // This would be determined by your backend logic
    // For now, assume first person to join is host
    return participants.isEmpty;
  }

  List<Participant> get audioMutedParticipants {
    return participants.where((p) => p.isAudioMuted).toList();
  }

  List<Participant> get videoMutedParticipants {
    return participants.where((p) => p.isVideoMuted).toList();
  }

  @override
  void onClose() {
    _stopMeetingTimer();
    endMeeting();
    super.onClose();
  }
}

class Participant {
  final String id;
  final String name;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final bool isScreenSharing;
  final String connectionQuality;
  final DateTime joinedAt;

  Participant({
    required this.id,
    required this.name,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.isScreenSharing = false,
    this.connectionQuality = 'Good',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Participant copyWith({
    String? id,
    String? name,
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isScreenSharing,
    String? connectionQuality,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      connectionQuality: connectionQuality ?? this.connectionQuality,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Participant{id: $id, name: $name, isAudioMuted: $isAudioMuted, isVideoMuted: $isVideoMuted}';
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final ChatMessageType type;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.type = ChatMessageType.text,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    ChatMessageType? type,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum ChatMessageType { text, system, file, emoji }
