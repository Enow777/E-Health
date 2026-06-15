import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  bool _isAvailable = true;
  late List<_DayConfig> _days;
  String _filter = 'All Week';
  int? _expandedIndex;
  bool _saving = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _days = _buildDefaultDays();
  }

  List<_DayConfig> _buildDefaultDays() => [
        _DayConfig(key: 'monday', label: 'Monday', short: 'MON'),
        _DayConfig(key: 'tuesday', label: 'Tuesday', short: 'TUE'),
        _DayConfig(key: 'wednesday', label: 'Wednesday', short: 'WED'),
        _DayConfig(key: 'thursday', label: 'Thursday', short: 'THU'),
        _DayConfig(key: 'friday', label: 'Friday', short: 'FRI'),
        _DayConfig(key: 'saturday', label: 'Saturday', short: 'SAT'),
        _DayConfig(key: 'sunday', label: 'Sunday', short: 'SUN'),
      ];

  void _loadProfile(DoctorProfile profile) {
    if (_initialised) return;
    _isAvailable = profile.isAvailable;
    final schedule = profile.weeklySchedule;
    for (final day in _days) {
      if (schedule.containsKey(day.key)) {
        final entry = Map<String, dynamic>.from(schedule[day.key] as Map);
        day.enabled = entry['enabled'] as bool? ?? true;
        day.from = entry['from'] as String? ?? '08:00';
        day.to = entry['to'] as String? ?? '18:00';
      }
    }
    _initialised = true;
  }

  Future<void> _save(HealthRepository repo) async {
    setState(() => _saving = true);
    try {
      final map = <String, dynamic>{
        for (final d in _days) d.key: d.toMap(),
      };
      await repo.updateDoctorSchedule(
          weeklySchedule: map, isAvailable: _isAvailable);
      if (mounted) {
        Navigator.pop(context);
        showAppMessage(context, AppL10n.of(context).scheduleSaved);
      }
    } on Object catch (e) {
      if (mounted) showAppMessage(context, 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = tryHealthRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.of(context).mySchedule),
        centerTitle: false,
      ),
      body: HealthStream<DoctorProfile?>(
        stream: repo?.watchDoctorProfile(),
        fallback: null,
        builder: (context, profile) {
          final l10n = AppL10n.of(context);
          if (profile != null) _loadProfile(profile);
          final filtered = _filter == 'Weekdays'
              ? _days
                  .where((d) => !{'saturday', 'sunday'}.contains(d.key))
                  .toList()
              : _days;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _SummaryBar(days: _days),
                    const SizedBox(height: 20),

                    // ── Global availability ──────────────────────────────────
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.event_available_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.acceptingAppointments,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.turnOffToPause,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _isAvailable,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withAlpha(80),
                            onChanged: (v) => setState(() => _isAvailable = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Section header ───────────────────────────────────────
                    Text(l10n.weeklySchedule,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      l10n.setWorkingHours,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),

                    // ── Filter chips ─────────────────────────────────────────
                    Row(
                      children: ['All Week', 'Weekdays'].map((f) {
                        final active = _filter == f;
                        final label = f == 'Weekdays' ? l10n.weekdays : l10n.allWeek;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _filter = f;
                              _expandedIndex = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      active ? Colors.white : AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // ── Day cards ────────────────────────────────────────────
                    ...filtered.asMap().entries.map((e) {
                      final i = e.key;
                      final day = e.value;
                      final expanded = _expandedIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DayCard(
                          day: day,
                          isExpanded: expanded,
                          onTap: () => setState(() =>
                              _expandedIndex = expanded ? null : i),
                          onToggle: (v) => setState(() => day.enabled = v),
                          onFromChanged: (t) =>
                              setState(() => day.from = t),
                          onToChanged: (t) => setState(() => day.to = t),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),

                    // ── Tip ──────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withAlpha(30)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.scheduleNote,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pinned save button ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: (_saving || repo == null)
                      ? null
                      : () => _save(repo),
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(l10n.saveSchedule),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.days});
  final List<_DayConfig> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final active = days.where((d) => d.enabled).toList();
    const keyToIdx = {'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3, 'friday': 4, 'saturday': 5, 'sunday': 6};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(35)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF4ADE80), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              active.isEmpty
                  ? l10n.noActiveDays
                  : active.map((d) => l10n.dayNames[keyToIdx[d.key]!]).join(' · '),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.calendar_month_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            l10n.daysCount(active.length),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Day card ──────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.onTap,
    required this.onToggle,
    required this.onFromChanged,
    required this.onToChanged,
  });

  final _DayConfig day;
  final bool isExpanded;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withAlpha(80)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Day badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: day.enabled
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          AppL10n.of(context).dayNames[const {'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3, 'friday': 4, 'saturday': 5, 'sunday': 6}[day.key]!],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: day.enabled
                                ? Colors.white
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppL10n.of(context).dayNamesLong[const {'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3, 'friday': 4, 'saturday': 5, 'sunday': 6}[day.key]!],
                            style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          if (!isExpanded)
                            Text(
                              day.enabled
                                  ? '${day.from}  →  ${day.to}'
                                  : AppL10n.of(context).unavailable,
                              style: TextStyle(
                                fontSize: 12,
                                color: day.enabled
                                    ? AppColors.muted
                                    : const Color(0xFFE25555),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: day.enabled,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withAlpha(80),
                      onChanged: onToggle,
                    ),
                  ],
                ),
                if (isExpanded && day.enabled) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _TimePicker(
                          label: AppL10n.of(context).from,
                          time: day.from,
                          onPicked: onFromChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimePicker(
                          label: AppL10n.of(context).to,
                          time: day.to,
                          onPicked: onToChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Time picker ───────────────────────────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onPicked,
  });

  final String label;
  final String time;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final parts = time.split(':');
            final initial = TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
            final picked =
                await showTimePicker(context: context, initialTime: initial);
            if (picked != null) {
              onPicked(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
              );
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Day config (mutable state) ────────────────────────────────────────────────

class _DayConfig {
  _DayConfig({
    required this.key,
    required this.label,
    required this.short,
  });

  final String key;
  final String label;
  final String short;
  bool enabled = true;
  String from = '08:00';
  String to = '18:00';

  Map<String, dynamic> toMap() => {'enabled': enabled, 'from': from, 'to': to};
}
