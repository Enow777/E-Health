import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({
    super.key,
    required this.doctor,
    this.roomUrl = '',
  });

  final Doctor doctor;
  final String roomUrl;

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  var _cameraOn = true;
  var _micOn = true;
  var _launching = false;

  String get _effectiveRoomUrl =>
      widget.roomUrl.isNotEmpty ? widget.roomUrl : 'https://meet.jit.si/NkapHealth-demo';

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.videoConsultationTitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          // ── Preview pane ───────────────────────────────────────────────────
          Container(
            height: 330,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Avatar(
                        initials: widget.doctor.initials,
                        size: 86,
                        pale: true,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.doctor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.tapJoinCall,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFC8E4E0), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Self-view placeholder (top-right)
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    width: 96,
                    height: 128,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF315B56),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6AA099)),
                    ),
                    child: Icon(
                      _cameraOn
                          ? Icons.person_rounded
                          : Icons.videocam_off_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Pre-join controls ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CallButton(
                icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                selected: _micOn,
                tooltip: _micOn ? l10n.muteMic : l10n.unmuteMic,
                onTap: () => setState(() => _micOn = !_micOn),
              ),
              const SizedBox(width: 12),
              _CallButton(
                icon: _cameraOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                selected: _cameraOn,
                tooltip: _cameraOn ? l10n.turnOffCamera : l10n.turnOnCamera,
                onTap: () => setState(() => _cameraOn = !_cameraOn),
              ),
              const SizedBox(width: 12),
              _CallButton(
                icon: Icons.call_end_rounded,
                danger: true,
                tooltip: l10n.leave,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Doctor info + join ─────────────────────────────────────────────
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.doctor.specialty} · ${widget.doctor.clinic}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _launching ? null : _joinCall,
                    icon: _launching
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.video_call_outlined),
                    label: Text(_launching ? l10n.opening : l10n.joinCall),
                  ),
                ),
                const SizedBox(height: 10),
                // Room URL chip — lets user copy it or share with others
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _copyRoomUrl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _effectiveRoomUrl,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy_rounded,
                            size: 16, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    l10n.copyLinkHint,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.howItWorks,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _Tip(
                  icon: Icons.security_rounded,
                  text: l10n.callIsPrivate,
                ),
                const SizedBox(height: 8),
                _Tip(
                  icon: Icons.videocam_rounded,
                  text: l10n.checkCameraAndMic,
                ),
                const SizedBox(height: 8),
                _Tip(
                  icon: Icons.open_in_browser_rounded,
                  text: l10n.joinCallOpensJitsi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinCall() async {
    setState(() => _launching = true);
    try {
      final uri = Uri.parse(_effectiveRoomUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        showAppMessage(context, AppL10n.of(context).couldNotOpenCall);
      }
    } on Object {
      if (mounted) {
        showAppMessage(context, AppL10n.of(context).couldNotOpenCall);
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  Future<void> _copyRoomUrl() async {
    await Clipboard.setData(ClipboardData(text: _effectiveRoomUrl));
    if (mounted) showAppMessage(context, AppL10n.of(context).roomLinkCopied);
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: danger || selected ? Colors.white : AppColors.primary,
        style: IconButton.styleFrom(
          backgroundColor: danger
              ? const Color(0xFFE25555)
              : selected
                  ? AppColors.primary
                  : Colors.white,
          minimumSize: const Size(54, 54),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
