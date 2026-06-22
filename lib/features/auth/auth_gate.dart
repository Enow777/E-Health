import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/health_repository.dart';
import '../../data/models.dart';
import '../doctor/doctor_setup_screen.dart';
import '../doctor/doctor_shell.dart';
import '../onboarding/splash_screen.dart';
import '../shell/app_shell.dart';
import 'auth_screen.dart';
import 'patient_setup_screen.dart';
import 'role_selection_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.showIntro});

  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final alreadySignedIn = FirebaseAuth.instance.currentUser != null;
    if (showIntro && !alreadySignedIn) {
      return const SplashScreen(finishTarget: AuthGate(showIntro: false));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) return const AuthScreen();
        return const _RoleRouter();
      },
    );
  }
}

/// Reads the user's role from Firestore and routes to the correct shell.
class _RoleRouter extends StatelessWidget {
  const _RoleRouter();

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    if (repo == null) return const AppShell();

    return StreamBuilder<String?>(
      stream: repo.watchUserRole(),
      builder: (context, roleSnap) {
        if (roleSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = roleSnap.data;
        if (role == null) return const RoleSelectionScreen();
        if (role == 'doctor') return _DoctorRouter(repo: repo);
        return _PatientRouter(repo: repo);
      },
    );
  }
}

/// For patients: shows the one-time setup screen until phone number is set,
/// then shows the main app shell.
class _PatientRouter extends StatelessWidget {
  const _PatientRouter({required this.repo});
  final HealthRepository repo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientProfile>(
      stream: repo.watchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data;
        if (profile == null || profile.phoneNumber.isEmpty) {
          return const PatientSetupScreen();
        }
        return const AppShell();
      },
    );
  }
}

/// For doctors: shows setup screens until the profile is complete,
/// then routes based on hospital approval status.
class _DoctorRouter extends StatelessWidget {
  const _DoctorRouter({required this.repo});
  final HealthRepository repo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DoctorProfile?>(
      stream: repo.watchDoctorProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data;

        // Step 1: must complete profile setup first
        if (profile == null || !profile.setupComplete) {
          return const DoctorSetupScreen1(isFirstSetup: true);
        }

        // Step 2: choose hospital affiliation (or go independent)
        final status = profile.approvalStatus;
        if (status.isEmpty) {
          return _HospitalAffiliationScreen(repo: repo);
        }

        // Step 3a: waiting for hospital decision
        if (status == 'pending') {
          return _PendingApprovalScreen(
            repo: repo,
            hospitalName: profile.hospitalName,
          );
        }

        // Step 3b: rejected — let doctor try again or go independent
        if (status == 'rejected') {
          return _RejectedScreen(repo: repo, hospitalName: profile.hospitalName);
        }

        // Approved or independent → full doctor shell
        return const DoctorShell();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hospital Affiliation Screen
// ─────────────────────────────────────────────────────────────────────────────

class _HospitalAffiliationScreen extends StatefulWidget {
  const _HospitalAffiliationScreen({required this.repo});
  final HealthRepository repo;

  @override
  State<_HospitalAffiliationScreen> createState() =>
      _HospitalAffiliationScreenState();
}

class _HospitalAffiliationScreenState
    extends State<_HospitalAffiliationScreen> {
  List<Map<String, dynamic>> _hospitals = [];
  String? _selectedId;
  String? _selectedName;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final list = await widget.repo.fetchHospitals();
      if (mounted) setState(() { _hospitals = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest() async {
    if (_selectedId == null || _selectedName == null) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.setDoctorHospital(
        hospitalId: _selectedId!,
        hospitalName: _selectedName!,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }

  Future<void> _continueIndependently() async {
    setState(() => _submitting = true);
    try {
      await widget.repo.setIndependentDoctor();
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Icon(Icons.local_hospital_rounded,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Choose Your Hospital',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the hospital you work with. They will review and '
                'approve your account before you can receive appointments.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_hospitals.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No hospitals registered yet.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _hospitals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final h = _hospitals[index];
                      final id = h['id'] as String;
                      final name = h['name'] as String? ?? 'Unknown Hospital';
                      final address = h['address'] as String? ?? '';
                      final selected = _selectedId == id;
                      return InkWell(
                        onTap: _submitting
                            ? null
                            : () => setState(() {
                                  _selectedId = id;
                                  _selectedName = name;
                                }),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                : theme.colorScheme.surface,
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : const Color(0xFFE2E8F0),
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.local_hospital_outlined,
                                    color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    if (address.isNotEmpty)
                                      Text(address,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color:
                                                      const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: (_selectedId == null || _submitting)
                    ? null
                    : _sendRequest,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Request'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _submitting ? null : _continueIndependently,
                child: const Text('Continue Independently'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => FirebaseAuth.instance.signOut(),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B)),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending Approval Screen
// ─────────────────────────────────────────────────────────────────────────────

class _PendingApprovalScreen extends StatelessWidget {
  const _PendingApprovalScreen({
    required this.repo,
    required this.hospitalName,
  });
  final HealthRepository repo;
  final String hospitalName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 40, color: Color(0xFFD97706)),
              ),
              const SizedBox(height: 24),
              Text(
                'Awaiting Approval',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                hospitalName.isNotEmpty
                    ? 'Your request has been sent to $hospitalName. '
                        'You will be notified once they review your account.'
                    : 'Your account is pending hospital approval.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () async {
                  await repo.cancelHospitalRequest();
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Request'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B)),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rejected Screen
// ─────────────────────────────────────────────────────────────────────────────

class _RejectedScreen extends StatefulWidget {
  const _RejectedScreen({required this.repo, required this.hospitalName});
  final HealthRepository repo;
  final String hospitalName;

  @override
  State<_RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<_RejectedScreen> {
  bool _loading = false;

  Future<void> _tryAnother() async {
    setState(() => _loading = true);
    try {
      await widget.repo.cancelHospitalRequest();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goIndependent() async {
    setState(() => _loading = true);
    try {
      await widget.repo.setIndependentDoctor();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.cancel_outlined,
                    size: 40, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 24),
              Text(
                'Request Not Approved',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hospitalName.isNotEmpty
                    ? '${widget.hospitalName} did not approve your request. '
                        'You can try a different hospital or continue independently.'
                    : 'Your hospital request was not approved. '
                        'You can try a different hospital or continue independently.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _loading ? null : _tryAnother,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Try Another Hospital'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _goIndependent,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Continue Independently'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => FirebaseAuth.instance.signOut(),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B)),
                child: const Text('Sign out'),
              ),
              if (_loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
