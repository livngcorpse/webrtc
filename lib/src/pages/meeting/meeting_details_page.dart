// lib/src/pages/meeting/meeting_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/controllers/meeting_list_controller.dart';
import 'package:get_boilerplate/src/models/meeting_model.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class MeetingDetailsPage extends StatefulWidget {
  const MeetingDetailsPage({super.key});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final MeetingListController _controller = Get.find<MeetingListController>();
  late String meetingId;
  Meeting? meeting;

  @override
  void initState() {
    super.initState();
    meetingId = Get.parameters['id'] ?? '';
    meeting = _controller.getMeetingById(meetingId);
  }

  @override
  Widget build(BuildContext context) {
    if (meeting == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meeting Not Found')),
        body: const Center(
          child: Text('Meeting not found or has been deleted.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit')
                  ],
                ),
                onTap: () => _editMeeting(),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share')
                  ],
                ),
                onTap: () => _shareMeeting(),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _deleteMeeting(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Status Badge
            if (meeting!.isLive)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 6),
                    Text('LIVE',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // Meeting Title and Description
            Text(
              meeting!.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (meeting!.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                meeting!.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 24),

            // Meeting Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      'Host',
                      meeting!.hostName,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.access_time,
                      'Date & Time',
                      DateFormat('MMM dd, yyyy • HH:mm')
                          .format(meeting!.scheduledTime),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.schedule,
                      'Duration',
                      meeting!.formattedDuration,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.key,
                      'Meeting ID',
                      meeting!.id,
                      copyable: true,
                    ),
                    if (meeting!.passcode.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        Icons.lock,
                        'Passcode',
                        meeting!.passcode,
                        copyable: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Meeting Link Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting Link',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              meeting!.meetingUrl,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _copyToClipboard(meeting!.meetingUrl),
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy link',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Participants Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Participants',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${meeting!.participants.length}'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (meeting!.participants.isEmpty)
                      const Text('No participants yet')
                    else
                      ...meeting!.participants.map(
                        (participantId) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(participantId[0].toUpperCase()),
                          ),
                          title: Text('Participant $participantId'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (meeting!.canJoin)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/meeting-room/${meeting!.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: meeting!.isLive ? Colors.red : Colors.blue,
                  ),
                  child: Text(
                      meeting!.isLive ? 'Join Live Meeting' : 'Start Meeting'),
                ),
              ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareMeeting,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(meeting!.meetingUrl),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              onPressed: () => _copyToClipboard(value),
              icon: const Icon(Icons.copy, size: 20),
              tooltip: 'Copy $label',
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareMeeting() {
    final shareText = '''
Join my meeting: ${meeting!.title}

📅 ${DateFormat('MMM dd, yyyy • HH:mm').format(meeting!.scheduledTime)}
⏰ Duration: ${meeting!.formattedDuration}

Meeting Link: ${meeting!.meetingUrl}

Meeting ID: ${meeting!.id}
${meeting!.passcode.isNotEmpty ? 'Passcode: ${meeting!.passcode}' : ''}
''';

    Share.share(shareText, subject: 'Meeting Invitation: ${meeting!.title}');
  }

  void _editMeeting() {
    // TODO: Navigate to edit meeting page
    Get.snackbar('Info', 'Edit meeting feature will be implemented');
  }

  void _deleteMeeting() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text(
            'Are you sure you want to delete this meeting? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _controller.deleteMeeting(meeting!.id);
              if (success) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
