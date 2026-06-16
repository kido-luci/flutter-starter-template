import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import 'app_video_player.dart';

class BookmarkVideoAttachmentPreview extends StatefulWidget {
  const BookmarkVideoAttachmentPreview({super.key, required this.videoUrl});

  static const double _previewHeight = 180;

  final String videoUrl;

  @override
  State<BookmarkVideoAttachmentPreview> createState() =>
      _BookmarkVideoAttachmentPreviewState();
}

class _BookmarkVideoAttachmentPreviewState
    extends State<BookmarkVideoAttachmentPreview> {
  AppVideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _load(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant BookmarkVideoAttachmentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _load(widget.videoUrl);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _load(String videoUrl) {
    _controller?.dispose();
    _controller = null;

    final service = context.read<VideoPlayerService>();
    final uri = Uri.tryParse(videoUrl);
    final controller =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https')
        ? service.network(uri)
        : service.file(File(videoUrl));

    _controller = controller;
    controller.initialize().then((_) {
      if (mounted && identical(_controller, controller)) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Video',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                height: BookmarkVideoAttachmentPreview._previewHeight,
                width: double.infinity,
                child: _controller != null
                    ? AppVideoPlayer(controller: _controller!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: GestureDetector(
                onTap: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormVideoRemoved(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.xmark,
                    size: AppIconSize.md,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
