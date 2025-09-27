// lib/src/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_boilerplate/src/controllers/auth_controller.dart';
import 'package:get_boilerplate/src/controllers/meeting_list_controller.dart';
import 'package:get_boilerplate/src/models/user_model.dart';
import 'package:get_boilerplate/src/models/meeting_model.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthController _authController = Get.find<AuthController>();
  final MeetingListController _meetingController =
      Get.put(MeetingListController());

  @override
  void initState() {
    super.initState();
    _meetingController.loadMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoConference'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                _authController.userName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.person_outlined),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
                onTap: () => Get.toNamed('/profile'),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () => Get.toNamed('/settings'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _authController.logout(),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _meetingController.loadMeetings,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Upcoming meetings
              _buildUpcomingMeetings(),
              const SizedBox(height: 24),

              // Recent meetings (for teachers)
              if (_authController.isTeacher) _buildRecentMeetings(),
            ],
          ),
        ),
      ),
      floatingActionButton: _authController.isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/create-meeting'),
              icon: const Icon(Icons.add),
              label: const Text('New Meeting'),
            )
          : FloatingActionButton(
              onPressed: () => Get.toNamed('/join-meeting'),
              child: const Icon(Icons.login),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    _authController.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${_authController.userName}!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_authController.userRole.displayName} • ${_authController.userEmail}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (_authController.isTeacher) ...[
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Create Meeting',
                  subtitle: 'Start a new video call',
                  color: Colors.blue,
                  onTap: () => Get.toNamed('/create-meeting'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.schedule,
                  title: 'Schedule Meeting',
                  subtitle: 'Plan for later',
                  color: Colors.orange,
                  onTap: () => Get.toNamed('/schedule-meeting'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.login,
                  title: 'Join Meeting',
                  subtitle: 'Enter meeting ID',
                  color: Colors.green,
                  onTap: () => Get.toNamed('/join-meeting'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.history,
                  title: 'Meeting History',
                  subtitle: 'View past meetings',
                  color: Colors.purple,
                  onTap: () => Get.toNamed('/meeting-history'),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.login,
                  title: 'Join Meeting',
                  subtitle: 'Enter meeting ID or link',
                  color: Colors.green,
                  onTap: () => Get.toNamed('/join-meeting'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.history,
                  title: 'My Classes',
                  subtitle: 'View joined classes',
                  color: Colors.purple,
                  onTap: () => Get.toNamed('/my-classes'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMeetings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Meetings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/meetings'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (_meetingController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingMeetings =
              _meetingController.upcomingMeetings.take(3).toList();

          if (upcomingMeetings.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming meetings',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _authController.isTeacher
                          ? 'Create a new meeting to get started'
                          : 'Join a meeting or wait for invitations',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: upcomingMeetings
                .map((meeting) => _buildMeetingCard(meeting))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRecentMeetings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Meetings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/meeting-history'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final recentMeetings =
              _meetingController.recentMeetings.take(2).toList();

          if (recentMeetings.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No recent meetings',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: recentMeetings
                .map((meeting) => _buildMeetingCard(meeting, isRecent: true))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildMeetingCard(Meeting meeting, {bool isRecent = false}) {
    final isLive = meeting.status == MeetingStatus.inProgress;
    final timeFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (isLive || (!isRecent && meeting.canJoin)) {
            Get.toNamed('/meeting-room/${meeting.id}');
          } else {
            _showMeetingDetails(meeting);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (meeting.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            meeting.description,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(meeting.scheduledTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    meeting.formattedDuration,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  if (meeting.participants.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${meeting.participants.length}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
              if (isLive || (!isRecent && meeting.canJoin)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/meeting-room/${meeting.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLive ? Colors.red : Colors.blue,
                    ),
                    child: Text(isLive ? 'Join Live Meeting' : 'Join Meeting'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMeetingDetails(Meeting meeting) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(meeting.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text('Host: ${meeting.hostName}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                    'Time: ${DateFormat('MMM dd, yyyy • HH:mm').format(meeting.scheduledTime)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                Text('Duration: ${meeting.formattedDuration}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.key, size: 20),
                const SizedBox(width: 8),
                Text('Meeting ID: ${meeting.id}'),
              ],
            ),
            const SizedBox(height: 24),
            if (meeting.canJoin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/meeting-room/${meeting.id}');
                  },
                  child: const Text('Join Meeting'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
