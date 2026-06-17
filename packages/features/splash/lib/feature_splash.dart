/// Splash feature: the bootstrap screen shown while the session is restored.
///
/// The host app mounts `SplashScreen` in its router, passing an `onRestored`
/// callback that advances the deep-link gate and navigates onward. The visual
/// `SplashContent` is exported for reuse and testing.
library;

export 'src/presentation/screens/splash_screen.dart';
export 'src/presentation/widgets/splash_widgets.dart';
