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
/// then shows the main doctor shell.
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
        // Profile is "complete" only after the doctor finishes the setup wizard
        if (profile == null || !profile.setupComplete) {
          return const DoctorSetupScreen1(isFirstSetup: true);
        }
        return const DoctorShell();
      },
    );
  }
}
