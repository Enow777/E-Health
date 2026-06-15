import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _registering = true;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: PageFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 24),
          children: [
            const BrandMark(),
            const SizedBox(height: 38),
            Text(
              _registering ? l10n.createPatientAccount : l10n.welcomeBack,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_registering) ...[
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 3
                          ? l10n.enterYourFullName
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (value) =>
                        value != null && value.contains('@')
                        ? null
                        : l10n.enterValidEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (value) =>
                        value != null && value.length >= 6
                        ? null
                        : l10n.useAtLeast6Chars,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_registering ? l10n.createAccount : l10n.signIn),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _registering = !_registering),
              child: Text(
                _registering
                    ? l10n.alreadyHaveAccount
                    : l10n.createNewAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_registering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _name.text.trim(),
        );
        await HealthRepository().createPatientProfile(
          fullName: _name.text.trim(),
          email: FirebaseAuth.instance.currentUser?.email ?? '',
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await HealthRepository().ensurePatientProfile(
            fullName: user.displayName ?? '',
            email: user.email ?? '',
          );
        }
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) showAppMessage(context, error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
