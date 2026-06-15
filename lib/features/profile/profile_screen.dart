import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../doctors/discover_screen.dart';
import '../notifications/notifications_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();
    final l10n = AppL10n.of(context);
    final currentLang = localeNotifier.value.languageCode;
    return PageFrame(
      child: HealthStream<PatientProfile>(
        stream: repository?.watchProfile(),
        fallback: demoProfile,
        builder: (context, profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            PageTopBar(
              title: l10n.profileTitle,
              onNotifications: () => openNotifications(context),
            ),
            const SizedBox(height: 24),
            Center(
              child: Avatar(
                initials: profile.initials,
                size: 78,
                photoUrl: profile.photoUrl.isNotEmpty ? profile.photoUrl : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                profile.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${l10n.patientId} - ${profile.patientCode}',
                style: const TextStyle(
                  color: Color(0xFF748481),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 27),
            ProfileTile(
              icon: Icons.person_outline_rounded,
              title: l10n.personalInformation,
              onTap: () => openSettings(context, 'Personal information'),
            ),
            ProfileTile(
              icon: Icons.lock_outline_rounded,
              title: l10n.privacyAndSecurity,
              onTap: () => openSettings(context, 'Privacy and security'),
            ),
            ProfileTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              value: currentLang == 'fr' ? l10n.french : l10n.english,
              onTap: () => _showLanguagePicker(context, l10n),
            ),
            ProfileTile(
              icon: Icons.help_outline_rounded,
              title: l10n.helpAndSupport,
              onTap: () => openSettings(context, 'Help and support'),
            ),
            ProfileTile(
              icon: Icons.info_outline_rounded,
              title: l10n.aboutNkapHealth,
              onTap: () => openSettings(context, 'About Nkap Health'),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () async {
                if (FirebaseAuth.instance.currentUser == null) {
                  showAppMessage(context, l10n.signedOut);
                  return;
                }
                await FirebaseAuth.instance.signOut();
              },
              child: Text(l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppL10n l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _LanguagePickerSheet(),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final current = localeNotifier.value.languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _LangTile(
            label: l10n.english,
            code: 'en',
            selected: current == 'en',
          ),
          const SizedBox(height: 8),
          _LangTile(
            label: l10n.french,
            code: 'fr',
            selected: current == 'fr',
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.label,
    required this.code,
    required this.selected,
  });

  final String label;
  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2B6B63))
          : const Icon(Icons.circle_outlined, color: Color(0xFFCFDAD8)),
      onTap: () async {
        Navigator.pop(context);
        await setLocale(code);
      },
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      leading: Icon(icon, color: const Color(0xFF466762)),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF91A19E)),
        ],
      ),
    );
  }
}
