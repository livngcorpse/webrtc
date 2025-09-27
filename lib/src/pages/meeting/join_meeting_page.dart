// lib/src/pages/meeting/join_meeting_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/controllers/join_meeting_controller.dart';
import 'package:get_boilerplate/src/controllers/auth_controller.dart';

class JoinMeetingPage extends StatefulWidget {
  const JoinMeetingPage({super.key});

  @override
  State<JoinMeetingPage> createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final JoinMeetingController _controller = Get.put(JoinMeetingController());
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header
              const Icon(
                Icons.video_call,
                size: 60,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              Text(
                'Join a Meeting',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Enter the meeting ID or paste the meeting link',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Meeting ID Input
              TextFormField(
                controller: _controller.meetingIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _MeetingIdFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Meeting ID',
                  hintText: 'Enter 10-digit meeting ID',
                  prefixIcon: const Icon(Icons.videocam),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _pasteFromClipboard,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a meeting ID';
                  }
                  final cleanValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleanValue.length < 10) {
                    return 'Meeting ID must be 10 digits';
                  }
                  return null;
                },
                onChanged: _controller.parseMeetingId,
              ),
              const SizedBox(height: 16),

              // Passcode Input (shown conditionally)
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _controller.showPasscodeField.value ? 80 : 0,
                    child: _controller.showPasscodeField.value
                        ? TextFormField(
                            controller: _controller.passcodeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Passcode',
                              hintText: 'Enter meeting passcode',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) {
                              if (_controller.showPasscodeField.value &&
                                  (value?.isEmpty ?? true)) {
                                return 'Please enter the meeting passcode';
                              }
                              return null;
                            },
                          )
                        : const SizedBox.shrink(),
                  )),

              // Name Input (for guests)
              if (!_authController.isAuthenticated.value) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your Name *',
                    hintText: 'Enter your display name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Audio/Video Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Settings',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Join with audio muted'),
                            secondary: Icon(
                              _controller.isAudioMuted.value
                                  ? Icons.mic_off
                                  : Icons.mic,
                              color: _controller.isAudioMuted.value
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            value: _controller.isAudioMuted.value,
                            onChanged: (_) => _controller.toggleAudio(),
                          )),
                      Obx(() => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Join with video off'),
                            secondary: Icon(
                              _controller.isVideoMuted.value
                                  ? Icons.videocam_off
                                  : Icons.videocam,
                              color: _controller.isVideoMuted.value
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            value: _controller.isVideoMuted.value,
                            onChanged: (_) => _controller.toggleVideo(),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Join Button
              Obx(() => SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading.value
                          ? null
                          : _handleJoinMeeting,
                      child: _controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Join Meeting'),
                    ),
                  )),
              const SizedBox(height: 16),

              // Alternative actions
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showQRScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showURLInput,
                      icon: const Icon(Icons.link),
                      label: const Text('Join URL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign up prompt for guests
              if (!_authController.isAuthenticated.value) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Want to host your own meetings?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a free account to start hosting meetings',
                        style: TextStyle(color: Colors.blue[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text('Sign Up Free'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;

        // Check if it's a URL
        if (text.contains('http') || text.contains('://')) {
          _controller.joinMeetingByUrl(text);
        } else {
          // Extract numbers from clipboard
          _controller.parseMeetingId(text);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to paste from clipboard');
    }
  }

  void _showQRScanner() {
    Get.snackbar('Info', 'QR Scanner will be implemented');
  }

  void _showURLInput() {
    final urlController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Join by URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste the meeting invitation link:'),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Meeting URL',
                hintText: 'https://yourapp.com/join/1234567890',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (urlController.text.isNotEmpty) {
                _controller.joinMeetingByUrl(urlController.text);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _handleJoinMeeting() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.joinMeeting();
    }
  }
}

// Custom formatter for meeting ID
class _MeetingIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 10 digits
    final limitedText = text.length > 10 ? text.substring(0, 10) : text;

    // Format as XXX XXX XXXX
    String formattedText = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 3 || i == 6) {
        formattedText += ' ';
      }
      formattedText += limitedText[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
