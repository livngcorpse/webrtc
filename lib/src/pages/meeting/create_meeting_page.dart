// lib/src/pages/meeting/create_meeting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/controllers/create_meeting_controller.dart';
import 'package:intl/intl.dart';

class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final CreateMeetingController _controller =
      Get.put(CreateMeetingController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
        actions: [
          TextButton(
            onPressed: _controller.createInstantMeeting,
            child: const Text('Start Now'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting Details Section
              _buildSectionHeader('Meeting Details'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _controller.titleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a meeting title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Schedule Section
              _buildSectionHeader('Schedule'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Meeting Settings Section
              _buildSectionHeader('Meeting Settings'),
              const SizedBox(height: 16),

              _buildSettingsCard(),
              const SizedBox(height: 32),

              // Create Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading.value
                          ? null
                          : _handleCreateMeeting,
                      child: _controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Meeting'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    DateFormat('MMM dd, yyyy')
                        .format(_controller.selectedDate.value),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: InkWell(
        onTap: _selectTime,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    'Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    _controller.selectedTime.value.format(context),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${_controller.duration.value} minutes'),
                        ),
                        Text(_formatDuration(_controller.duration.value)),
                      ],
                    ),
                    Slider(
                      value: _controller.duration.value.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      onChanged: (value) =>
                          _controller.updateDuration(value.toInt()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _controller.updateDuration(30),
                          child: const Text('30min'),
                        ),
                        TextButton(
                          onPressed: () => _controller.updateDuration(60),
                          child: const Text('1hr'),
                        ),
                        TextButton(
                          onPressed: () => _controller.updateDuration(120),
                          child: const Text('2hr'),
                        ),
                        TextButton(
                          onPressed: () => _controller.updateDuration(180),
                          child: const Text('3hr'),
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings),
                const SizedBox(width: 8),
                Text(
                  'Participant Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  title: const Text('Allow participants to unmute'),
                  subtitle: const Text('Let participants unmute themselves'),
                  value: _controller.allowParticipantsToUnmute.value,
                  onChanged: (value) =>
                      _controller.allowParticipantsToUnmute.value = value,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Allow participants to turn on video'),
                  subtitle: const Text('Let participants control their video'),
                  value: _controller.allowParticipantsToTurnOnVideo.value,
                  onChanged: (value) =>
                      _controller.allowParticipantsToTurnOnVideo.value = value,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Allow screen sharing'),
                  subtitle: const Text('Let participants share their screen'),
                  value: _controller.allowScreenSharing.value,
                  onChanged: (value) =>
                      _controller.allowScreenSharing.value = value,
                )),
            const Divider(),
            Obx(() => SwitchListTile(
                  title: const Text('Enable waiting room'),
                  subtitle: const Text('Manually approve participants'),
                  value: _controller.enableWaitingRoom.value,
                  onChanged: (value) =>
                      _controller.enableWaitingRoom.value = value,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Mute participants on join'),
                  subtitle: const Text('Start with audio muted'),
                  value: _controller.muteParticipantsOnJoin.value,
                  onChanged: (value) =>
                      _controller.muteParticipantsOnJoin.value = value,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Turn off video on join'),
                  subtitle: const Text('Start with video disabled'),
                  value: _controller.disableVideoOnJoin.value,
                  onChanged: (value) =>
                      _controller.disableVideoOnJoin.value = value,
                )),
            Obx(() => SwitchListTile(
                  title: const Text('Enable recording'),
                  subtitle: const Text('Allow meeting to be recorded'),
                  value: _controller.enableRecording.value,
                  onChanged: (value) =>
                      _controller.enableRecording.value = value,
                )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '${hours}hr';
    }

    return '${hours}hr ${remainingMinutes}min';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      _controller.updateDate(picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime.value,
    );

    if (picked != null) {
      _controller.updateTime(picked);
    }
  }

  void _handleCreateMeeting() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.createMeeting();
    }
  }
}
