import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  // Pending category stored when notification tapped before AppShell mounts.
  String? _pendingCategory;
  void Function(String? category)? _onNavigate;

  static const _channelId = 'nkap_health';
  static const _channelName = 'Nkap Health';
  static const _channelDesc = 'Appointment, medication, and record alerts';

  Future<void> initialise() async {
    if (_ready) return;
    _ready = true;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleCategory(response.payload);
      },
    );

    // Create the Android notification channel required for Android 8.0+.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Request the POST_NOTIFICATIONS runtime permission on Android 13+.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Show a local notification when a push arrives while the app is open.
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null) return;
      show(
        title: n.title ?? 'Nkap Health',
        body: n.body ?? '',
        payload: message.data['category'] as String?,
      );
    });

    // Navigate when the user taps a notification that woke the app from background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleCategory(message.data['category'] as String?);
    });

    // Handle tap on a notification that launched the app from terminated state.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _pendingCategory = initial.data['category'] as String?;
    }
  }

  /// Called by AppShell once mounted so the service can trigger navigation.
  void attachNavigator(void Function(String? category) callback) {
    _onNavigate = callback;
    final pending = _pendingCategory;
    if (pending != null) {
      _pendingCategory = null;
      Future.microtask(() => callback(pending));
    }
  }

  void detachNavigator() => _onNavigate = null;

  void _handleCategory(String? category) {
    final callback = _onNavigate;
    if (callback != null) {
      callback(category);
    } else {
      _pendingCategory = category;
    }
  }

  /// Display a local notification immediately (used for foreground FCM messages).
  void show({
    required String title,
    required String body,
    String? payload,
  }) {
    _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
