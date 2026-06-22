import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../appointments/book_visit_screen.dart';
import '../appointments/video_consultation_screen.dart';
import '../doctors/doctor_cards.dart';
import '../doctors/discover_screen.dart';
import '../medications/medications_screen.dart';
import '../notifications/notifications_screen.dart';
import '../records/records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();
    final l10n = AppL10n.of(context);
    return PageFrame(
      child: HealthStream<PatientProfile>(
        stream: repository?.watchProfile(),
        fallback: demoProfile,
        builder: (context, profile) => HealthStream<List<Doctor>>(
          stream: repository?.watchDoctors(),
          fallback: doctors,
          builder: (context, allDoctors) => HealthStream<List<Appointment>>(
            stream: repository?.watchAppointments(),
            fallback: appointments,
            builder: (context, allAppointments) =>
                HealthStream<List<Medication>>(
              stream: repository?.watchMedications(),
              fallback: medications,
              builder: (context, allMedications) {
                final upcomingList = allAppointments
                    .where((a) =>
                        a.status == 'upcoming' || a.status == 'pending')
                    .toList();
                final nextAppointment =
                    upcomingList.isNotEmpty ? upcomingList.first : null;
                final nextMedication =
                    allMedications.isNotEmpty ? allMedications.first : null;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Row(
                      children: [
                        const BrandMark(),
                        const Spacer(),
                        IconButton(
                          onPressed: () => openNotifications(context),
                          icon: const Icon(Icons.notifications_none_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Avatar(initials: profile.initials, size: 42),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${_timeGreeting(l10n)}, ${profile.fullName.split(' ').first}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n.howAreYou,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF657673),
                          ),
                    ),
                    const SizedBox(height: 24),
                    _UpcomingAppointment(appointment: nextAppointment),
                    const SizedBox(height: 26),
                    SectionHeading(title: l10n.yourHealthServices),
                    const SizedBox(height: 13),
                    const _ServiceGrid(),
                    const SizedBox(height: 27),
                    SectionHeading(
                      title: l10n.nearbyDoctors,
                      action: l10n.seeAll,
                      onTap: () => _open(context, const FindDoctorPage()),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 191,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allDoctors.length.clamp(0, 5),
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, index) =>
                            DoctorPreviewCard(doctor: allDoctors[index]),
                      ),
                    ),
                    if (nextMedication != null) ...[
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MedicationsScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(17),
                        child: _MedicationReminder(medication: nextMedication),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _timeGreeting(AppL10n l10n) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return l10n.goodMorning;
  if (hour >= 12 && hour < 17) return l10n.goodAfternoon;
  return l10n.goodEvening;
}

class _UpcomingAppointment extends StatelessWidget {
  const _UpcomingAppointment({this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final appt = appointment;
    if (appt == null) return _buildEmpty(context, l10n);

    final isVideo = appt.type.contains('Video');
    final canJoin = isVideo && appt.callActive && appt.isInCallWindow;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.nextAppointmentLabel,
                style: const TextStyle(
                  color: Color(0xFFB8E7DF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                appt.type,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Avatar(initials: appt.doctor.initials, size: 46, pale: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      appt.doctor.specialty,
                      style: const TextStyle(
                          color: Color(0xFFC8E4E0), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFD6EFEC),
                size: 16,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${appt.formattedDate} · ${appt.time}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (canJoin)
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VideoConsultationScreen(
                          doctor: appt.doctor,
                          roomUrl: appt.videoRoomUrl),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  child: Text(l10n.joinCall),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppL10n l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nextAppointmentLabel,
            style: const TextStyle(
              color: Color(0xFFB8E7DF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.noUpcomingAppointments,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.bookConsultationPrompt,
            style: const TextStyle(color: Color(0xFFC8E4E0), fontSize: 13),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _open(context, const BookVisitScreen()),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
            ),
            child: Text(l10n.bookAVisit),
          ),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final services = <(String, IconData, Color, VoidCallback)>[
      (
        l10n.findADoctor,
        Icons.person_search_outlined,
        const Color(0xFFE2F3EF),
        () => _open(context, const FindDoctorPage()),
      ),
      (
        l10n.bookAVisit,
        Icons.calendar_month_outlined,
        const Color(0xFFFFF0E5),
        () => _open(context, const BookVisitScreen()),
      ),
      (
        l10n.myRecords,
        Icons.folder_copy_outlined,
        const Color(0xFFE8EEFA),
        () => _open(context, const RecordsPage()),
      ),
      (
        l10n.medications,
        Icons.medication_outlined,
        const Color(0xFFF2EAF8),
        () => _open(context, const MedicationsScreen()),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
      ),
      itemCount: services.length,
      itemBuilder: (_, index) {
        final service = services[index];
        return InkWell(
          key: ValueKey(
            'home-service-${service.$1.toLowerCase().replaceAll(' ', '-')}',
          ),
          onTap: service.$4,
          borderRadius: BorderRadius.circular(17),
          child: SoftCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: service.$3,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    service.$2,
                    color: const Color(0xFF28534E),
                    size: 21,
                  ),
                ),
                Text(
                  service.$1,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _MedicationReminder extends StatelessWidget {
  const _MedicationReminder({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheduleParts = medication.schedule.split(' - ');
    final timeLabel =
        scheduleParts.length > 1 ? scheduleParts.last : medication.schedule;

    return SoftCard(
      color: AppColors.warningBackground,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: medication.color,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFFB76735),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicationReminder,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '${medication.name} · ${medication.dosage}',
                  style: const TextStyle(
                      color: Color(0xFF806D61), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeLabel,
            style: const TextStyle(
              color: Color(0xFFB76735),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
