import 'package:ehealth/features/doctors/discover_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../notifications/notifications_screen.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return PageFrame(
      child: HealthStream<List<ChatConversation>>(
        stream: repo?.watchConversations(),
        fallback: const [],
        builder: (context, convs) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              PageTopBar(
                title: AppL10n.of(context).messages,
                onNotifications: () => openNotifications(context),
              ),
              const SizedBox(height: 20),
              if (convs.isEmpty)
                _EmptyState()
              else
                ...convs.map((conv) {
                  final isPatient = uid == conv.patientId;
                  final otherName =
                      isPatient ? conv.doctorName : conv.patientName;
                  final senderName =
                      isPatient ? conv.patientName : conv.doctorName;
                  final unread = conv.unreadFor(uid);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ConversationTile(
                      conversation: conv,
                      otherName: otherName,
                      senderName: senderName,
                      unread: unread,
                      currentUid: uid,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.otherName,
    required this.senderName,
    required this.unread,
    required this.currentUid,
  });

  final ChatConversation conversation;
  final String otherName;
  final String senderName;
  final int unread;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final isYou = conversation.lastSenderId == currentUid;
    final l10n = AppL10n.of(context);
    final String preview;
    if (conversation.lastMessage.isEmpty) {
      preview = l10n.noMessagesYet;
    } else if (isYou) {
      preview = '${l10n.youPrefix}: ${conversation.lastMessage}';
    } else {
      preview = conversation.lastMessage;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(
            chatId: conversation.id,
            otherPersonName: otherName,
            otherPersonInitials: _initials(otherName),
            senderName: senderName,
          ),
        ),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(initials: _initials(otherName), size: 50),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              unread > 0 ? FontWeight.w700 : null,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: unread > 0
                              ? AppColors.text
                              : AppColors.muted,
                          fontWeight:
                              unread > 0 ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (conversation.lastMessageTime != null)
              Text(
                _timeLabel(conversation.lastMessageTime!),
                style: TextStyle(
                  fontSize: 11,
                  color: unread > 0 ? AppColors.primary : AppColors.muted,
                  fontWeight:
                      unread > 0 ? FontWeight.w600 : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _timeLabel(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppL10n.of(context).noMessagesYet,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppL10n.of(context).visitDoctorProfile,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
