import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.finishTarget});

  final Widget? finishTarget;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), _openOnboarding);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: OnboardingScreen(finishTarget: widget.finishTarget),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SplashBrand(),
              const Spacer(),
              Text(
                l10n.splashTagline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.3,
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: 270,
                child: Text(
                  l10n.splashSub,
                  style: const TextStyle(
                    color: Color(0xFFC6E3DF),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'NKAP HEALTH',
                style: TextStyle(
                  color: Color(0xFFA7D3CD),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'nkap health',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.65,
          ),
        ),
      ],
    );
  }
}
