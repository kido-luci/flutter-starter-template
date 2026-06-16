import 'dart:async';

import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_video_player_controls.dart';
import 'app_video_player_fullscreen.dart';

/// A premium, highly customizable, and responsive video player widget.
///
/// Wraps [AppVideoPlayerController] and provides beautiful glassmorphic controls,
/// auto-hiding overlay HUD, speed adjustment, volume controls, buffering/error views,
/// and smooth animations.
class AppVideoPlayer extends StatefulWidget {
  /// Creates an instance of [AppVideoPlayer].
  const AppVideoPlayer({
    super.key,
    required this.controller,
    this.aspectRatio,
    this.isFullscreen = false,
  });

  /// The video controller interface.
  final AppVideoPlayerController controller;

  /// Optional override for the video aspect ratio.
  /// If not provided, the controller's initialized aspect ratio is used.
  final double? aspectRatio;

  /// Whether this player is currently rendering in fullscreen mode.
  final bool isFullscreen;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;
  double _playbackSpeed = 1;
  bool _isMuted = false;
  double _preMuteVolume = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.valueListenable.addListener(_onControllerValueChanged);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.valueListenable.removeListener(_onControllerValueChanged);
    super.dispose();
  }

  void _onControllerValueChanged() {
    if (mounted) {
      setState(() {
        _playbackSpeed = widget.controller.value.playbackSpeed;
        _isMuted = widget.controller.value.volume == 0.0;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _onTapPlayer() {
    _toggleControls();
  }

  Future<void> _togglePlay() async {
    _startHideTimer();
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
  }

  Future<void> _toggleMute() async {
    _startHideTimer();
    final currentVolume = widget.controller.value.volume;
    if (currentVolume > 0) {
      _preMuteVolume = currentVolume;
      await widget.controller.setVolume(0);
    } else {
      await widget.controller.setVolume(_preMuteVolume);
    }
  }

  void _setSpeed(double speed) {
    _startHideTimer();
    widget.controller.setPlaybackSpeed(speed);
  }

  void _enterFullscreen() {
    if (widget.isFullscreen) {
      Navigator.of(context).pop();
    } else {
      AppVideoPlayerFullScreenPage.show(context, widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.controller.rawController;
    if (raw == null) {
      // Return placeholder widget when controller is mocked or stubbed for testing.
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.video, color: Colors.white70, size: 48),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Mock Video Player View',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (!widget.controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: widget.controller.value.hasError
              ? _buildErrorView()
              : const CircularProgressIndicator(),
        ),
      );
    }

    final resolvedAspectRatio =
        widget.aspectRatio ?? widget.controller.value.aspectRatio;

    return AspectRatio(
      aspectRatio: resolvedAspectRatio,
      child: GestureDetector(
        onTap: _onTapPlayer,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Underlying Video View
            IgnorePointer(child: VideoPlayer(raw)),

            // Loading/Buffering Indicator
            if (widget.controller.value.isBuffering)
              const CircularProgressIndicator().animate().fade(
                duration: AppDurations.xfast,
              ),

            // Controls HUD Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: AppDurations.fast,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AppVideoPlayerControlsOverlay(
                  controller: widget.controller,
                  rawController: raw,
                  isFullscreen: widget.isFullscreen,
                  isMuted: _isMuted,
                  playbackSpeed: _playbackSpeed,
                  onTogglePlay: _togglePlay,
                  onToggleMute: _toggleMute,
                  onSpeedSelected: _setSpeed,
                  onFullscreenPressed: _enterFullscreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FaIcon(
          FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent,
          size: AppIconSize.xxxl,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.controller.value.errorDescription ?? 'Failed to load video',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
