import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_video_player_controls_bar.dart';

class AppVideoPlayerControlsOverlay extends StatelessWidget {
  const AppVideoPlayerControlsOverlay({
    super.key,
    required this.controller,
    required this.rawController,
    required this.isFullscreen,
    required this.isMuted,
    required this.playbackSpeed,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onSpeedSelected,
    required this.onFullscreenPressed,
  });

  final AppVideoPlayerController controller;
  final VideoPlayerController rawController;
  final bool isFullscreen;
  final bool isMuted;
  final double playbackSpeed;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onFullscreenPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          if (isFullscreen) const _FullscreenBackButton(),
          _CenterPlayButton(controller: controller, onPressed: onTogglePlay),
          AppVideoPlayerControlsBar(
            controller: controller,
            rawController: rawController,
            isFullscreen: isFullscreen,
            isMuted: isMuted,
            playbackSpeed: playbackSpeed,
            onTogglePlay: onTogglePlay,
            onToggleMute: onToggleMute,
            onSpeedSelected: onSpeedSelected,
            onFullscreenPressed: onFullscreenPressed,
          ),
        ],
      ),
    );
  }
}

class _FullscreenBackButton extends StatelessWidget {
  const _FullscreenBackButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: SafeArea(
        child: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _CenterPlayButton extends StatelessWidget {
  const _CenterPlayButton({
    required this.controller,
    required this.onPressed,
  });

  final AppVideoPlayerController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ExcludeSemantics(
        child:
            Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        controller.value.isPlaying
                            ? FontAwesomeIcons.pause
                            : FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                )
                .animate(target: controller.value.isPlaying ? 1 : 0)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 150.ms,
                )
                .fade(duration: 150.ms),
      ),
    );
  }
}
