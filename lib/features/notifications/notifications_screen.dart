import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.notificationsTitle,
      action: TextButton(
        onPressed: () async {
          final repo = tryHealthRepository();
          await repo?.markAllNotificationsRead();
          if (context.mounted) {
            showAppMessage(context, l10n.allNotificationsRead);
          }
        },
        child: Text(l10n.readAll),
      ),
      child: HealthStream<List<HealthNotification>>(
        stream: repository?.watchNotifications(),
        fallback: notifications,
        builder: (context, allNotifications) => allNotifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 56,
                        color: Color(0xFF91A19E),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noNotificationsYet,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.notificationsEmptyMsg,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF91A19E),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: allNotifications
                    .map((notification) => _NotificationTile(notification))
                    .toList(),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.notification);

  final HealthNotification notification;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: unread
            ? () => tryHealthRepository()
                ?.markNotificationRead(notification.id)
            : null,
        child: SoftCard(
          color: unread ? const Color(0xFFF1F8F7) : Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F0ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(notification.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          notification.time,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openNotifications(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()));
}
