import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/l10n/locale_notifier.dart';
import 'data/notification_service.dart';
import 'data/reminder_service.dart';

export 'app.dart';

/// Must be a top-level function. Called when an FCM message arrives while
/// the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  // Firebase is automatically initialized by FlutterFire in the background
  // isolate. For notification messages (not data-only), the OS shows the
  // system notification automatically — no action needed here.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedLocale();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    await NotificationService.instance.initialise();
    await ReminderService().configure();
    firebaseReady = true;
  } on Object {
    firebaseReady = false;
  }

  runApp(NkapHealthApp(useFirebase: firebaseReady));
}
