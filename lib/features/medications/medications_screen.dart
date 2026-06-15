import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final repository = tryHealthRepository();
    return AppPage(
      title: l10n.medications,
      action: IconButton(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
      ),
      child: HealthStream<List<Medication>>(
        stream: repository?.watchMedications(),
        fallback: medications,
        builder: (context, allMedications) {
          final repo = tryHealthRepository();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              if (allMedications.isNotEmpty) ...[
                _NextDoseBanner(medications: allMedications),
                const SizedBox(height: 24),
              ],
              SectionHeading(title: AppL10n.of(context).activeMedication),
              const SizedBox(height: 12),
              if (allMedications.isEmpty)
                _EmptyMedications(onAdd: () => _showAddSheet(context))
              else ...[
                ...allMedications.map(
                  (medication) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _MedicationCard(
                      medication: medication,
                      onDelete: repo == null
                          ? null
                          : () => _confirmDelete(context, medication, repo),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SectionHeading(title: AppL10n.of(context).yourProgress),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.of(context).medicationAdherence,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppL10n.of(context).keepTakingMeds,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 13),
                      const LinearProgressIndicator(value: .86, minHeight: 7),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddMedicationSheet(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Medication medication,
    HealthRepository repo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return AlertDialog(
          title: Text(l10n.removeMedication),
          content: Text(l10n.removeMedicationConfirm(medication.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.remove),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await repo.deleteMedication(medication.id);
      if (context.mounted) {
        showAppMessage(context, '${medication.name} removed');
      }
    }
  }
}

class _NextDoseBanner extends StatelessWidget {
  const _NextDoseBanner({required this.medications});

  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final next = medications.first;
    final timeText = next.schedule.isNotEmpty ? next.schedule : l10n.asScheduled;
    return SoftCard(
      color: const Color(0xFFFFF8F1),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Color(0xFFB76735)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${l10n.nextDose} ${next.name} — $timeText',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMedications extends StatelessWidget {
  const _EmptyMedications({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.medication_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            AppL10n.of(context).noActiveMedications,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppL10n.of(context).addMedsPrompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppL10n.of(context).addMedication),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication, this.onDelete});

  final Medication medication;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: medication.color,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  medication.dosage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  medication.schedule,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppL10n.of(context).createReminder,
            onPressed: () => _createReminder(context),
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Remove',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<void> _createReminder(BuildContext context) async {
    final repository = tryHealthRepository();
    if (repository == null) {
      showAppMessage(context, 'Connect Firebase to create reminders');
      return;
    }
    await repository.createMedicationReminder(medication);
    if (context.mounted) {
      showAppMessage(context, '${AppL10n.of(context).reminderSavedFor} ${medication.name}');
    }
  }
}

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _scheduleCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l10n.addMedication,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.medicationName,
                prefixIcon: const Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.medicationName : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dosageCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.dosage,
                prefixIcon: const Icon(Icons.format_list_numbered_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.dosage : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _scheduleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.medicationScheduleHint,
                prefixIcon: const Icon(Icons.schedule_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.medicationScheduleHint : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationCtrl,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.medicationDuration,
                prefixIcon: const Icon(Icons.date_range_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.medicationDuration : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveMedication),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = tryHealthRepository();
    if (repo == null) {
      showAppMessage(context, 'Firebase not available');
      return;
    }
    setState(() => _busy = true);
    try {
      await repo.createMedication(
        Medication(
          id: '',
          name: _nameCtrl.text.trim(),
          dosage: _dosageCtrl.text.trim(),
          schedule: _scheduleCtrl.text.trim(),
          duration: _durationCtrl.text.trim(),
          color: const Color(0xFFE2F1EE),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        showAppMessage(context, AppL10n.of(context).medicationAdded);
      }
    } on Object {
      if (mounted) showAppMessage(context, AppL10n.of(context).saveMedication);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
