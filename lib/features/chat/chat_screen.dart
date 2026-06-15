import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherPersonName,
    required this.otherPersonInitials,
    required this.senderName,
  });

  final String chatId;
  final String otherPersonName;
  final String otherPersonInitials;
  final String senderName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _recorder = AudioRecorder();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _isSending = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(initials: widget.otherPersonInitials, size: 36),
            const SizedBox(width: 10),
            Text(
              widget.otherPersonName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: HealthStream<List<ChatMessage>>(
                stream: repo?.watchMessages(widget.chatId),
                fallback: const [],
                builder: (context, messages) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    repo?.markConversationRead(widget.chatId, _uid);
                    repo?.markMessagesRead(widget.chatId, _uid);
                    _scrollToBottom();
                  });
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        AppL10n.of(context).sayHelloTo(widget.otherPersonName),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[i];
                      final isMine = msg.senderId == _uid;
                      final showDate = i == 0 ||
                          !_sameDay(
                              messages[i - 1].createdAt, msg.createdAt);
                      return Column(
                        children: [
                          if (showDate) _DateLabel(date: msg.createdAt),
                          _MessageBubble(message: msg, isMine: isMine),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBar(repo),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(HealthRepository? repo) {
    if (_isRecording) {
      return _RecordingBar(
        seconds: _recordSeconds,
        onStop: () => _stopRecording(repo),
        onCancel: _cancelRecording,
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: AppL10n.of(context).messagePlaceholder,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: const Color(0xFFF7FAF9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isSending)
            const SizedBox(
              width: 44,
              height: 44,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleIconBtn(
                  icon: Icons.mic_outlined,
                  background: const Color(0xFFEAF4F2),
                  color: AppColors.primary,
                  onTap: _startRecording,
                ),
                const SizedBox(width: 6),
                _CircleIconBtn(
                  icon: Icons.send_rounded,
                  background: AppColors.primary,
                  color: Colors.white,
                  onTap: () => _sendText(repo),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _sendText(HealthRepository? repo) async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || repo == null) return;
    _textCtrl.clear();
    setState(() => _isSending = true);
    try {
      await repo.sendTextMessage(
        chatId: widget.chatId,
        senderId: _uid,
        senderName: widget.senderName,
        text: text,
      );
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    } on Object catch (e) {
      if (mounted) showAppMessage(context, '${AppL10n.of(context).failedToSend} $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        showAppMessage(context, AppL10n.of(context).micPermissionRequired);
      }
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _recordTimer =
          Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
    } on Object catch (e) {
      if (mounted) {
        showAppMessage(context, 'Could not start recording: $e');
      }
    }
  }

  Future<void> _stopRecording(HealthRepository? repo) async {
    _recordTimer?.cancel();
    final path = await _recorder.stop();
    final duration = _recordSeconds;
    setState(() => _isRecording = false);
    if (path == null || repo == null) return;
    setState(() => _isSending = true);
    try {
      final url = await repo.uploadVoiceNote(widget.chatId, path);
      try {
        File(path).deleteSync();
      } catch (_) {}
      await repo.sendVoiceMessage(
        chatId: widget.chatId,
        senderId: _uid,
        senderName: widget.senderName,
        voiceUrl: url,
        duration: duration,
      );
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    } on Object catch (e) {
      if (mounted) {
        showAppMessage(context, '${AppL10n.of(context).failedToSendVoice} $e');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Recording bar ─────────────────────────────────────────────────────────────

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.seconds,
    required this.onStop,
    required this.onCancel,
  });

  final int seconds;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  String get _timeStr {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const _PulseRecordDot(),
          const SizedBox(width: 10),
          Text(
            '${AppL10n.of(context).recording}  $_timeStr',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFE25555),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onCancel,
            child: Text(AppL10n.of(context).cancel,
                style: const TextStyle(color: AppColors.muted)),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: onStop,
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE25555)),
            icon: const Icon(Icons.stop_rounded, size: 16),
            label: Text(AppL10n.of(context).stop),
          ),
        ],
      ),
    );
  }
}

class _PulseRecordDot extends StatefulWidget {
  const _PulseRecordDot();

  @override
  State<_PulseRecordDot> createState() => _PulseRecordDotState();
}

class _PulseRecordDotState extends State<_PulseRecordDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFFE25555),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 6,
        left: isMine ? 60 : 0,
        right: isMine ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Avatar(
              initials: _initials(message.senderName),
              size: 28,
              pale: true,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: message.isVoice
                  ? const EdgeInsets.fromLTRB(12, 10, 12, 8)
                  : const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                border: isMine
                    ? null
                    : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isVoice)
                    _VoiceNotePlayer(
                      url: message.voiceUrl,
                      duration: message.duration,
                      isMine: isMine,
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isMine ? Colors.white : AppColors.text,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _timeLabel(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMine
                                ? Colors.white.withAlpha(160)
                                : AppColors.muted,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: message.isRead
                                ? const Color(0xFF4FC3F7)
                                : Colors.white.withAlpha(140),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  String _timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

// ── Voice note player ─────────────────────────────────────────────────────────

class _VoiceNotePlayer extends StatefulWidget {
  const _VoiceNotePlayer({
    required this.url,
    required this.duration,
    required this.isMine,
  });

  final String url;
  final int duration;
  final bool isMine;

  @override
  State<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<_VoiceNotePlayer> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  int _posSeconds = 0;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.duration;
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _posSeconds = pos.inSeconds);
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted && dur.inSeconds > 0) {
        setState(() => _totalSeconds = dur.inSeconds);
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _posSeconds = 0);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else if (_posSeconds > 0 && _posSeconds < _totalSeconds) {
      await _player.resume();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isMine ? Colors.white : AppColors.primary;
    final trackBg = widget.isMine
        ? Colors.white.withAlpha(50)
        : AppColors.border;
    final progress =
        _totalSeconds > 0 ? (_posSeconds / _totalSeconds).clamp(0.0, 1.0) : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.isMine
                  ? Colors.white.withAlpha(40)
                  : const Color(0xFFEAF4F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: accent,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: trackBg,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _totalSeconds > 0
                  ? '${_fmt(_posSeconds)} / ${_fmt(_totalSeconds)}'
                  : '${_fmt(_posSeconds)}',
              style: TextStyle(
                fontSize: 11,
                color: widget.isMine
                    ? Colors.white.withAlpha(180)
                    : AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Icon(Icons.mic_rounded, size: 14, color: accent.withAlpha(160)),
      ],
    );
  }
}

// ── Date label ────────────────────────────────────────────────────────────────

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final now = DateTime.now();
    final String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = l10n.today;
    } else {
      final months = l10n.monthsFull;
      label = '${date.day} ${months[date.month - 1]}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared circle icon button ─────────────────────────────────────────────────

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({
    required this.icon,
    required this.background,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration:
            BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
