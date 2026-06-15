import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../auth/auth_gate.dart';
import '../notifications/notifications_screen.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_setup_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return PageFrame(
      child: HealthStream<DoctorProfile?>(
        stream: repo?.watchDoctorProfile(),
        fallback: null,
        builder: (context, profile) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                ],
              ),
              const SizedBox(height: 28),
              _ProfileHeader(profile: profile),
              const SizedBox(height: 20),

              if (profile != null && profile.specialties.isNotEmpty) ...[
                _SpecialtiesCard(specialties: profile.specialties, l10n: l10n),
                const SizedBox(height: 14),
              ],

              // ── Availability toggle ──────────────────────────────────────
              SoftCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.availability,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          profile?.isAvailable == true
                              ? Icons.circle
                              : Icons.circle_outlined,
                          size: 10,
                          color: profile?.isAvailable == true
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            profile?.isAvailable == true
                                ? l10n.availableForAppointments
                                : l10n.notAcceptingAppointments,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: profile?.isAvailable == true
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Switch.adaptive(
                          value: profile?.isAvailable ?? true,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withAlpha(80),
                          onChanged: (v) async {
                            if (profile == null) return;
                            await repo?.updateDoctorProfile(
                                profile.copyWith(isAvailable: v));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Language toggle ──────────────────────────────────────────
              _LanguageTile(l10n: l10n),
              const SizedBox(height: 14),

              _InfoSection(profile: profile, l10n: l10n),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const DoctorSetupScreen1(isFirstSetup: false),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.editProfile),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DoctorScheduleScreen(),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(l10n.manageSchedule),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _signOut(context, l10n),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(l10n.signOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE25555),
                  side: const BorderSide(color: Color(0xFFE25555)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut(BuildContext context, AppL10n l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.signOut,
                  style: const TextStyle(color: Color(0xFFE25555)))),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
            builder: (_) => const AuthGate(showIntro: false)),
        (_) => false,
      );
    }
  }
}

// ── Language toggle card ──────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.l10n});
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LangBtn(
                    label: l10n.english, code: 'en', current: current),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LangBtn(
                    label: l10n.french, code: 'fr', current: current),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  const _LangBtn(
      {required this.label, required this.code, required this.current});
  final String label;
  final String code;
  final String current;

  @override
  Widget build(BuildContext context) {
    final selected = current == code;
    return OutlinedButton(
      onPressed: selected ? null : () => setLocale(code),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            selected ? AppColors.primary.withAlpha(20) : Colors.white,
        foregroundColor: selected ? AppColors.primary : AppColors.muted,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final DoctorProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final initials = profile?.initials ?? _initialsFromAuth();
    final name = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (FirebaseAuth.instance.currentUser?.displayName ?? 'Doctor');
    final clinic = profile?.clinic ?? '';

    return Column(
      children: [
        Avatar(
          initials: initials,
          size: 90,
          photoUrl:
              profile?.photoUrl.isNotEmpty == true ? profile!.photoUrl : null,
        ),
        const SizedBox(height: 14),
        Text(
          'Dr. $name',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        if (clinic.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            clinic,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            _StatPill(
              icon: Icons.star_rounded,
              label:
                  '${profile?.rating.toStringAsFixed(1) ?? '5.0'} ${l10n.rating}',
            ),
            if (profile?.experience.isNotEmpty == true)
              _StatPill(
                icon: Icons.work_outline_rounded,
                label: profile!.experience,
              ),
            if (profile?.sex.isNotEmpty == true)
              _StatPill(
                icon: Icons.person_outline_rounded,
                label: profile!.sex,
              ),
            if (profile?.age.isNotEmpty == true)
              _StatPill(
                icon: Icons.cake_outlined,
                label: 'Age ${profile!.age}',
              ),
          ],
        ),
      ],
    );
  }

  String _initialsFromAuth() {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'D';
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Specialties card ──────────────────────────────────────────────────────────

class _SpecialtiesCard extends StatelessWidget {
  const _SpecialtiesCard({required this.specialties, required this.l10n});
  final List<String> specialties;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.specialties,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specialties
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withAlpha(60)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Info section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.profile, required this.l10n});
  final DoctorProfile? profile;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (FirebaseAuth.instance.currentUser?.email ?? '');

    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileDetails,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _Row(icon: Icons.email_outlined, label: l10n.email, value: email),
          if (profile?.phoneNumber.isNotEmpty == true)
            _Row(
                icon: Icons.phone_outlined,
                label: l10n.phone,
                value: profile!.phoneNumber),
          if (profile?.languages.isNotEmpty == true)
            _Row(
                icon: Icons.language_rounded,
                label: l10n.languages,
                value: profile!.languages),
          if (profile?.about.isNotEmpty == true) ...[
            const Divider(height: 24, color: AppColors.border),
            Text(
              l10n.about,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            Text(profile!.about,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
