import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../doctors/discover_screen.dart';
import '../notifications/notifications_screen.dart';
import 'record_details_screen.dart';
import 'record_privacy_screen.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final repository = tryHealthRepository();
    return PageFrame(
      child: HealthStream<List<MedicalRecord>>(
        stream: repository?.watchRecords(),
        fallback: medicalRecords,
        builder: (context, records) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          if (showHeader) ...[
            PageTopBar(
              title: l10n.medicalRecords,
              onNotifications: () => openNotifications(context),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            l10n.recordsSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF657673)),
          ),
          const SizedBox(height: 21),
          SoftCard(
            color: const Color(0xFFE7F4F1),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF11645D)),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    l10n.recordsPrivacy,
                    style: const TextStyle(color: Color(0xFF315E59), fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RecordPrivacyScreen(),
                    ),
                  ),
                  child: Text(l10n.manage),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          FilledButton.icon(
            onPressed: () => _uploadRecord(context),
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(l10n.uploadMedicalDocument),
          ),
          const SizedBox(height: 20),
          SectionHeading(title: l10n.recentRecords, action: l10n.filter),
          const SizedBox(height: 12),
          if (records.isEmpty)
            SoftCard(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.folder_open_outlined,
                    size: 48,
                    color: Color(0xFF91A19E),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noRecordsYet,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.uploadFirstDocument,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF91A19E),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            )
          else
            ...records.map((record) => RecordTile(record: record)),
        ],
      ),
      ),
    );
  }

  Future<void> _uploadRecord(BuildContext context) async {
    final repository = tryHealthRepository();
    if (repository == null) {
      showAppMessage(context, 'Connect Firebase before uploading records');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return;

    if (!context.mounted) return;
    showAppMessage(context, 'Uploading ${file.name}...');
    try {
      await repository.uploadMedicalRecord(
        path: path,
        fileName: file.name,
        title: file.name,
        recordType: 'Uploaded document',
        provider: 'Patient upload',
      );
      if (context.mounted) showAppMessage(context, 'Record uploaded');
    } on Object catch (e) {
      if (context.mounted) {
        final message = _storageErrorMessage(e.toString());
        showAppMessage(context, message);
      }
    }
  }
}

String _storageErrorMessage(String error) {
  if (error.contains('unauthorized') || error.contains('permission-denied')) {
    return 'Upload denied — check Firebase Storage rules are deployed';
  }
  if (error.contains('no-bucket') || error.contains('no bucket')) {
    return 'Firebase Storage is not enabled — enable it in the Firebase Console';
  }
  if (error.contains('network') || error.contains('socket')) {
    return 'Upload failed — check your internet connection';
  }
  if (error.contains('canceled') || error.contains('cancelled')) {
    return 'Upload was cancelled';
  }
  return 'Upload failed: $error';
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppL10n.of(context).medicalRecords,
      child: const RecordsScreen(showHeader: false),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record});

  final MedicalRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RecordDetailsScreen(record: record),
          ),
        ),
        borderRadius: BorderRadius.circular(15),
        child: SoftCard(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  record.icon,
                  color: const Color(0xFF28645E),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.type} · ${record.date}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF91A19E)),
            ],
          ),
        ),
      ),
    );
  }
}
