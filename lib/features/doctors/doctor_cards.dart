import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import 'doctor_details_screen.dart';

class DoctorPreviewCard extends StatelessWidget {
  const DoctorPreviewCard({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openDoctor(context, doctor),
      borderRadius: BorderRadius.circular(17),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 134,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Avatar(initials: doctor.initials, size: 44),
                  const Spacer(),
                  Icon(
                    doctor.hasRatings
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFF2A64A),
                    size: 15,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    doctor.hasRatings ? '${doctor.rating}' : AppL10n.of(context).newLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                doctor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF758683), fontSize: 12),
              ),
              const Spacer(),
              Text(
                AppL10n.of(context).distanceAway(doctor.distance),
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorListCard extends StatelessWidget {
  const DoctorListCard({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openDoctor(context, doctor),
      borderRadius: BorderRadius.circular(17),
      child: SoftCard(
        child: Row(
          children: [
            Avatar(initials: doctor.initials, size: 52),
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
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6C827E),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        doctor.distance,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        doctor.hasRatings
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFF2A64A),
                        size: 15,
                      ),
                      Text(
                        doctor.hasRatings ? ' ${doctor.rating}' : ' ${AppL10n.of(context).newLabel}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF91A19E)),
          ],
        ),
      ),
    );
  }
}

void openDoctor(BuildContext context, Doctor doctor) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DoctorDetailsScreen(doctor: doctor),
    ),
  );
}
