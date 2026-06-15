import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/models.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _date = 0;
  int _time = 0;
  bool _video = true;
  String _urgency = 'normal';

  late final List<DateTime> _dates;
  static const _times = ['8:00 AM', '9:30 AM', '11:00 AM', '2:00 PM', '3:30 PM', '5:00 PM'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i + 1)));
  }

  /// ISO date stored in Firestore — enables time-based call-window checks.
  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Human-readable label used only in the confirmation dialog.
  static String _fmtDate(DateTime d, AppL10n l10n) {
    return '${l10n.dayNames[d.weekday - 1]}, ${d.day} ${l10n.monthsFull[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppPage(
      title: l10n.bookAppointment,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          SoftCard(
            child: Row(
              children: [
                Avatar(initials: widget.doctor.initials, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.doctor.specialty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.chooseADate, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_dates.length, (index) {
                final selected = index == _date;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _date = index),
                    child: _DateOption(date: _dates[index], selected: selected),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.availableTimes,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(
              _times.length,
              (index) => ChoiceChip(
                label: Text(_times[index]),
                selected: index == _time,
                onSelected: (_) => setState(() => _time = index),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.consultationType,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ConsultationOption(
            icon: Icons.videocam_outlined,
            title: l10n.videoConsultation,
            detail: l10n.speakWithDoctorRemotely,
            selected: _video,
            onTap: () => setState(() => _video = true),
          ),
          const SizedBox(height: 10),
          _ConsultationOption(
            icon: Icons.local_hospital_outlined,
            title: l10n.clinicVisit,
            detail: widget.doctor.clinic,
            selected: !_video,
            onTap: () => setState(() => _video = false),
          ),
          const SizedBox(height: 24),
          Text(l10n.urgencyLevel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l10n.urgencyDesc,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          ..._urgencyOptions.map((opt) {
            final selected = _urgency == opt.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UrgencyOption(
                option: opt,
                selected: selected,
                onTap: () => setState(() => _urgency = opt.value),
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _confirm(context),
            child: Text(l10n.sendRequest),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final appointment = Appointment(
      id: '',
      doctor: widget.doctor,
      date: _isoDate(_dates[_date]),
      time: _times[_time],
      type: _video ? 'Video consultation' : 'Clinic visit',
      status: 'pending',
      urgency: _urgency,
    );
    try {
      await tryHealthRepository()?.createAppointment(appointment);
    } on Object {
      if (context.mounted) {
        showAppMessage(context, AppL10n.of(context).appointmentKeptForDemo);
      }
    }
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final ml10n = AppL10n.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F3EF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 31,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ml10n.requestSent,
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 7),
              Text(
                ml10n.requestSentMsg(
                  _fmtDate(_dates[_date], ml10n),
                  _times[_time],
                  widget.doctor.name,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(ctx);
                  },
                  child: Text(ml10n.done),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Urgency data ──────────────────────────────────────────────────────────────

class _UrgencyData {
  const _UrgencyData({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
}

const _urgencyOptions = [
  _UrgencyData(
    value: 'normal',
    label: 'Normal',
    description: 'Routine visit — no immediate concern.',
    icon: Icons.check_circle_outline_rounded,
    color: AppColors.primary,
  ),
  _UrgencyData(
    value: 'urgent',
    label: 'Urgent',
    description: 'Needs attention within the next day or two.',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFB76735),
  ),
  _UrgencyData(
    value: 'emergency',
    label: 'Emergency',
    description: 'Severe symptoms — requires immediate attention.',
    icon: Icons.emergency_rounded,
    color: Color(0xFFE25555),
  ),
];

class _UrgencyOption extends StatelessWidget {
  const _UrgencyOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _UrgencyData option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final label = option.value == 'urgent'
        ? l10n.urgencyUrgent
        : option.value == 'emergency'
            ? l10n.urgencyEmergency
            : l10n.urgencyNormal;
    final desc = option.value == 'urgent'
        ? l10n.urgencyUrgentDesc
        : option.value == 'emergency'
            ? l10n.urgencyEmergencyDesc
            : l10n.urgencyNormalDesc;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? option.color.withAlpha(18) : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? option.color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: option.color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: option.color)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: option.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateOption extends StatelessWidget {
  const _DateOption({required this.date, required this.selected});

  final DateTime date;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final dayLabel = l10n.dayNames[date.weekday - 1];
    final dayNum = date.day.toString().padLeft(2, '0');
    final monthLabel = l10n.monthsFull[date.month - 1];
    final mutedColor = selected ? const Color(0xFFBFE6E1) : const Color(0xFF849390);
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 11),
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
          const SizedBox(height: 3),
          Text(
            monthLabel,
            style: TextStyle(
              color: mutedColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationOption extends StatelessWidget {
  const _ConsultationOption({
    required this.icon,
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: SoftCard(
        color: selected ? const Color(0xFFEAF5F3) : Colors.white,
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
