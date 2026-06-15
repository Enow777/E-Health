import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import 'book_appointment_screen.dart';

class BookVisitScreen extends StatelessWidget {
  const BookVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final repository = tryHealthRepository();
    return AppPage(
      title: l10n.bookAVisitTitle,
      child: HealthStream<List<Doctor>>(
        stream: repository?.watchDoctors(),
        fallback: doctors,
        builder: (context, allDoctors) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              AppL10n.of(context).chooseCareYouNeed,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 7),
            Text(
              AppL10n.of(context).selectDoctorPrompt,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SearchField(hint: AppL10n.of(context).searchDoctorsOrSpecialties),
            const SizedBox(height: 24),
            SectionHeading(title: AppL10n.of(context).availableDoctors),
            const SizedBox(height: 12),
            ...allDoctors.map(
              (doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _BookingDoctorCard(doctor: doctor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDoctorCard extends StatelessWidget {
  const _BookingDoctorCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Avatar(initials: doctor.initials, size: 51),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 5),
                    Text(
                      doctor.nextAvailable,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookAppointmentScreen(doctor: doctor),
                ),
              ),
              child: Text(AppL10n.of(context).viewAvailableTimes),
            ),
          ),
        ],
      ),
    );
  }
}
