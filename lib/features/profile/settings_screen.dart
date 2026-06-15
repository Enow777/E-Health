import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';

// ── Generic settings screen (Help & About) ────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final rows = _rowsFor(title, l10n);
    return AppPage(
      title: _displayTitle(title, l10n),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          for (final row in rows)
            SoftCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  row.$1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: row.$2 == null
                    ? null
                    : Text(
                        row.$2!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF91A19E),
                ),
                onTap: () => showAppMessage(context, '${row.$1} opened'),
              ),
            ),
        ].expand((w) => [w, const SizedBox(height: 10)]).toList(),
      ),
    );
  }

  String _displayTitle(String key, AppL10n l10n) => switch (key) {
        'Help and support' => l10n.helpAndSupport,
        'About Nkap Health' => l10n.aboutNkapHealth,
        _ => key,
      };

  List<(String, String?)> _rowsFor(String title, AppL10n l10n) {
    return switch (title) {
      'Help and support' => [
          (l10n.faq, null),
          (l10n.contactSupport, l10n.replyWithinOneDay),
          (l10n.emergencyGuidance, l10n.forUrgentCare),
        ],
      _ => [
          ('Nkap Health', '${l10n.version} 1.0.0'),
          (l10n.privacyPolicy, null),
          (l10n.termsOfService, null),
        ],
    };
  }
}

// ── Privacy & Security screen ─────────────────────────────────────────────────

class PrivacyAndSecurityScreen extends StatelessWidget {
  const PrivacyAndSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.privacyAndSecurity,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _SecurityTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.appLock,
            subtitle: l10n.usePasscode,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AppLockScreen()),
            ),
          ),
          _SecurityTile(
            icon: Icons.folder_shared_outlined,
            title: l10n.recordAccess,
            subtitle: l10n.manageDoctorPermissions,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RecordAccessScreen()),
            ),
          ),
          _SecurityTile(
            icon: Icons.password_rounded,
            title: l10n.changePassword,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: const Color(0xFF466762)),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: subtitle != null
              ? Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)
              : null,
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF91A19E)),
          onTap: onTap,
        ),
      ),
    );
  }
}

// ── App Lock screen ───────────────────────────────────────────────────────────

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _enabled = prefs.getBool('app_lock_enabled') ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final enabled = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const _PinSetupSheet(),
      );
      if (enabled == true && mounted) setState(() => _enabled = true);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_lock_enabled', false);
      await prefs.remove('app_lock_pin');
      if (mounted) {
        setState(() => _enabled = false);
        showAppMessage(context, AppL10n.of(context).pinDisabled);
      }
    }
  }

  Future<void> _changePin() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _PinSetupSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    if (_loading) {
      return AppPage(
        title: l10n.appLock,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return AppPage(
      title: l10n.appLock,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          SoftCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.enableAppLock,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(l10n.appLockSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium),
              value: _enabled,
              onChanged: _toggle,
              activeThumbColor: AppColors.primary,
            ),
          ),
          if (_enabled) ...[
            const SizedBox(height: 12),
            SoftCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.pin_outlined, color: Color(0xFF466762)),
                title: Text(l10n.changePin,
                    style: Theme.of(context).textTheme.titleMedium),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF91A19E)),
                onTap: _changePin,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SoftCard(
            color: const Color(0xFFEAF4F2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: Color(0xFF11645D)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.appLockNote,
                    style: const TextStyle(
                        color: Color(0xFF315E59), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinSetupSheet extends StatefulWidget {
  const _PinSetupSheet();

  @override
  State<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<_PinSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pin1Ctrl = TextEditingController();
  final _pin2Ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _pin1Ctrl.dispose();
    _pin2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.createPin,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _pin1Ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.enterPin,
                prefixIcon: const Icon(Icons.pin_outlined),
              ),
              validator: (v) =>
                  (v == null || v.length < 4) ? l10n.pinTooShort : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _pin2Ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.confirmPinPrompt,
                prefixIcon: const Icon(Icons.pin_outlined),
              ),
              validator: (v) =>
                  v != _pin1Ctrl.text ? l10n.pinMismatch : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', true);
    await prefs.setString('app_lock_pin', _pin1Ctrl.text);
    if (mounted) {
      showAppMessage(context, AppL10n.of(context).pinSaved);
      Navigator.pop(context, true);
    }
  }
}

// ── Record Access screen ──────────────────────────────────────────────────────

class RecordAccessScreen extends StatelessWidget {
  const RecordAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final repository = tryHealthRepository();
    return AppPage(
      title: l10n.recordAccess,
      child: HealthStream<List<RecordShare>>(
        stream: repository?.watchRecordShares(),
        fallback: const [],
        builder: (context, shares) {
          if (shares.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_shared_outlined,
                      size: 56,
                      color: Color(0xFF91A19E),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noSharedRecords,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noSharedRecordsMsg,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF91A19E),
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                l10n.manageDoctorPermissions,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF657673),
                    ),
              ),
              const SizedBox(height: 16),
              ...shares.map(
                (share) => _RecordShareTile(
                  share: share,
                  onRevoke: repository == null
                      ? null
                      : () => _revoke(context, repository, share, l10n),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    HealthRepository repo,
    RecordShare share,
    AppL10n l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.revokeAccess),
        content:
            Text('${l10n.revokeConfirm} ${share.doctorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.revokeAccess),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.revokeRecordShare(share.id);
      if (context.mounted) showAppMessage(context, l10n.accessRevoked);
    }
  }
}

class _RecordShareTile extends StatelessWidget {
  const _RecordShareTile({required this.share, this.onRevoke});

  final RecordShare share;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF28645E),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    share.recordTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${l10n.sharedWith} ${share.doctorName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onRevoke != null)
              TextButton(
                onPressed: onRevoke,
                style:
                    TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.revokeAccess),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Change Password screen ────────────────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return AppPage(
        title: l10n.changePassword,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.signInToChangePassword,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return AppPage(
      title: l10n.changePassword,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _currentCtrl,
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(
                          () => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.currentPassword : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCtrl,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon:
                        const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? l10n.passwordTooShort : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.confirmNewPassword,
                    prefixIcon:
                        const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      v != _newCtrl.text ? l10n.passwordsDoNotMatch : null,
                  onFieldSubmitted: (_) => _submit(user, l10n),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _busy ? null : () => _submit(user, l10n),
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.changePassword),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(User user, AppL10n l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final email = user.email;
    if (email == null) return;
    setState(() => _busy = true);
    try {
      final cred = EmailAuthProvider.credential(
          email: email, password: _currentCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      if (mounted) {
        showAppMessage(context, l10n.passwordChanged);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg =
            (e.code == 'wrong-password' || e.code == 'invalid-credential')
                ? l10n.wrongCurrentPassword
                : (e.message ?? l10n.passwordTooShort);
        showAppMessage(context, msg);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ── Personal Info screen ──────────────────────────────────────────────────────

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _pickedPhoto;
  String _existingPhotoUrl = '';
  bool _uploadingPhoto = false;
  bool _saving = false;
  bool _initialised = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.personalInformation,
      child: HealthStream<PatientProfile>(
        stream: repository?.watchProfile(),
        fallback: demoProfile,
        builder: (context, profile) {
          if (!_initialised) {
            _nameController.text = profile.fullName;
            _phoneController.text = profile.phoneNumber;
            _existingPhotoUrl = profile.photoUrl;
            _initialised = true;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploadingPhoto
                      ? null
                      : () => _pickPhoto(repository),
                  child: Stack(
                    children: [
                      _uploadingPhoto
                          ? Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2F1EE),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            )
                          : _pickedPhoto != null
                              ? ClipOval(
                                  child: Image.file(
                                    _pickedPhoto!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Avatar(
                                  initials: profile.initials,
                                  size: 90,
                                  photoUrl:
                                      _existingPhotoUrl.isNotEmpty
                                          ? _existingPhotoUrl
                                          : null,
                                ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.tapToChangePhoto,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon:
                      const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: _InfoRow(
                    label: l10n.emailAddress, value: profile.email),
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: _InfoRow(
                    label: l10n.patientId,
                    value: profile.patientCode),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () => _save(context, repository),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.saveChanges),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickPhoto(HealthRepository? repository) async {
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
      if (repository != null) {
        final url = await repository.uploadPatientPhoto(file);
        if (mounted) setState(() => _existingPhotoUrl = url);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Photo upload failed: $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save(
      BuildContext context, HealthRepository? repository) async {
    final l10n = AppL10n.of(context);
    final name = _nameController.text.trim();
    if (name.length < 2) {
      showAppMessage(context, l10n.pleaseEnterYourFullName);
      return;
    }
    if (repository == null) {
      showAppMessage(context, l10n.profileSaved);
      return;
    }
    setState(() => _saving = true);
    try {
      await repository.updatePatientProfile(
        fullName: name,
        phoneNumber: _phoneController.text.trim(),
        photoUrl:
            _existingPhotoUrl.isNotEmpty ? _existingPhotoUrl : null,
      );
      if (context.mounted) showAppMessage(context, l10n.profileSaved);
    } on Object {
      if (context.mounted) {
        showAppMessage(context, 'Failed to update profile');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

// ── Navigation helper ─────────────────────────────────────────────────────────

void openSettings(BuildContext context, String title) {
  switch (title) {
    case 'Personal information':
      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => const PersonalInfoScreen()),
      );
    case 'Privacy and security':
      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => const PrivacyAndSecurityScreen()),
      );
    default:
      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => SettingsScreen(title: title)),
      );
  }
}
