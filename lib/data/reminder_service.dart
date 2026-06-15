import 'package:firebase_messaging/firebase_messaging.dart';

import 'health_repository.dart';

class ReminderService {
  ReminderService({FirebaseMessaging? messaging, HealthRepository? repository})
    : _messaging = messaging ?? FirebaseMessaging.instance,
      _repository = repository ?? tryHealthRepository();

  final FirebaseMessaging _messaging;
  final HealthRepository? _repository;

  Future<void> configure() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (token != null) {
      await _repository?.saveMessagingToken(token);
    }
  }
}
