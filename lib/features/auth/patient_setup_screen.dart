import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';

class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  File? _pickedPhoto;
  String _photoUrl = '';
  bool _uploadingPhoto = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.yourProfile),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 1,
                minHeight: 5,
                backgroundColor: Color(0xFFE0EFED),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.almostDone,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(l10n.setUpYourProfile,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            l10n.addAFewDetails,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 28),

          // ── Profile photo ────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _uploadingPhoto ? null : _pickPhoto,
              child: Stack(
                children: [
                  _uploadingPhoto
                      ? Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2F1EE),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _pickedPhoto != null
                          ? ClipOval(
                              child: Image.file(
                                _pickedPhoto!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Avatar(
                              initials: _initialsOf(_nameCtrl.text),
                              size: 96,
                              photoUrl:
                                  _photoUrl.isNotEmpty ? _photoUrl : null,
                            ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.addProfilePhoto,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 26),

          // ── Name ────────────────────────────────────────────────────────
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),

          // ── Phone ────────────────────────────────────────────────────────
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              prefixIcon: const Icon(Icons.phone_outlined),
              hintText: '+237 6XX XXX XXX',
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.getStarted),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    setState(() {
      _pickedPhoto = file;
      _uploadingPhoto = true;
    });
    try {
      final repo = tryHealthRepository();
      if (repo != null) {
        final url = await repo.uploadPatientPhoto(file);
        if (mounted) setState(() => _photoUrl = url);
      }
    } on Object catch (e) {
      if (mounted) {
        showAppMessage(context, '${AppL10n.of(context).photoUploadFailed} $e');
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final l10n = AppL10n.of(context);
    if (name.length < 2) {
      showAppMessage(context, l10n.enterYourFullName);
      return;
    }
    if (phone.isEmpty) {
      showAppMessage(context, l10n.enterYourPhoneNumber);
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = tryHealthRepository();
      if (repo == null) return;
      await repo.updatePatientProfile(
        fullName: name,
        phoneNumber: phone,
        photoUrl: _photoUrl.isNotEmpty ? _photoUrl : null,
      );
      // _PatientRouter stream will detect phoneNumber is set and show AppShell
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
