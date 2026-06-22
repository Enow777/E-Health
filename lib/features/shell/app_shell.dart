import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../data/health_repository.dart';
import '../../data/notification_service.dart';
import '../appointments/appointments_screen.dart';
import '../chat/chat_list_screen.dart';
import '../doctors/discover_screen.dart';
import '../home/home_screen.dart';
import '../medications/medications_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../records/records_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    DiscoverScreen(),
    AppointmentsScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    tryHealthRepository()?.seedDemoDoctors();
    if (!kIsWeb) {
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) tryHealthRepository()?.saveMessagingToken(token);
      });
    }
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
        setState(() => _index = 2);
      case 'chat':
        setState(() => _index = 3);
      case 'record':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RecordsScreen()),
        );
      case 'medication':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MedicationsScreen()),
        );
      default:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
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
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.manage_search_rounded),
            label: l10n.discover,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.bookings,
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
