import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import '../shell/app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.finishTarget});

  final Widget? finishTarget;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _images = [
    'assets/images/onboarding-care.jpg',
    'assets/images/onboarding-telemedicine.jpg',
    'assets/images/onboarding-health.jpg',
  ];
  static const _alignments = [
    Alignment.center,
    Alignment.center,
    Alignment.centerRight,
  ];

  List<_OnboardingData> _pages(AppL10n l10n) => [
        _OnboardingData(
          image: _images[0],
          eyebrow: l10n.onb1Tag,
          title: l10n.onb1Title,
          body: l10n.onb1Desc,
          alignment: _alignments[0],
        ),
        _OnboardingData(
          image: _images[1],
          eyebrow: l10n.onb2Tag,
          title: l10n.onb2Title,
          body: l10n.onb2Desc,
          alignment: _alignments[1],
        ),
        _OnboardingData(
          image: _images[2],
          eyebrow: l10n.onb3Tag,
          title: l10n.onb3Title,
          body: l10n.onb3Desc,
          alignment: _alignments[2],
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final pages = _pages(l10n);
    final isLast = _index == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 10, 2),
              child: Row(
                children: [
                  const _CompactBrand(),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(l10n.skip)),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (_, index) => _OnboardingPage(data: pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: index == _index ? 22 : 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: index == _index
                              ? AppColors.primary
                              : const Color(0xFFD7E5E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLast ? _finish : _next,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: Text(isLast ? l10n.getStarted : l10n.continueBtn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.finishTarget ?? const AppShell(),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    data.image,
                    fit: BoxFit.cover,
                    alignment: data.alignment,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x290E2926)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            data.eyebrow,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(data.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            data.body,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 8),
        const Text(
          'nkap health',
          style: TextStyle(
            color: Color(0xFF173B37),
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.alignment,
  });

  final String image;
  final String eyebrow;
  final String title;
  final String body;
  final Alignment alignment;
}
