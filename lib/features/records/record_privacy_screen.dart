import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/models.dart';

class RecordPrivacyScreen extends StatelessWidget {
  const RecordPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final repo = tryHealthRepository();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordPrivacyTitle)),
      body: repo == null
          ? const Center(child: Text('Not connected'))
          : StreamBuilder<List<RecordAccess>>(
              stream: repo.watchMyRecordAccess(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final requests =
                    all.where((a) => a.isRequested).toList();
                final others =
                    all.where((a) => !a.isRequested).toList();

                if (all.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 56, color: AppColors.muted),
                          const SizedBox(height: 16),
                          Text(l10n.noDoctorAccess,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l10n.recordPrivacySubtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted)),
                    if (requests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(
                        icon: Icons.notifications_active_outlined,
                        color: const Color(0xFFD97706),
                        title: l10n.pendingAccessRequests,
                      ),
                      const SizedBox(height: 8),
                      ...requests.map((r) => _RequestTile(
                            access: r,
                            repo: repo,
                            l10n: l10n,
                          )),
                    ],
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(
                        icon: Icons.people_outline,
                        color: AppColors.primary,
                        title: l10n.doctorAccess,
                      ),
                      const SizedBox(height: 8),
                      ...others.map((a) => _AccessTile(
                            access: a,
                            repo: repo,
                            l10n: l10n,
                          )),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
  });
  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.access,
    required this.repo,
    required this.l10n,
  });
  final RecordAccess access;
  final HealthRepository repo;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.person_outline,
                      color: Color(0xFFD97706), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${access.doctorName}',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(l10n.wantsToViewRecords,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                    child: Text(l10n.rejectRequest),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _accept(context),
                    child: Text(l10n.acceptRequest),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    try {
      await repo.grantDoctorAccess(
        doctorId: access.doctorId,
        doctorName: access.doctorName,
      );
      if (context.mounted) {
        showAppMessage(context, l10n.accessUpdated(access.doctorName));
      }
    } on Object catch (e) {
      if (context.mounted) showAppMessage(context, 'Failed: $e');
    }
  }

  Future<void> _reject(BuildContext context) async {
    try {
      await repo.blockDoctorAccess(
        doctorId: access.doctorId,
        doctorName: access.doctorName,
      );
      if (context.mounted) {
        showAppMessage(context, l10n.accessUpdated(access.doctorName));
      }
    } on Object catch (e) {
      if (context.mounted) showAppMessage(context, 'Failed: $e');
    }
  }
}

class _AccessTile extends StatelessWidget {
  const _AccessTile({
    required this.access,
    required this.repo,
    required this.l10n,
  });
  final RecordAccess access;
  final HealthRepository repo;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final isGranted = access.isGranted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isGranted
                  ? const Color(0xFFEAF4F2)
                  : const Color(0xFFFEE2E2),
              child: Icon(
                Icons.person_outline,
                color: isGranted
                    ? AppColors.primary
                    : const Color(0xFFDC2626),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. ${access.doctorName}',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    isGranted ? l10n.accessGranted : l10n.accessBlocked,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isGranted
                              ? AppColors.primary
                              : const Color(0xFFDC2626),
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _toggle(context),
              child: Text(isGranted ? l10n.blockAccess : l10n.grantAccess),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context) async {
    try {
      if (access.isGranted) {
        await repo.blockDoctorAccess(
          doctorId: access.doctorId,
          doctorName: access.doctorName,
        );
      } else {
        await repo.grantDoctorAccess(
          doctorId: access.doctorId,
          doctorName: access.doctorName,
        );
      }
      if (context.mounted) {
        showAppMessage(context, l10n.accessUpdated(access.doctorName));
      }
    } on Object catch (e) {
      if (context.mounted) showAppMessage(context, 'Failed: $e');
    }
  }
}
