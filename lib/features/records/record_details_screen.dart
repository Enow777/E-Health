import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';

class RecordDetailsScreen extends StatelessWidget {
  const RecordDetailsScreen({super.key, required this.record});

  final MedicalRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.recordDetails,
      action: IconButton(
        onPressed: () => _shareRecord(context),
        icon: const Icon(Icons.ios_share_outlined),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(record.icon, color: AppColors.primary, size: 29),
          ),
          const SizedBox(height: 16),
          Text(record.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(record.type, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 23),
          SoftCard(
            child: Column(
              children: [
                _RecordLine(label: l10n.date, value: record.date),
                const Divider(height: 22),
                _RecordLine(label: l10n.provider, value: record.provider),
                const Divider(height: 22),
                _RecordLine(label: l10n.access, value: l10n.privateLabel),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(l10n.summary, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(record.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 26),
          OutlinedButton.icon(
            onPressed: () => _openDocument(context),
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.viewDocument),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(BuildContext context) async {
    final url = record.fileUrl;
    if (url == null || url.isEmpty) {
      showAppMessage(context, 'This demo record has no attached file');
      return;
    }
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      showAppMessage(context, 'Unable to open document');
    }
  }

  void _shareRecord(BuildContext context) {
    final repository = tryHealthRepository();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => HealthStream<List<Doctor>>(
        stream: repository?.watchDoctors(),
        fallback: doctors,
        builder: (context, allDoctors) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              AppL10n.of(context).shareWithDoctor,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...allDoctors.map(
              (doctor) => ListTile(
                leading: Avatar(initials: doctor.initials, size: 42),
                title: Text(doctor.name),
                subtitle: Text(doctor.specialty),
                onTap: () async {
                  Navigator.pop(context);
                  if (repository == null) {
                    showAppMessage(context, 'Connect Firebase to share records');
                    return;
                  }
                  await repository.shareMedicalRecord(
                    record: record,
                    doctor: doctor,
                  );
                  if (context.mounted) {
                    showAppMessage(context, '${AppL10n.of(context).recordSharedWith} ${doctor.name}');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordLine extends StatelessWidget {
  const _RecordLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
