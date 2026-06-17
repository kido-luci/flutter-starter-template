import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../widgets/splash_widgets.dart';

/// Bootstrap screen shown while the session is restored.
///
/// Restores the session — enforcing a minimum display time so it never
/// flashes — then hands control back to the host through [onRestored]. The
/// host owns the routing decision (advancing the deep-link gate and
/// navigating onward), keeping this feature free of app-level navigation
/// state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onRestored, super.key});

  /// Invoked once the session is restored and the minimum display time has
  /// elapsed, with the still-mounted screen [BuildContext].
  final void Function(BuildContext context) onRestored;

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
    widget.onRestored(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashContent();
  }
}
