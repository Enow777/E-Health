import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/models.dart';
import '../appointments/book_appointment_screen.dart';
import '../chat/chat_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return StreamBuilder<bool>(
      stream: repo?.watchIsDoctorSaved(doctor.id) ?? Stream.value(false),
      builder: (context, snapshot) {
        final l10n = AppL10n.of(context);
        final isSaved = snapshot.data ?? false;
        return AppPage(
          title: l10n.doctorProfileTitle,
          action: IconButton(
            tooltip: isSaved ? l10n.removeFromSaved : l10n.saveDoctor,
            onPressed: () => _toggleSave(context, repo, isSaved),
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : null,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(child: Avatar(initials: doctor.initials, size: 88)),
              const SizedBox(height: 14),
              Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                doctor.specialty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.clinic,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              SoftCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(
                      label: l10n.rating,
                      value: doctor.hasRatings
                          ? '${doctor.rating} / 5'
                          : l10n.noReviews,
                    ),
                    const _Divider(),
                    _Metric(label: l10n.experience, value: doctor.experience),
                    const _Divider(),
                    _Metric(label: l10n.distance, value: doctor.distance),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.about, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(doctor.about, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              _InfoLine(icon: Icons.language_rounded, text: doctor.languages),
              const SizedBox(height: 10),
              _InfoLine(
                icon: Icons.location_on_outlined,
                text: '${doctor.clinic} · ${l10n.distanceAway(doctor.distance)}',
              ),
              const SizedBox(height: 24),
              Text(
                l10n.nextAvailability,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              SoftCard(
                color: const Color(0xFFEAF5F3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      doctor.nextAvailable,
                      style: const TextStyle(
                        color: Color(0xFF225E58),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookAppointmentScreen(doctor: doctor),
                  ),
                ),
                child: Text(l10n.bookAnAppointment),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _openChat(context, repo),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(l10n.messageDoctor),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openChat(BuildContext context, HealthRepository? repo) async {
    if (repo == null) {
      showAppMessage(context, AppL10n.of(context).signInToMessage);
      return;
    }
    final uid = repo.currentUid ?? '';
    final patientSnap = await repo.watchProfile().first;
    final conv = await repo.getOrCreateConversation(
      patientId: uid,
      patientName: patientSnap.fullName,
      doctorId: doctor.id,
      doctorName: doctor.name,
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: conv.id,
          otherPersonName: doctor.name,
          otherPersonInitials: doctor.initials,
          senderName: patientSnap.fullName,
        ),
      ),
    );
  }

  Future<void> _toggleSave(
    BuildContext context,
    HealthRepository? repo,
    bool isSaved,
  ) async {
    if (repo == null) {
      showAppMessage(context, AppL10n.of(context).signInToSave);
      return;
    }
    if (isSaved) {
      await repo.unsaveDoctor(doctor.id);
      if (context.mounted) showAppMessage(context, AppL10n.of(context).removedFromSaved);
    } else {
      await repo.saveDoctor(doctor);
      if (context.mounted) showAppMessage(context, AppL10n.of(context).savedDoctorMsg(doctor.name));
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 32, child: VerticalDivider());
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF52706B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
