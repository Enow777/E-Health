import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../appointments/video_consultation_screen.dart';
import '../notifications/notifications_screen.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return PageFrame(
      child: HealthStream<DoctorProfile?>(
        stream: repo?.watchDoctorProfile(),
        fallback: null,
        builder: (context, profile) =>
            HealthStream<List<Appointment>>(
          stream: repo?.watchDoctorAppointments(),
          fallback: const [],
          builder: (context, appointments) {
            final now = DateTime.now();
            final todayLabel = _weekdayLabel(now);
            final active = {'upcoming', 'pending'};
            final todayAppts = appointments
                .where((a) =>
                    active.contains(a.status) &&
                    (a.date.contains(todayLabel) ||
                        a.date.toLowerCase().contains('today')))
                .toList();
            final upcoming = appointments
                .where((a) => active.contains(a.status))
                .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Row(
                  children: [
                    const BrandMark(),
                    const Spacer(),
                    IconButton(
                      onPressed: () => openNotifications(context),
                      icon: const Icon(Icons.notifications_none_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Avatar(
                      initials: profile?.initials ??
                          _initialsFromAuth(),
                      size: 42,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${_timeGreeting(l10n)}, Dr. ${_firstName(profile)}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  profile?.specialty.isNotEmpty == true
                      ? '${profile!.specialty} · ${profile.clinic}'
                      : 'Nkap Health',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.today,
                        value: '${todayAppts.length}',
                        sub: l10n.appointmentsCount(todayAppts.length),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_outline_rounded,
                        label: l10n.totalLabel,
                        value: '${upcoming.length}',
                        sub: l10n.upcomingLabel,
                        color: const Color(0xFF1A5276),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeading(title: l10n.upcomingAppointments),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  SoftCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded,
                              color: AppColors.muted),
                          const SizedBox(width: 12),
                          Text(
                            l10n.noUpcomingAppointmentsDoc,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...upcoming.take(5).map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: _DoctorAppointmentTile(appointment: a),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _firstName(DoctorProfile? profile) {
    if (profile != null && profile.fullName.isNotEmpty) {
      return profile.fullName.split(' ').first;
    }
    final name = FirebaseAuth.instance.currentUser?.displayName ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'Doctor';
  }

  String _initialsFromAuth() {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'D';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

String _timeGreeting(AppL10n l10n) {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) return l10n.goodMorning;
  if (h >= 12 && h < 17) return l10n.goodAfternoon;
  return l10n.goodEvening;
}

String _weekdayLabel(DateTime dt) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[dt.weekday - 1];
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DoctorAppointmentTile extends StatelessWidget {
  const _DoctorAppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isVideo = appointment.type.contains('Video');
    return SoftCard(
      child: Row(
        children: [
          Avatar(
            initials: _initials(appointment.patientName),
            size: 46,
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
                  '${appointment.date} · ${appointment.time}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  appointment.type,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (isVideo)
            IconButton(
              onPressed: () async {
                final repo = tryHealthRepository();
                if (!appointment.callActive) {
                  await repo?.setCallActive(appointment.id, true);
                }
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
              icon: Icon(
                appointment.callActive
                    ? Icons.videocam_rounded
                    : Icons.videocam_outlined,
                color: appointment.callActive
                    ? const Color(0xFF2ECC71)
                    : AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
