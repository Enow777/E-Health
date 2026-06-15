import 'package:flutter/material.dart';

import 'core/l10n/app_l10n.dart';
import 'core/l10n/locale_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/shell/app_shell.dart';

class NkapHealthApp extends StatelessWidget {
  const NkapHealthApp({
    super.key,
    this.showIntro = true,
    this.useFirebase = false,
  });

  final bool showIntro;
  final bool useFirebase;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nkap Health',
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: useFirebase
            ? AuthGate(showIntro: showIntro)
            : (showIntro ? const SplashScreen() : const AppShell()),
      ),
    );
  }
}
