import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selected;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: PageFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 32),
          children: [
            const BrandMark(),
            const SizedBox(height: 40),
            Text(
              l10n.howWillYouUse,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.chooseYourRole,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 36),
            _RoleCard(
              selected: _selected == 'patient',
              icon: Icons.person_outline_rounded,
              title: l10n.iAmPatient,
              subtitle: l10n.patientRoleDesc,
              accentColor: AppColors.primary,
              onTap: () => setState(() => _selected = 'patient'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              selected: _selected == 'doctor',
              icon: Icons.medical_services_outlined,
              title: l10n.iAmDoctor,
              subtitle: l10n.doctorRoleDesc,
              accentColor: const Color(0xFF1A5276),
              onTap: () => setState(() => _selected = 'doctor'),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: (_selected == null || _busy) ? null : _confirm,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.continueBtn),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final role = _selected;
    if (role == null) return;
    setState(() => _busy = true);
    try {
      final repo = tryHealthRepository();
      final user = FirebaseAuth.instance.currentUser;
      if (repo == null || user == null) return;

      await repo.setUserRole(role);

      if (role == 'patient') {
        await repo.createPatientProfile(
          fullName: user.displayName ?? '',
          email: user.email ?? '',
        );
      } else {
        await repo.createDoctorProfile(
          fullName: user.displayName ?? '',
          email: user.email ?? '',
        );
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Error: $e');
      setState(() => _busy = false);
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? accentColor.withAlpha(15) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? accentColor : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selected
                      ? accentColor.withAlpha(30)
                      : const Color(0xFFF0F5F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: selected ? accentColor : null,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected ? accentColor : AppColors.border,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
