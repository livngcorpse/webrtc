import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as RTC;

class RemoteViewCard extends StatefulWidget {
  final RTC.RTCVideoRenderer remoteRenderer;
  final String? participantName;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final String? connectionQuality;
  final bool showControls;

  const RemoteViewCard({
    super.key,
    required this.remoteRenderer,
    this.participantName,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.connectionQuality,
    this.showControls = true,
  });

  @override
  State<StatefulWidget> createState() => _RemoteViewCardState();
}

class _RemoteViewCardState extends State<RemoteViewCard> {
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getConnectionQualityColor() {
    switch (widget.connectionQuality?.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConnectionQualityIndicator() {
    if (widget.connectionQuality == null) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.signal_cellular_alt,
              color: _getConnectionQualityColor(),
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              widget.connectionQuality!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (widget.isAudioMuted)
              const Icon(
                Icons.mic_off,
                color: Colors.red,
                size: 16,
              ),
            if (widget.isAudioMuted) const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.participantName ?? 'Participant',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOffPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            widget.participantName ?? 'Participant',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? Colors.blue : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              // Video content
              if (widget.remoteRenderer.textureId != null &&
                  !widget.isVideoMuted)
                Positioned.fill(
                  child: RTC.RTCVideoView(
                    widget.remoteRenderer,
                    objectFit:
                        RTC.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              else
                _buildVideoOffPlaceholder(),

              // Connection quality indicator
              if (widget.showControls) _buildConnectionQualityIndicator(),

              // Participant info bar
              if (widget.showControls) _buildParticipantInfo(),

              // Video muted indicator
              if (widget.isVideoMuted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

              // Loading indicator when connecting
              if (widget.remoteRenderer.textureId == null)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
