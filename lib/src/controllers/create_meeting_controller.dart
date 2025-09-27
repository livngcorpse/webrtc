// lib/src/controllers/create_meeting_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/models/meeting_model.dart';
import 'package:get_boilerplate/src/controllers/meeting_list_controller.dart';

class CreateMeetingController extends GetxController {
  final MeetingListController _meetingListController =
      Get.find<MeetingListController>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final RxInt duration = 60.obs; // minutes
  final RxBool isLoading = false.obs;

  // Meeting settings
  final RxBool allowParticipantsToUnmute = true.obs;
  final RxBool allowParticipantsToTurnOnVideo = true.obs;
  final RxBool allowScreenSharing = true.obs;
  final RxBool enableWaitingRoom = false.obs;
  final RxBool enableRecording = false.obs;
  final RxBool muteParticipantsOnJoin = false.obs;
  final RxBool disableVideoOnJoin = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  DateTime get scheduledDateTime {
    final date = selectedDate.value;
    final time = selectedTime.value;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  MeetingSettings get meetingSettings {
    return MeetingSettings(
      allowParticipantsToUnmute: allowParticipantsToUnmute.value,
      allowParticipantsToTurnOnVideo: allowParticipantsToTurnOnVideo.value,
      allowScreenSharing: allowScreenSharing.value,
      enableWaitingRoom: enableWaitingRoom.value,
      enableRecording: enableRecording.value,
      muteParticipantsOnJoin: muteParticipantsOnJoin.value,
      disableVideoOnJoin: disableVideoOnJoin.value,
    );
  }

  Future<void> createMeeting() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final meeting = await _meetingListController.createMeeting(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        scheduledTime: scheduledDateTime,
        durationMinutes: duration.value,
        settings: meetingSettings,
      );

      if (meeting != null) {
        Get.back();
        Get.toNamed('/meeting-details/${meeting.id}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create meeting: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createInstantMeeting() async {
    if (titleController.text.trim().isEmpty) {
      titleController.text = 'Instant Meeting';
    }

    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();

    await createMeeting();
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a meeting title');
      return false;
    }

    final now = DateTime.now();
    if (scheduledDateTime.isBefore(now)) {
      Get.snackbar('Error', 'Please select a future date and time');
      return false;
    }

    if (duration.value < 15) {
      Get.snackbar('Error', 'Minimum duration is 15 minutes');
      return false;
    }

    return true;
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  void updateTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  void updateDuration(int minutes) {
    duration.value = minutes;
  }
}
