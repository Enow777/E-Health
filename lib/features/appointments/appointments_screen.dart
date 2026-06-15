import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../doctors/doctor_cards.dart';
import '../doctors/discover_screen.dart';
import '../notifications/notifications_screen.dart';
import 'video_consultation_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return PageFrame(
      child: HealthStream<List<Appointment>>(
        stream: repository?.watchAppointments(),
        fallback: appointments,
        builder: (context, allAppointments) {
          final upcoming = allAppointments
              .where((a) => a.status == 'upcoming' || a.status == 'pending')
              .toList();
          final past = allAppointments
              .where((a) =>
                  a.status == 'past' ||
                  a.status == 'completed' ||
                  a.status == 'cancelled')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              PageTopBar(
                title: l10n.appointmentsTitle,
                onNotifications: () => openNotifications(context),
              ),
              const SizedBox(height: 22),
              const _DateStrip(),
              const SizedBox(height: 27),
              SectionHeading(title: l10n.upcoming),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l10n.noUpcomingApptMsg,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ...upcoming.map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: AppointmentCard(
                    appointmentId: appointment.id,
                    doctor: appointment.doctor,
                    date: appointment.formattedDate,
                    time: appointment.time,
                    type: appointment.type,
                    status: appointment.status,
                    roomUrl: appointment.videoRoomUrl,
                    featured: appointment.status == 'upcoming' &&
                        appointment.type.contains('Video'),
                    callActive: appointment.callActive,
                    patientInCall: appointment.patientInCall,
                    callWindowOpen: appointment.isInCallWindow,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SectionHeading(title: l10n.pastConsultations),
              const SizedBox(height: 12),
              ...past.map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: AppointmentCard(
                    appointmentId: appointment.id,
                    doctor: appointment.doctor,
                    date: appointment.formattedDate,
                    time: appointment.time,
                    type: appointment.type,
                    past: true,
                    isRated: appointment.isRated,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    required this.type,
    this.appointmentId,
    this.status = 'upcoming',
    this.roomUrl = '',
    this.featured = false,
    this.past = false,
    this.isRated = false,
    this.callActive = false,
    this.patientInCall = false,
    this.callWindowOpen = false,
  });

  final Doctor doctor;
  final String date;
  final String time;
  final String type;
  final String? appointmentId;
  final String status;
  final String roomUrl;
  final bool featured;
  final bool past;
  final bool isRated;
  final bool callActive;
  final bool patientInCall;
  final bool callWindowOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => openDoctor(context, doctor),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Avatar(initials: doctor.initials, size: 47),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              doctor.specialty,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!past)
                IconButton(
                  onPressed: () => _showOptions(context),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF7B8D8A),
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: Color(0xFFE6EEEC)),
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Color(0xFF4E6A66),
              ),
              const SizedBox(width: 6),
              Text(
                '$date - $time',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (status == 'pending')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(l10n.pending,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB76735))),
                )
              else
                Text(
                  type,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 12),
                ),
            ],
          ),
          if (featured) ...[
            const SizedBox(height: 14),
            if (!callWindowOpen) ...[
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: Color(0xFF8A9E9B)),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.scheduledFor} $time',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A9E9B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.videocam_off_outlined, size: 18),
                  label: Text(l10n.notYetTime),
                ),
              ),
            ] else if (callActive) ...[
              Row(
                children: [
                  _PulseDot(),
                  const SizedBox(width: 6),
                  Text(
                    l10n.doctorIsLive,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                  ),
                  onPressed: () async {
                    final id = appointmentId;
                    if (id != null && id.isNotEmpty) {
                      await tryHealthRepository()?.setPatientInCall(id, true);
                    }
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VideoConsultationScreen(
                              doctor: doctor, roomUrl: roomUrl),
                        ),
                      );
                      if (id != null && id.isNotEmpty) {
                        await tryHealthRepository()
                            ?.setPatientInCall(id, false);
                      }
                    }
                  },
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: Text(l10n.joinNow),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBDBDBD),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.waitingForDoctor,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A9E9B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: Text(l10n.waitingForDoctorShort),
                ),
              ),
            ],
          ],
          if (past && !isRated && appointmentId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showRatingSheet(context),
                icon: const Icon(Icons.star_border_rounded, size: 18),
                label: Text(l10n.rateThisAppointment),
              ),
            ),
          ],
          if (past && isRated) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(l10n.youRatedThisAppointment,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _RatingSheet(
        doctor: doctor,
        appointmentId: appointmentId!,
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppL10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${l10n.appointmentWith} ${doctor.name}',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            Text(
              '$date · $time',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.event_busy_outlined,
                color: Color(0xFFE25555),
              ),
              title: Text(
                l10n.cancelAppointment,
                style: const TextStyle(color: Color(0xFFE25555)),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                final id = appointmentId;
                if (id == null || id.isEmpty) {
                  showAppMessage(
                      context, l10n.cannotCancelDemo);
                  return;
                }
                await tryHealthRepository()?.cancelAppointment(id);
                if (context.mounted) {
                  showAppMessage(context, l10n.appointmentCancelled);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rating sheet ──────────────────────────────────────────────────────────────

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.doctor, required this.appointmentId});
  final Doctor doctor;
  final String appointmentId;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.rateYourAppointment,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${l10n.withDoctor} ${widget.doctor.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _stars;
              return GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 40,
                    color: filled
                        ? const Color(0xFFF2A64A)
                        : AppColors.border,
                  ),
                ),
              );
            }),
          ),
          if (_stars > 0) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                _label(l10n, _stars),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.leaveComment,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_stars == 0 || _submitting) ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.submitRating),
          ),
        ],
      ),
    );
  }

  String _label(AppL10n l10n, int stars) => switch (stars) {
        1 => l10n.ratingPoor,
        2 => l10n.ratingFair,
        3 => l10n.ratingGood,
        4 => l10n.ratingVeryGood,
        _ => l10n.ratingExcellent,
      };

  Future<void> _submit() async {
    final l10n = AppL10n.of(context);
    setState(() => _submitting = true);
    try {
      final repo = tryHealthRepository();
      if (repo == null) return;
      await repo.addDoctorRating(
        doctorId: widget.doctor.id,
        appointmentId: widget.appointmentId,
        rating: _stars.toDouble(),
        comment: _commentCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        showAppMessage(context, l10n.ratingSubmitted);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, '${l10n.failedToSubmit} $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final today = DateTime.now();
    final days = List.generate(5, (i) => today.add(Duration(days: i)));
    final dayNames = l10n.dayNames;
    final months = l10n.monthsFull;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) {
        final selected = date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;
        final dayLabel = dayNames[date.weekday - 1];
        final dayNum = date.day.toString().padLeft(2, '0');
        final monthLabel = months[date.month - 1];
        final mutedColor = selected
            ? const Color(0xFFBFE6E1)
            : const Color(0xFF849390);
        return Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayNum,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF28433F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                monthLabel,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF2ECC71),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
