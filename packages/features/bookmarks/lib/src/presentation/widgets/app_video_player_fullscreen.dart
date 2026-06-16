import 'package:app_platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_video_player.dart';

class AppVideoPlayerFullScreenPage extends StatefulWidget {
  const AppVideoPlayerFullScreenPage({super.key, required this.controller});

  final AppVideoPlayerController controller;

  static Future<void> show(
    BuildContext context,
    AppVideoPlayerController controller,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, _, _) =>
            AppVideoPlayerFullScreenPage(controller: controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<AppVideoPlayerFullScreenPage> createState() =>
      _AppVideoPlayerFullScreenPageState();
}

class _AppVideoPlayerFullScreenPageState
    extends State<AppVideoPlayerFullScreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AppVideoPlayer(
          controller: widget.controller,
          isFullscreen: true,
        ),
      ),
    );
  }
}
