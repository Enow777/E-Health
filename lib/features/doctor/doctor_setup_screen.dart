import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _specialties = [
  'General Practice',
  'Paediatrics',
  'Cardiology',
  'Dermatology',
  'Neurology',
  'Orthopaedics',
  'Gynaecology & Obstetrics',
  'Psychiatry',
  'Oncology',
  'Endocrinology',
  'Gastroenterology',
  'Pulmonology',
  'Nephrology',
  'Ophthalmology',
  'ENT (Ear, Nose & Throat)',
  'Rheumatology',
  'Urology',
  'Emergency Medicine',
  'Radiology',
  'General Surgery',
  'Anaesthesiology',
  'Infectious Disease',
  'Haematology',
  'Geriatrics',
  'Sports Medicine',
];

const _experienceOptions = [
  '< 1 year',
  '1 year',
  '2 years',
  '3 years',
  '4 years',
  '5 years',
  '6–10 years',
  '11–15 years',
  '16–20 years',
  '20+ years',
];

const _sexOptions = ['Male', 'Female', 'Prefer not to say'];

// ── Screen 1 – Personal details ───────────────────────────────────────────────

class DoctorSetupScreen1 extends StatefulWidget {
  const DoctorSetupScreen1({super.key, this.isFirstSetup = false});

  final bool isFirstSetup;

  @override
  State<DoctorSetupScreen1> createState() => _DoctorSetupScreen1State();
}

class _DoctorSetupScreen1State extends State<DoctorSetupScreen1> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _sex = '';
  File? _pickedPhoto;
  String _existingPhotoUrl = '';
  bool _uploadingPhoto = false;
  bool _initialised = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isFirstSetup,
        title: Text(AppL10n.of(context).doctorProfileTitle),
        centerTitle: false,
      ),
      body: HealthStream<DoctorProfile?>(
        stream: repo?.watchDoctorProfile(),
        fallback: null,
        builder: (context, profile) {
          if (!_initialised && profile != null) {
            _nameCtrl.text = profile.fullName;
            _ageCtrl.text = profile.age;
            _phoneCtrl.text = profile.phoneNumber;
            _sex = profile.sex;
            _existingPhotoUrl = profile.photoUrl;
            _initialised = true;
          } else if (!_initialised) {
            final user = FirebaseAuth.instance.currentUser;
            _nameCtrl.text = user?.displayName ?? '';
            _initialised = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              _StepHeader(
                step: 1,
                title: AppL10n.of(context).personalDetails,
                subtitle: AppL10n.of(context).tellPatientsAboutYourself,
                isFirstSetup: widget.isFirstSetup,
              ),
              const SizedBox(height: 28),

              // ── Profile photo ──────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _uploadingPhoto ? null : _pickPhoto,
                  child: Stack(
                    children: [
                      _uploadingPhoto
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2F1EE),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _pickedPhoto != null
                              ? ClipOval(
                                  child: Image.file(
                                    _pickedPhoto!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Avatar(
                                  initials: _initialsOf(_nameCtrl.text),
                                  size: 100,
                                  photoUrl: _existingPhotoUrl.isNotEmpty
                                      ? _existingPhotoUrl
                                      : null,
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
                            border: Border.all(
                                color: Colors.white, width: 2),
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
                  AppL10n.of(context).tapToAddPhoto,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 24),

              // ── Name ──────────────────────────────────────────────────────
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),

              // ── Age ───────────────────────────────────────────────────────
              TextField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).age,
                  prefixIcon: const Icon(Icons.cake_outlined),
                  hintText: 'e.g. 35',
                ),
              ),
              const SizedBox(height: 14),

              // ── Sex ───────────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(AppL10n.of(context).sex,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.muted)),
                  ),
                  Wrap(
                    spacing: 10,
                    children: _sexOptions.map((s) {
                      final selected = _sex == s;
                      final l10n = AppL10n.of(context);
                      final displayLabel = s == 'Male'
                          ? l10n.male
                          : s == 'Female'
                              ? l10n.female
                              : l10n.preferNotToSay;
                      return ChoiceChip(
                        label: Text(displayLabel),
                        selected: selected,
                        onSelected: (_) => setState(() => _sex = s),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Phone ─────────────────────────────────────────────────────
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+237 6XX XXX XXX',
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _next,
                child: Text(AppL10n.of(context).nextProfessionalDetails),
              ),
            ],
          );
        },
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
        final url = await repo.uploadDoctorPhoto(file);
        if (mounted) setState(() => _existingPhotoUrl = url);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, '${AppL10n.of(context).photoUploadFailed} $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _next() {
    if (_nameCtrl.text.trim().length < 2) {
      showAppMessage(context, AppL10n.of(context).enterYourFullName);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorSetupScreen2(
          isFirstSetup: widget.isFirstSetup,
          name: _nameCtrl.text.trim(),
          age: _ageCtrl.text.trim(),
          sex: _sex,
          phone: _phoneCtrl.text.trim(),
          photoUrl: _existingPhotoUrl,
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Screen 2 – Professional details ──────────────────────────────────────────

class DoctorSetupScreen2 extends StatefulWidget {
  const DoctorSetupScreen2({
    super.key,
    required this.isFirstSetup,
    required this.name,
    required this.age,
    required this.sex,
    required this.phone,
    required this.photoUrl,
  });

  final bool isFirstSetup;
  final String name;
  final String age;
  final String sex;
  final String phone;
  final String photoUrl;

  @override
  State<DoctorSetupScreen2> createState() => _DoctorSetupScreen2State();
}

class _DoctorSetupScreen2State extends State<DoctorSetupScreen2> {
  final _clinicCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  String _experience = '';
  final Set<String> _selectedSpecialties = {};
  bool _saving = false;
  bool _initialised = false;

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _langCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.of(context).doctorProfileTitle),
        centerTitle: false,
      ),
      body: HealthStream<DoctorProfile?>(
        stream: repo?.watchDoctorProfile(),
        fallback: null,
        builder: (context, profile) {
          if (!_initialised && profile != null) {
            _clinicCtrl.text = profile.clinic;
            _langCtrl.text = profile.languages;
            _aboutCtrl.text = profile.about;
            _experience = profile.experience.isNotEmpty &&
                    _experienceOptions.contains(profile.experience)
                ? profile.experience
                : '';
            _selectedSpecialties
              ..clear()
              ..addAll(profile.specialties);
            _initialised = true;
          } else if (!_initialised) {
            _langCtrl.text = 'English';
            _initialised = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              _StepHeader(
                step: 2,
                title: AppL10n.of(context).professionalDetails,
                subtitle: AppL10n.of(context).helpPatientsFindRightDoctor,
                isFirstSetup: widget.isFirstSetup,
              ),
              const SizedBox(height: 24),

              // ── Clinic / Hospital ──────────────────────────────────────────
              TextField(
                controller: _clinicCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).hospitalClinic,
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  hintText: 'e.g. Central Hospital Yaoundé',
                ),
              ),
              const SizedBox(height: 14),

              // ── Experience ────────────────────────────────────────────────
              InputDecorator(
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).yearsOfExperience,
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
                child: DropdownButton<String>(
                  value: _experience.isNotEmpty ? _experience : null,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Text(AppL10n.of(context).select),
                  items: _experienceOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _experience = v ?? ''),
                ),
              ),
              const SizedBox(height: 22),

              // ── Specialties ───────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    AppL10n.of(context).medicalSpecialties,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    AppL10n.of(context).selectedOf5(_selectedSpecialties.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedSpecialties.isEmpty
                          ? const Color(0xFFE25555)
                          : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppL10n.of(context).select15Specialties,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialties.map((s) {
                  final isSelected = _selectedSpecialties.contains(s);
                  final atMax = _selectedSpecialties.length >= 5;
                  return FilterChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val && atMax && !isSelected) {
                        showAppMessage(
                            context, AppL10n.of(context).max5Specialties);
                        return;
                      }
                      setState(() {
                        if (val) {
                          _selectedSpecialties.add(s);
                        } else {
                          _selectedSpecialties.remove(s);
                        }
                      });
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // ── Languages ─────────────────────────────────────────────────
              TextField(
                controller: _langCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).languagesSpoken,
                  prefixIcon: const Icon(Icons.language_rounded),
                  hintText: 'e.g. English, French',
                ),
              ),
              const SizedBox(height: 14),

              // ── About ─────────────────────────────────────────────────────
              TextField(
                controller: _aboutCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppL10n.of(context).aboutBio,
                  hintText: AppL10n.of(context).describeApproach,
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.info_outline_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _saving ? null : () => _save(repo),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.isFirstSetup
                        ? AppL10n.of(context).completeSetup
                        : AppL10n.of(context).saveChanges),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save(HealthRepository? repo) async {
    if (_selectedSpecialties.isEmpty) {
      showAppMessage(context, AppL10n.of(context).selectAtLeastOneSpecialty);
      return;
    }
    if (_clinicCtrl.text.trim().isEmpty) {
      showAppMessage(context, AppL10n.of(context).enterHospitalName);
      return;
    }
    if (repo == null) return;
    setState(() => _saving = true);
    try {
      final existing = await repo.watchDoctorProfile().first;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final updated = DoctorProfile(
        id: existing?.id ?? uid,
        fullName: widget.name,
        email: existing?.email ??
            (FirebaseAuth.instance.currentUser?.email ?? ''),
        specialties: _selectedSpecialties.toList(),
        clinic: _clinicCtrl.text.trim(),
        phoneNumber: widget.phone,
        about: _aboutCtrl.text.trim(),
        languages: _langCtrl.text.trim(),
        experience: _experience,
        age: widget.age,
        sex: widget.sex,
        photoUrl: widget.photoUrl,
        rating: existing?.rating ?? 0.0,
        ratingCount: existing?.ratingCount ?? 0,
        nextAvailable: existing?.nextAvailable ?? 'Available today',
        isAvailable: existing?.isAvailable ?? true,
        setupComplete: true,
      );
      await repo.updateDoctorProfile(updated);
      if (!mounted) return;
      if (widget.isFirstSetup) {
        // Pop Screen2; _DoctorRouter now sees setupComplete:true and renders DoctorShell.
        Navigator.of(context).pop();
      } else {
        Navigator.of(context)
          ..pop()
          ..pop();
        showAppMessage(context, 'Profile updated');
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Shared header widget ──────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isFirstSetup,
  });

  final int step;
  final String title;
  final String subtitle;
  final bool isFirstSetup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: step / 2,
              minHeight: 5,
              backgroundColor: const Color(0xFFE0EFED),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppL10n.of(context).stepOf2(step),
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
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
