import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../chat/chat_screen.dart';
import '../doctors/discover_screen.dart';
import '../notifications/notifications_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return PageFrame(
      child: HealthStream<List<PatientProfile>>(
        stream: repo?.watchDoctorPatients(),
        fallback: const [],
        builder: (context, patients) {
          final filtered = patients.where((p) {
            final q = _query.toLowerCase();
            return q.isEmpty ||
                p.fullName.toLowerCase().contains(q) ||
                p.email.toLowerCase().contains(q);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              PageTopBar(
                title: AppL10n.of(context).patients,
                onNotifications: () => openNotifications(context),
              ),
              const SizedBox(height: 16),
              SearchField(
                hint: AppL10n.of(context).searchPatients,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 20),
              Text(
                AppL10n.of(context).patientCount(filtered.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (patients.isEmpty)
                _EmptyPatients()
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(AppL10n.of(context).noMatchingPatients(_query),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted)),
                  ),
                )
              else
                ...filtered.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PatientTile(
                      patient: p,
                      repo: repo,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SoftCard(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.people_outline_rounded,
              size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(l10n.noPatientsYet,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            l10n.patientsEmptyMsg,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient, required this.repo});

  final PatientProfile patient;
  final HealthRepository? repo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PatientDetailScreen(patient: patient, repo: repo),
        ),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Avatar(initials: patient.initials, size: 48, pale: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(patient.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text(patient.patientCode,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF91A19E)),
          ],
        ),
      ),
    );
  }
}

// ── Patient detail (doctor's view) ────────────────────────────────────────────

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen(
      {super.key, required this.patient, required this.repo});

  final PatientProfile patient;
  final HealthRepository? repo;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patient.fullName),
          bottom: TabBar(
            tabs: [
              Tab(text: AppL10n.of(context).records),
              Tab(text: AppL10n.of(context).medications),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              tooltip: AppL10n.of(context).messagePatient,
              onPressed: () => _openChat(context),
            ),
            IconButton(
              icon: const Icon(Icons.note_add_outlined),
              tooltip: AppL10n.of(context).addConsultationNote,
              onPressed: () => _addNote(context),
            ),
            IconButton(
              icon: const Icon(Icons.medication_outlined),
              tooltip: AppL10n.of(context).prescribeMedication,
              onPressed: () => _prescribe(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _PatientInfoBanner(patient: patient),
            Expanded(
              child: TabBarView(
                children: [
                  _RecordsTab(patientId: patient.id, patientName: patient.fullName, repo: repo),
                  _MedicationsTab(patientId: patient.id, repo: repo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNote(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddNoteSheet(patient: patient, repo: repo),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final doctorProfile = await repo?.watchDoctorProfile().first;
    if (doctorProfile == null) return;
    final uid = repo?.currentUid ?? '';
    final conv = await repo?.getOrCreateConversation(
      patientId: patient.id,
      patientName: patient.fullName,
      doctorId: uid,
      doctorName: doctorProfile.fullName,
    );
    if (conv == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: conv.id,
          otherPersonName: patient.fullName,
          otherPersonInitials: patient.initials,
          senderName: doctorProfile.fullName,
        ),
      ),
    );
  }

  void _prescribe(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _PrescribeSheet(patient: patient, repo: repo),
    );
  }
}

class _PatientInfoBanner extends StatelessWidget {
  const _PatientInfoBanner({required this.patient});
  final PatientProfile patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Avatar(initials: patient.initials, size: 52, pale: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(patient.patientCode,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (patient.phoneNumber.isNotEmpty)
                  Text(patient.phoneNumber,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({required this.patientId, required this.repo, required this.patientName});
  final String patientId;
  final String patientName;
  final HealthRepository? repo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return StreamBuilder<RecordAccess?>(
      stream: repo?.watchRecordAccessForDoctor(patientId),
      builder: (context, accessSnap) {
        if (accessSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final access = accessSnap.data;

        if (access != null && access.isBlocked) {
          return _BlockedView(
            patientId: patientId,
            patientName: patientName,
            repo: repo,
            l10n: l10n,
          );
        }

        if (access != null && access.isRequested) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      size: 56, color: Color(0xFFD97706)),
                  const SizedBox(height: 16),
                  Text(l10n.accessRequestPending,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.accessRequested,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          );
        }

        return HealthStream<List<MedicalRecord>>(
          stream: repo?.watchPatientRecords(patientId),
          fallback: const [],
          builder: (context, records) {
            if (records.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.noRecordsForPatient),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = records[i];
                return SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEAF4F2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(r.icon,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            Text('${r.type} · ${r.date}',
                                style:
                                    Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BlockedView extends StatefulWidget {
  const _BlockedView({
    required this.patientId,
    required this.patientName,
    required this.repo,
    required this.l10n,
  });
  final String patientId;
  final String patientName;
  final HealthRepository? repo;
  final AppL10n l10n;

  @override
  State<_BlockedView> createState() => _BlockedViewState();
}

class _BlockedViewState extends State<_BlockedView> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 56, color: Color(0xFFDC2626)),
            const SizedBox(height: 16),
            Text(widget.l10n.accessBlocked,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(widget.l10n.recordsAccessBlocked,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _sending ? null : _requestAccess,
              icon: _sending
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(widget.l10n.requestAccess),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestAccess() async {
    setState(() => _sending = true);
    try {
      await widget.repo?.requestRecordAccess(
        patientId: widget.patientId,
        patientName: widget.patientName,
      );
      if (mounted) {
        showAppMessage(context, widget.l10n.accessRequestSent);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _MedicationsTab extends StatelessWidget {
  const _MedicationsTab({required this.patientId, required this.repo});
  final String patientId;
  final HealthRepository? repo;

  @override
  Widget build(BuildContext context) {
    return HealthStream<List<Medication>>(
      stream: repo?.watchPatientMedications(patientId),
      fallback: const [],
      builder: (context, meds) {
        if (meds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(AppL10n.of(context).noMedicationsOnRecord),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: meds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final m = meds[i];
            return SoftCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: m.color,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.medication_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        Text('${m.dosage} · ${m.schedule}',
                            style:
                                Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Add consultation note sheet ───────────────────────────────────────────────

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet({required this.patient, required this.repo});
  final PatientProfile patient;
  final HealthRepository? repo;

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  String _type = 'Consultation note';
  bool _busy = false;

  static const _types = [
    'Consultation note',
    'Laboratory results',
    'Radiology report',
    'Referral letter',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(AppL10n.of(context).addConsultationNote,
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          InputDecorator(
            decoration: InputDecoration(labelText: AppL10n.of(context).recordType),
            child: DropdownButton<String>(
              value: _type,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: AppL10n.of(context).titleLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryCtrl,
            maxLines: 3,
            decoration: InputDecoration(
                labelText: AppL10n.of(context).notesSummary,
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppL10n.of(context).saveNote),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showAppMessage(context, AppL10n.of(context).enterATitle);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = widget.repo;
      if (repo == null) throw Exception('Not connected');
      final profile = await _getDoctorProfile(repo);
      await repo.addPatientRecord(
        patientId: widget.patient.id,
        title: _titleCtrl.text.trim(),
        recordType: _type,
        summary: _summaryCtrl.text.trim().isNotEmpty
            ? _summaryCtrl.text.trim()
            : 'No additional notes.',
        providerName: profile,
      );
      if (mounted) {
        Navigator.pop(context);
        showAppMessage(context, AppL10n.of(context).noteSaved);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _getDoctorProfile(HealthRepository repo) async {
    final snap = await repo.watchDoctorProfile().first;
    return snap != null ? 'Dr. ${snap.fullName}' : 'Doctor';
  }
}

// ── Prescribe sheet ───────────────────────────────────────────────────────────

class _PrescribeSheet extends StatefulWidget {
  const _PrescribeSheet({required this.patient, required this.repo});
  final PatientProfile patient;
  final HealthRepository? repo;

  @override
  State<_PrescribeSheet> createState() => _PrescribeSheetState();
}

class _PrescribeSheetState extends State<_PrescribeSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  bool _busy = false;

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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(AppL10n.of(context).prescribeMedication,
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: AppL10n.of(context).medicationName,
                prefixIcon: const Icon(Icons.medication_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosageCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: AppL10n.of(context).dosage,
                prefixIcon: const Icon(Icons.format_list_numbered_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _scheduleCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: AppL10n.of(context).medicationScheduleHint,
                prefixIcon: const Icon(Icons.schedule_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _durationCtrl,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                labelText: AppL10n.of(context).medicationDuration,
                prefixIcon: const Icon(Icons.date_range_rounded)),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppL10n.of(context).sendPrescription),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _dosageCtrl.text.trim().isEmpty) {
      showAppMessage(context, AppL10n.of(context).enterMedNameAndDosage);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = widget.repo;
      if (repo == null) throw Exception('Not connected');
      final providerSnap = await repo.watchDoctorProfile().first;
      final providerName =
          providerSnap != null ? 'Dr. ${providerSnap.fullName}' : 'Doctor';
      await repo.addPatientPrescription(
        patientId: widget.patient.id,
        medication: Medication(
          id: '',
          name: _nameCtrl.text.trim(),
          dosage: _dosageCtrl.text.trim(),
          schedule: _scheduleCtrl.text.trim(),
          duration: _durationCtrl.text.trim(),
          color: const Color(0xFFE2F1EE),
        ),
        providerName: providerName,
      );
      if (mounted) {
        Navigator.pop(context);
        showAppMessage(
            context, '${AppL10n.of(context).prescriptionSentTo} ${widget.patient.fullName}');
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
