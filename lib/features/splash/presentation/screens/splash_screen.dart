import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../../app/router.dart';
import '../widgets/splash_widgets.dart';

/// Bootstrap screen shown while the session is restored.
///
/// Owns the post-restore redirect: routes to `/` on success, `/login`
/// otherwise. Enforces a minimum display time so the splash never flashes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration _minDisplay = Duration(seconds: 2);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final session = SessionScope.of(context);
    await Future.wait<void>([
      session.restore(),
      Future<void>.delayed(SplashScreen._minDisplay),
    ]);
    if (!mounted) return;
    DeepLinkScope.of(context).splashCompleted = true;
    const HomeRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashContent();
  }
}
