// lib/src/models/meeting_model.dart
class Meeting {
  final String id;
  final String title;
  final String description;
  final String hostId;
  final String hostName;
  final String passcode;
  final DateTime scheduledTime;
  final int durationMinutes;
  final bool isRecurring;
  final MeetingStatus status;
  final List<String> participants;
  final MeetingSettings settings;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.passcode,
    required this.scheduledTime,
    required this.durationMinutes,
    this.isRecurring = false,
    this.status = MeetingStatus.scheduled,
    this.participants = const [],
    this.settings = const MeetingSettings(),
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      passcode: json['passcode'] ?? '',
      scheduledTime: DateTime.parse(
          json['scheduledTime'] ?? DateTime.now().toIso8601String()),
      durationMinutes: json['durationMinutes'] ?? 60,
      isRecurring: json['isRecurring'] ?? false,
      status: MeetingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      participants: List<String>.from(json['participants'] ?? []),
      settings: MeetingSettings.fromJson(json['settings'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'passcode': passcode,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isRecurring': isRecurring,
      'status': status.name,
      'participants': participants,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  String get meetingUrl => 'https://yourapp.com/join/$id';

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  bool get isLive => status == MeetingStatus.inProgress;
  bool get canJoin =>
      status == MeetingStatus.scheduled || status == MeetingStatus.inProgress;
}

enum MeetingStatus {
  scheduled,
  inProgress,
  ended,
  cancelled,
}

class MeetingSettings {
  final bool allowParticipantsToUnmute;
  final bool allowParticipantsToTurnOnVideo;
  final bool allowScreenSharing;
  final bool enableWaitingRoom;
  final bool enableRecording;
  final bool muteParticipantsOnJoin;
  final bool disableVideoOnJoin;

  const MeetingSettings({
    this.allowParticipantsToUnmute = true,
    this.allowParticipantsToTurnOnVideo = true,
    this.allowScreenSharing = true,
    this.enableWaitingRoom = false,
    this.enableRecording = false,
    this.muteParticipantsOnJoin = false,
    this.disableVideoOnJoin = false,
  });

  factory MeetingSettings.fromJson(Map<String, dynamic> json) {
    return MeetingSettings(
      allowParticipantsToUnmute: json['allowParticipantsToUnmute'] ?? true,
      allowParticipantsToTurnOnVideo:
          json['allowParticipantsToTurnOnVideo'] ?? true,
      allowScreenSharing: json['allowScreenSharing'] ?? true,
      enableWaitingRoom: json['enableWaitingRoom'] ?? false,
      enableRecording: json['enableRecording'] ?? false,
      muteParticipantsOnJoin: json['muteParticipantsOnJoin'] ?? false,
      disableVideoOnJoin: json['disableVideoOnJoin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowParticipantsToUnmute': allowParticipantsToUnmute,
      'allowParticipantsToTurnOnVideo': allowParticipantsToTurnOnVideo,
      'allowScreenSharing': allowScreenSharing,
      'enableWaitingRoom': enableWaitingRoom,
      'enableRecording': enableRecording,
      'muteParticipantsOnJoin': muteParticipantsOnJoin,
      'disableVideoOnJoin': disableVideoOnJoin,
    };
  }
}
