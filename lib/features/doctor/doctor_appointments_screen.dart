import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../appointments/video_consultation_screen.dart';
import '../doctors/discover_screen.dart';
import '../notifications/notifications_screen.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return PageFrame(
      child: HealthStream<List<Appointment>>(
        stream: repo?.watchDoctorAppointments(),
        fallback: const [],
        builder: (context, all) {
          final pending =
              all.where((a) => a.status == 'pending').toList()
                ..sort((a, b) => a.date.compareTo(b.date));
          final upcoming =
              all.where((a) => a.status == 'upcoming').toList()
                ..sort((a, b) => a.date.compareTo(b.date));
          final past = all
              .where((a) =>
                  a.status == 'past' ||
                  a.status == 'completed' ||
                  a.status == 'cancelled')
              .toList();

          final completed =
              past.where((a) => a.status == 'completed').length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              PageTopBar(
                title: l10n.schedule,
                onNotifications: () => openNotifications(context),
              ),
              const SizedBox(height: 20),

              _OverviewStrip(
                pending: pending.length,
                upcoming: upcoming.length,
                completed: completed,
              ),
              const SizedBox(height: 24),

              if (pending.isNotEmpty) ...[
                Row(
                  children: [
                    Text(l10n.pendingRequests,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB76735)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pending.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _DoctorApptCard(
                        appointment: a, repo: repo, isPending: true),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SectionHeading(title: l10n.upcoming),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                _EmptyState(
                  icon: Icons.event_available_outlined,
                  message: l10n.noConfirmedAppointments,
                )
              else
                ...upcoming.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _DoctorApptCard(appointment: a, repo: repo),
                  ),
                ),
              const SizedBox(height: 24),
              SectionHeading(title: l10n.pastConsultations),
              const SizedBox(height: 12),
              if (past.isEmpty)
                _EmptyState(
                  icon: Icons.history_rounded,
                  message: l10n.noPastConsultations,
                )
              else
                ...past.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _DoctorApptCard(appointment: a, repo: repo, past: true),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DoctorApptCard extends StatelessWidget {
  const _DoctorApptCard({
    required this.appointment,
    required this.repo,
    this.past = false,
    this.isPending = false,
  });

  final Appointment appointment;
  final HealthRepository? repo;
  final bool past;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isVideo = appointment.type.contains('Video');
    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Avatar(
                initials: _initials(appointment.patientName),
                size: 47,
                pale: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName.isNotEmpty
                          ? appointment.patientName
                          : l10n.patient,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      appointment.type,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (!past && !isPending)
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: Color(0xFF7B8D8A)),
                  onPressed: () => _showOptions(context),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE6EEEC)),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF4E6A66)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${appointment.formattedDate} · ${appointment.time}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (appointment.urgency != 'normal') ...[
                const SizedBox(width: 6),
                _UrgencyBadge(urgency: appointment.urgency),
              ],
              const SizedBox(width: 6),
              _StatusBadge(status: appointment.status),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respond(context, accept: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE25555),
                      side: const BorderSide(color: Color(0xFFE25555)),
                    ),
                    child: Text(l10n.decline),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _respond(context, accept: true),
                    child: Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
          if (!past && !isPending && isVideo) ...[
            const SizedBox(height: 12),
            if (!appointment.isInCallWindow) ...[
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: Color(0xFF8A9E9B)),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.callScheduledAt} ${appointment.time}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A9E9B),
                    ),
                  ),
                ],
              ),
            ] else if (appointment.callActive) ...[
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appointment.patientInCall
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFBDBDBD),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.patientInCall
                        ? l10n.patientIsOnline
                        : l10n.waitingForPatient,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: appointment.patientInCall
                          ? const Color(0xFF2ECC71)
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await repo?.setCallActive(appointment.id, false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE25555),
                        side: const BorderSide(color: Color(0xFFE25555)),
                      ),
                      icon: const Icon(Icons.call_end_rounded, size: 16),
                      label: Text(l10n.endCall),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VideoConsultationScreen(
                              doctor: appointment.doctor,
                              roomUrl: appointment.videoRoomUrl),
                        ),
                      ),
                      icon: const Icon(Icons.videocam_outlined, size: 16),
                      label: Text(l10n.openCall),
                    ),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await repo?.setCallActive(appointment.id, true);
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VideoConsultationScreen(
                              doctor: appointment.doctor,
                              roomUrl: appointment.videoRoomUrl),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: Text(l10n.startCall),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppL10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.patientName.isNotEmpty
                  ? appointment.patientName
                  : l10n.patient,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            Text(
              '${appointment.formattedDate} · ${appointment.time}',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.primary),
              title: Text(l10n.markAsCompleted),
              onTap: () async {
                Navigator.pop(ctx);
                await repo?.updateAppointmentStatus(
                    appointment.id, 'completed');
                if (context.mounted) {
                  showAppMessage(context, l10n.markedAsCompleted);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined,
                  color: Color(0xFFE25555)),
              title: Text(l10n.cancelAppointment,
                  style: const TextStyle(color: Color(0xFFE25555))),
              onTap: () async {
                Navigator.pop(ctx);
                await repo?.cancelAppointment(appointment.id);
                if (context.mounted) {
                  showAppMessage(context, l10n.appointmentCancelled);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(BuildContext context, {required bool accept}) async {
    final l10n = AppL10n.of(context);
    final newStatus = accept ? 'upcoming' : 'cancelled';
    await repo?.updateAppointmentStatus(appointment.id, newStatus);
    if (context.mounted) {
      showAppMessage(
        context,
        accept ? l10n.appointmentAccepted : l10n.appointmentDeclined,
      );
    }
  }

  String _initials(String name) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge({required this.urgency});
  final String urgency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final (label, bg, fg, icon) = switch (urgency) {
      'emergency' => (
          l10n.urgencyEmergency,
          const Color(0xFFFFEEEE),
          const Color(0xFFE25555),
          Icons.emergency_rounded,
        ),
      _ => (
          l10n.urgencyUrgent,
          const Color(0xFFFFF3E0),
          const Color(0xFFB76735),
          Icons.warning_amber_rounded,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final (label, bg, fg) = switch (status) {
      'completed' => (l10n.completed, const Color(0xFFE2F3EF), AppColors.primary),
      'cancelled' => (l10n.cancelled, const Color(0xFFFFEEEE), const Color(0xFFE25555)),
      'pending'   => (l10n.pending,   const Color(0xFFFFF3E0), const Color(0xFFB76735)),
      _           => (l10n.upcoming,  const Color(0xFFEAF4F2), AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 20),
          const SizedBox(width: 10),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ── Overview strip ────────────────────────────────────────────────────────────

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({
    required this.pending,
    required this.upcoming,
    required this.completed,
  });

  final int pending;
  final int upcoming;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Row(
      children: [
        _OverviewTile(
          count: pending,
          label: l10n.pendingOverview,
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFFB76735),
          bgColor: const Color(0xFFFFF3E0),
        ),
        const SizedBox(width: 10),
        _OverviewTile(
          count: upcoming,
          label: l10n.upcomingOverview,
          icon: Icons.event_available_rounded,
          iconColor: AppColors.primary,
          bgColor: const Color(0xFFEAF5F3),
        ),
        const SizedBox(width: 10),
        _OverviewTile(
          count: completed,
          label: l10n.completedOverview,
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF2ECC71),
          bgColor: const Color(0xFFE8F8EF),
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(180),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: iconColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B8A86),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
