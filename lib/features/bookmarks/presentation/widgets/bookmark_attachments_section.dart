import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../bloc/bookmark_form/bookmark_form_state.dart';
import 'bookmark_video_attachment_preview.dart';

/// Shows media previews and attachment actions for the bookmark form.
class BookmarkAttachmentsSection extends StatelessWidget {
  /// Creates a stateless attachments section backed by [state].
  const BookmarkAttachmentsSection({super.key, required this.state});

  /// Current bookmark form state that supplies image and video attachments.
  final BookmarkFormState state;

  @override
  Widget build(BuildContext context) {
    final videoUrl = state.videoUrl;
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.images,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'MEDIA',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (state.imageUrls.isNotEmpty) ...[
              _ImageAttachmentList(paths: state.imageUrls),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (videoUrl != null && videoUrl.isNotEmpty) ...[
              BookmarkVideoAttachmentPreview(videoUrl: videoUrl),
              const SizedBox(height: AppSpacing.lg),
            ],
            const _AttachmentActionButtons(),
          ],
        ),
      ),
    );
  }
}

class _ImageAttachmentList extends StatelessWidget {
  const _ImageAttachmentList({required this.paths});

  static const double _thumbnailSize = 100;

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final path = paths[index];
          return _ImageAttachmentTile(path: path);
        },
      ),
    );
  }
}

class _ImageAttachmentTile extends StatelessWidget {
  const _ImageAttachmentTile({required this.path});

  static const double _thumbnailSize = 100;

  final String path;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: path.startsWith('http')
              ? AppNetworkImage(
                  imageUrl: path,
                  fit: BoxFit.cover,
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                  semanticLabel: context.l10n.bookmarkAttachedImageLabel,
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                ),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: Semantics(
            button: true,
            label: context.l10n.bookmarkRemoveImageLabel,
            child: GestureDetector(
              onTap: () => context.read<BookmarkFormBloc>().add(
                BookmarkFormImageRemoved(path),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.xmark,
                  size: AppIconSize.sm,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentActionButtons extends StatelessWidget {
  const _AttachmentActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AttachmentActionButton(
                icon: FontAwesomeIcons.image,
                label: 'Gallery',
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormImagesPicked(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AttachmentActionButton(
                icon: FontAwesomeIcons.camera,
                label: 'Camera',
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormCameraImageTaken(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _AttachmentActionButton(
                icon: FontAwesomeIcons.video,
                label: 'Video',
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormVideoPicked(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AttachmentActionButton(
                icon: FontAwesomeIcons.video,
                label: 'Record',
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormCameraVideoTaken(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AttachmentActionButton extends StatelessWidget {
  const _AttachmentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final FaIconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerLow,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
