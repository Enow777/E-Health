import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../data/health_repository.dart';
import '../../data/notification_service.dart';
import '../chat/chat_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_home_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _index = 0;

  static const _screens = [
    DoctorHomeScreen(),
    DoctorAppointmentsScreen(),
    DoctorPatientsScreen(),
    ChatListScreen(),
    DoctorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) tryHealthRepository()?.saveMessagingToken(token);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationService.instance.attachNavigator(_handleNotificationTap);
      }
    });
  }

  @override
  void dispose() {
    NotificationService.instance.detachNavigator();
    super.dispose();
  }

  void _handleNotificationTap(String? category) {
    if (!mounted) return;
    switch (category) {
      case 'appointment':
        setState(() => _index = 1);
      case 'medication':
      case 'record':
        setState(() => _index = 2);
      case 'chat':
        setState(() => _index = 3);
      default:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NotificationsScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.schedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: l10n.patients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: l10n.messages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
