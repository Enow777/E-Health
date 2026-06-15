import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/widgets/common.dart';
import '../../data/health_repository.dart';
import '../../data/health_stream.dart';
import '../../data/location_service.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../notifications/notifications_screen.dart';
import 'doctor_cards.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selected = 'All';
  String _query = '';
  String? _locationLabel;
  bool _locating = false;
  bool _showAllSpecialties = false;

  static const _allSpecialties = [
    'General Practice',
    'Paediatrics',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopaedics',
    'Gynaecology & Obstetrics',
    'Psychiatry',
    'Oncology',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Nephrology',
    'Ophthalmology',
    'ENT (Ear, Nose & Throat)',
    'Rheumatology',
    'Urology',
    'Emergency Medicine',
    'Radiology',
    'General Surgery',
    'Anaesthesiology',
    'Infectious Disease',
    'Haematology',
    'Geriatrics',
    'Sports Medicine',
  ];

  static const _initialSpecialtyCount = 7;

  @override
  Widget build(BuildContext context) {
    final repository = tryHealthRepository();

    if (_selected == 'Saved') {
      return HealthStream<List<Doctor>>(
        stream: repository?.watchSavedDoctors(),
        fallback: const [],
        builder: (context, savedDoctors) =>
            _buildBody(context, savedDoctors, savedOnly: true),
      );
    }

    return HealthStream<List<Doctor>>(
      stream: repository?.watchDoctors(),
      fallback: doctors,
      builder: (context, allDoctors) => _buildBody(context, allDoctors),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Doctor> doctorList, {
    bool savedOnly = false,
  }) {
    final l10n = AppL10n.of(context);
    final visibleDoctors = savedOnly
        ? doctorList.where((doctor) {
            final query = _query.toLowerCase();
            return query.isEmpty ||
                doctor.name.toLowerCase().contains(query) ||
                doctor.specialty.toLowerCase().contains(query) ||
                doctor.clinic.toLowerCase().contains(query);
          }).toList()
        : doctorList.where((doctor) {
            final query = _query.toLowerCase();
            final matchesQuery =
                doctor.name.toLowerCase().contains(query) ||
                doctor.specialty.toLowerCase().contains(query) ||
                doctor.clinic.toLowerCase().contains(query);
            return matchesQuery &&
                (_selected == 'All' ||
                    doctor.specialty == _selected);
          }).toList();

    return PageFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          if (widget.showHeader) ...[
            PageTopBar(
              title: l10n.findADoctor,
              onNotifications: () => openNotifications(context),
            ),
            const SizedBox(height: 22),
          ],
          SearchField(
            hint: l10n.doctorSpecialtyOrClinic,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (_selected != 'Saved')
            SoftCard(
              color: const Color(0xFFEAF5F3),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF11645D),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      _locationLabel ?? l10n.useLocationToImprove,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _locating ? null : _useLocation,
                    child: Text(_locating ? l10n.locating : l10n.use),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildSpecialtyChips(l10n),
            ),
          ),
          const SizedBox(height: 23),
          Text(
            savedOnly
                ? l10n.savedDoctorCount(visibleDoctors.length)
                : l10n.nearbyDoctorCount(visibleDoctors.length),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 13),
          if (visibleDoctors.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      savedOnly
                          ? Icons.bookmark_border_rounded
                          : Icons.search_off_rounded,
                      size: 48,
                      color: const Color(0xFF91A19E),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      savedOnly
                          ? l10n.noSavedDoctors
                          : l10n.noDoctorsFound,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF91A19E),
                          ),
                    ),
                    if (savedOnly) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.tapBookmarkToSave,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF91A19E),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ...visibleDoctors.map(
              (doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: DoctorListCard(doctor: doctor),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecialtyChips(AppL10n l10n) {
    final visible = _showAllSpecialties
        ? _allSpecialties
        : _allSpecialties.take(_initialSpecialtyCount).toList();

    Widget chip(String value, Widget label) => ChoiceChip(
          label: label,
          selected: value == _selected,
          onSelected: (_) => setState(() => _selected = value),
        );

    return [
      chip('All', Text(l10n.allFilter)),
      for (final s in visible) ...[
        const SizedBox(width: 8),
        chip(s, Text(s)),
      ],
      const SizedBox(width: 8),
      ActionChip(
        label: Text(_showAllSpecialties ? l10n.less : l10n.more),
        onPressed: () => setState(() {
          _showAllSpecialties = !_showAllSpecialties;
          if (!_showAllSpecialties &&
              _selected != 'All' &&
              _selected != 'Saved' &&
              !_allSpecialties.take(_initialSpecialtyCount).contains(_selected)) {
            _selected = 'All';
          }
        }),
      ),
      const SizedBox(width: 8),
      ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_rounded, size: 15),
            const SizedBox(width: 4),
            Text(l10n.savedLabel),
          ],
        ),
        selected: _selected == 'Saved',
        onSelected: (_) => setState(() => _selected = 'Saved'),
      ),
    ];
  }

  Future<void> _useLocation() async {
    setState(() => _locating = true);
    final l10n = AppL10n.of(context);
    try {
      final position = await LocationService().currentPosition();
      if (position == null) {
        if (mounted) setState(() => _locationLabel = l10n.locationPermissionRequired);
        return;
      }
      await tryHealthRepository()?.savePatientLocation(position);
      if (mounted) {
        setState(() => _locationLabel =
            '${l10n.locationActive} ${position.latitude.toStringAsFixed(3)}, '
            '${position.longitude.toStringAsFixed(3)}');
      }
    } on Object {
      if (mounted) setState(() => _locationLabel = 'Unable to read device location');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }
}

class FindDoctorPage extends StatelessWidget {
  const FindDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppL10n.of(context).findADoctor,
      child: const DiscoverScreen(showHeader: false),
    );
  }
}

class PageTopBar extends StatelessWidget {
  const PageTopBar({
    super.key,
    required this.title,
    required this.onNotifications,
  });

  final String title;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2ECE9)),
          ),
        ),
      ],
    );
  }
}
