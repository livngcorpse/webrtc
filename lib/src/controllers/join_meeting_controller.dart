// lib/src/controllers/join_meeting_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/controllers/auth_controller.dart';
import 'package:get_boilerplate/src/controllers/meeting_list_controller.dart';

class JoinMeetingController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final MeetingListController _meetingListController =
      Get.find<MeetingListController>();

  final meetingIdController = TextEditingController();
  final passcodeController = TextEditingController();
  final nameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool showPasscodeField = false.obs;
  final RxBool isAudioMuted = false.obs;
  final RxBool isVideoMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill name if user is authenticated
    if (_authController.isAuthenticated.value) {
      nameController.text = _authController.userName;
    }
  }

  @override
  void onClose() {
    meetingIdController.dispose();
    passcodeController.dispose();
    nameController.dispose();
    super.onClose();
  }

  Future<void> joinMeeting() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final meetingId = meetingIdController.text.trim();
      final passcode = passcodeController.text.trim();
      final name = nameController.text.trim();

      // Check if meeting exists
      var meeting = _meetingListController.getMeetingById(meetingId);

      if (meeting == null) {
        // Try to fetch meeting from server
        await _fetchMeetingFromServer(meetingId);
        meeting = _meetingListController.getMeetingById(meetingId);
      }

      if (meeting == null) {
        Get.snackbar(
            'Error', 'Meeting not found. Please check the meeting ID.');
        return;
      }

      // Check passcode if required
      if (passcode.isNotEmpty && meeting.passcode != passcode) {
        Get.snackbar('Error', 'Incorrect passcode. Please try again.');
        return;
      }

      // Check if passcode is required but not provided
      if (meeting.passcode.isNotEmpty && passcode.isEmpty) {
        showPasscodeField.value = true;
        Get.snackbar('Info', 'This meeting requires a passcode.');
        return;
      }

      // Join the meeting
      final joinSuccess = await _joinMeetingRoom(
        meetingId: meetingId,
        participantName: name,
        isAudioMuted: isAudioMuted.value,
        isVideoMuted: isVideoMuted.value,
      );

      if (joinSuccess) {
        Get.offAllNamed('/meeting-room/$meetingId', arguments: {
          'participantName': name,
          'isAudioMuted': isAudioMuted.value,
          'isVideoMuted': isVideoMuted.value,
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join meeting: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinMeetingByUrl(String meetingUrl) async {
    try {
      // Extract meeting ID from URL
      final uri = Uri.parse(meetingUrl);
      final meetingId = uri.pathSegments.lastWhere(
        (segment) => segment.isNotEmpty,
        orElse: () => '',
      );

      if (meetingId.isEmpty) {
        Get.snackbar('Error', 'Invalid meeting URL');
        return;
      }

      meetingIdController.text = meetingId;
      await joinMeeting();
    } catch (e) {
      Get.snackbar('Error', 'Failed to parse meeting URL: $e');
    }
  }

  bool _validateForm() {
    final meetingId = meetingIdController.text.trim();
    final name = nameController.text.trim();

    if (meetingId.isEmpty) {
      Get.snackbar('Error', 'Please enter a meeting ID');
      return false;
    }

    if (meetingId.length < 10) {
      Get.snackbar('Error', 'Meeting ID must be at least 10 digits');
      return false;
    }

    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return false;
    }

    return true;
  }

  Future<void> _fetchMeetingFromServer(String meetingId) async {
    // TODO: Implement API call to fetch meeting details
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> _joinMeetingRoom({
    required String meetingId,
    required String participantName,
    required bool isAudioMuted,
    required bool isVideoMuted,
  }) async {
    try {
      // TODO: Implement joining meeting room logic
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  void toggleAudio() {
    isAudioMuted.value = !isAudioMuted.value;
  }

  void toggleVideo() {
    isVideoMuted.value = !isVideoMuted.value;
  }

  void parseMeetingId(String input) {
    // Remove any non-numeric characters
    final cleanInput = input.replaceAll(RegExp(r'[^0-9]'), '');
    meetingIdController.text = cleanInput;
  }
}
