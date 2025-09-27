// lib/src/controllers/meeting_list_controller.dart
import 'package:get/get.dart';
import 'package:get_boilerplate/src/models/meeting_model.dart';
import 'package:get_boilerplate/src/controllers/auth_controller.dart';

class MeetingListController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Meeting> allMeetings = <Meeting>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  List<Meeting> get upcomingMeetings {
    final now = DateTime.now();
    return allMeetings
        .where((meeting) =>
            meeting.scheduledTime.isAfter(now) &&
            (meeting.status == MeetingStatus.scheduled ||
                meeting.status == MeetingStatus.inProgress))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<Meeting> get recentMeetings {
    final now = DateTime.now();
    return allMeetings
        .where((meeting) =>
            meeting.scheduledTime.isBefore(now) &&
            meeting.status == MeetingStatus.ended)
        .toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }

  List<Meeting> get myMeetings {
    if (_authController.isTeacher) {
      return allMeetings
          .where((meeting) =>
              meeting.hostId == _authController.currentUser.value?.id)
          .toList();
    } else {
      return allMeetings
          .where((meeting) => meeting.participants
              .contains(_authController.currentUser.value?.id))
          .toList();
    }
  }

  List<Meeting> get filteredMeetings {
    if (searchQuery.value.isEmpty) {
      return allMeetings;
    }

    return allMeetings
        .where((meeting) =>
            meeting.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            meeting.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            meeting.hostName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  Future<void> loadMeetings() async {
    try {
      isLoading.value = true;

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      allMeetings.value = _generateMockMeetings();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load meetings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Meeting?> createMeeting({
    required String title,
    required String description,
    required DateTime scheduledTime,
    required int durationMinutes,
    MeetingSettings? settings,
  }) async {
    try {
      isLoading.value = true;

      final meeting = Meeting(
        id: _generateMeetingId(),
        title: title,
        description: description,
        hostId: _authController.currentUser.value!.id,
        hostName: _authController.currentUser.value!.name,
        passcode: _generatePasscode(),
        scheduledTime: scheduledTime,
        durationMinutes: durationMinutes,
        settings: settings ?? const MeetingSettings(),
        createdAt: DateTime.now(),
      );

      // TODO: Call API to create meeting
      await Future.delayed(const Duration(seconds: 1));

      allMeetings.add(meeting);

      Get.snackbar('Success', 'Meeting created successfully');
      return meeting;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create meeting: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeeting(Meeting meeting) async {
    try {
      isLoading.value = true;

      // TODO: Call API to update meeting
      await Future.delayed(const Duration(seconds: 1));

      final index = allMeetings.indexWhere((m) => m.id == meeting.id);
      if (index != -1) {
        allMeetings[index] = meeting;
        Get.snackbar('Success', 'Meeting updated successfully');
        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update meeting: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMeeting(String meetingId) async {
    try {
      isLoading.value = true;

      // TODO: Call API to delete meeting
      await Future.delayed(const Duration(seconds: 1));

      allMeetings.removeWhere((meeting) => meeting.id == meetingId);

      Get.snackbar('Success', 'Meeting deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete meeting: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Meeting? getMeetingById(String id) {
    try {
      return allMeetings.firstWhere((meeting) => meeting.id == id);
    } catch (e) {
      return null;
    }
  }

  void searchMeetings(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  String _generateMeetingId() {
    // Generate a 10-digit meeting ID
    final now = DateTime.now();
    return '${now.microsecondsSinceEpoch}'.substring(0, 10);
  }

  String _generatePasscode() {
    // Generate a 6-digit passcode
    final now = DateTime.now();
    return '${now.microsecondsSinceEpoch}'.substring(7, 13);
  }

  List<Meeting> _generateMockMeetings() {
    final user = _authController.currentUser.value;
    if (user == null) return [];

    final now = DateTime.now();

    return [
      Meeting(
        id: '1234567890',
        title: 'Math Class - Chapter 5',
        description: 'Advanced calculus and integration problems',
        hostId: user.isTeacher ? user.id : 'teacher1',
        hostName: user.isTeacher ? user.name : 'Dr. Smith',
        passcode: '123456',
        scheduledTime: now.add(const Duration(hours: 2)),
        durationMinutes: 60,
        status: MeetingStatus.scheduled,
        participants: user.isStudent ? [user.id] : ['student1', 'student2'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Meeting(
        id: '2345678901',
        title: 'Physics Lab Session',
        description: 'Quantum mechanics experiment discussion',
        hostId: user.isTeacher ? user.id : 'teacher2',
        hostName: user.isTeacher ? user.name : 'Prof. Johnson',
        passcode: '234567',
        scheduledTime: now.add(const Duration(days: 1)),
        durationMinutes: 90,
        status: MeetingStatus.scheduled,
        participants: user.isStudent ? [user.id] : ['student3', 'student4'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      if (user.isTeacher) ...[
        Meeting(
          id: '3456789012',
          title: 'Chemistry Review',
          description: 'Organic chemistry final review session',
          hostId: user.id,
          hostName: user.name,
          passcode: '345678',
          scheduledTime: now.subtract(const Duration(hours: 2)),
          durationMinutes: 75,
          status: MeetingStatus.ended,
          participants: ['student1', 'student2', 'student3'],
          createdAt: now.subtract(const Duration(days: 3)),
          startedAt: now.subtract(const Duration(hours: 2, minutes: 5)),
          endedAt: now.subtract(const Duration(minutes: 50)),
        ),
      ],
    ];
  }
}
