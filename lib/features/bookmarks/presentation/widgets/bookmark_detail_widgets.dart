import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmark_detail/bookmark_detail_bloc.dart';
import '../bloc/bookmark_detail/bookmark_detail_state.dart';
import 'app_video_player.dart';
import 'bookmark_failure_messages.dart';

/// Provides a [BookmarkDetailBloc] for [id] and renders the detail embedded in
/// a side pane (no back button; delete/edit report back via callbacks instead
/// of popping a route).
class BookmarkDetailPane extends StatelessWidget {
  const BookmarkDetailPane({
    super.key,
    required this.id,
    this.onDeleted,
    this.onEdited,
  });

  final String id;

  /// Called after the bookmark is deleted, so the host can clear its selection.
  final VoidCallback? onDeleted;

  /// Called after an edit returns with changes, so the host can refresh.
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookmarkDetailBloc>()..add(BookmarkDetailLoadRequested(id)),
      child: BookmarkDetailView(
        id: id,
        embedded: true,
        onDeleted: onDeleted,
        onEdited: onEdited,
      ),
    );
  }
}

class BookmarkDetailView extends StatelessWidget {
  const BookmarkDetailView({
    super.key,
    required this.id,
    this.embedded = false,
    this.onDeleted,
    this.onEdited,
  });

  final String id;

  /// Whether the view is rendered inside a side pane rather than a full screen.
  final bool embedded;

  /// In embedded mode, called after the bookmark is deleted.
  final VoidCallback? onDeleted;

  /// In embedded mode, called after an edit returns with changes.
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookmarkDetailBloc, BookmarkDetailState>(
      listenWhen: (_, state) => state is BookmarkDetailDeleted,
      listener: (context, state) {
        if (embedded) {
          onDeleted?.call();
        } else {
          context.pop(true);
        }
      },
      child: AppScaffold(
        title: context.l10n.bookmarkAppBarTitle,
        padding: EdgeInsets.zero,
        actions: [
          BlocBuilder<BookmarkDetailBloc, BookmarkDetailState>(
            builder: (context, state) {
              if (state is! BookmarkDetailReady) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.commonShare,
                    icon: const FaIcon(FontAwesomeIcons.shareNodes),
                    onPressed: () => context.read<BookmarkDetailBloc>().add(
                      BookmarkDetailShareRequested(state.bookmark),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.commonEdit,
                    icon: const FaIcon(FontAwesomeIcons.pen),
                    onPressed: () => _openEditor(context),
                  ),
                  IconButton(
                    tooltip: context.l10n.commonDelete,
                    icon: const FaIcon(FontAwesomeIcons.trashCan),
                    onPressed: () => _confirmAndDelete(context, state.bookmark),
                  ),
                ],
              );
            },
          ),
        ],
        body: BlocBuilder<BookmarkDetailBloc, BookmarkDetailState>(
          builder: (context, state) {
            return switch (state) {
              BookmarkDetailLoading() => const AppLoading(),
              BookmarkDetailFailure(:final failure) => AppErrorView(
                message: bookmarkFailureMessage(context, failure),
                onRetry: () => context.read<BookmarkDetailBloc>().add(
                  BookmarkDetailLoadRequested(id),
                ),
              ),
              BookmarkDetailReady(:final bookmark) ||
              BookmarkDetailDeleting(:final bookmark) => _DetailBody(
                bookmark: bookmark,
              ),
              BookmarkDetailDeleted() => const AppLoading(),
            };
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final changed = await BookmarkEditRoute(id).push<bool>(context);
    if (changed == true && context.mounted) {
      context.read<BookmarkDetailBloc>().add(BookmarkDetailLoadRequested(id));
      onEdited?.call();
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, Bookmark b) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookmarkDeleteDialogTitle),
        content: Text(l10n.bookmarkDeleteDialogMessage(b.title)),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            label: l10n.commonDelete,
            variant: AppButtonVariant.tonal,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<BookmarkDetailBloc>().add(BookmarkDetailDeleteRequested(b.id));
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.bookmark});

  static const double _imageSize = 200;

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            bookmark.title,
            style: context.textTheme.headlineSmall,
          ).animateSlideDown(),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _openUrl(context, bookmark),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.link,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    bookmark.url,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ).animateFadeIn(delay: 100.ms),
          if (bookmark.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              bookmark.description,
              style: context.textTheme.bodyMedium,
            ).animateFadeIn(delay: 200.ms),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppLinkPreview(
            url: bookmark.url,
            maxWidth: double.infinity,
            enableAnimation: true,
          ).animateFadeIn(delay: 250.ms),
          if (bookmark.videoUrl != null && bookmark.videoUrl!.isNotEmpty)
            _VideoSection(
              videoUrl: bookmark.videoUrl!,
            ).animateFadeIn(delay: 275.ms),
          if (bookmark.imageUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: _imageSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bookmark.imageUrls.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final path = bookmark.imageUrls[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: path.startsWith('http')
                        ? AppNetworkImage(
                            imageUrl: path,
                            fit: BoxFit.cover,
                            width: _imageSize,
                            height: _imageSize,
                            semanticLabel: context.l10n.bookmarkImageLabel(
                              bookmark.title,
                            ),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            width: _imageSize,
                            height: _imageSize,
                          ),
                  );
                },
              ),
            ).animateFadeIn(delay: 300.ms),
          ],
          if (bookmark.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in bookmark.tags)
                  Chip(label: Text(tag))
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 300.ms)
                      .scale(duration: 300.ms, curve: Curves.easeOut),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: context.l10n.bookmarkOpenUrl,
            icon: FontAwesomeIcons.arrowUpRightFromSquare,
            expand: true,
            onPressed: () => _openUrl(context, bookmark),
          ).animateSlideUp(delay: 300.ms),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, Bookmark bookmark) async {
    final uri = Uri.tryParse(bookmark.url);
    if (uri == null) {
      _toast(context, context.l10n.bookmarkInvalidUrl);
      return;
    }
    context.read<BookmarkDetailBloc>().add(BookmarkDetailUrlOpened(bookmark));
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _toast(context, context.l10n.bookmarkCouldNotOpenUrl);
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VideoSection extends StatefulWidget {
  const _VideoSection({required this.videoUrl});

  final String videoUrl;

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  AppVideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    final service = context.read<VideoPlayerService>();
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      _videoPlayerController = service.network(uri);
    } else {
      _videoPlayerController = service.file(File(widget.videoUrl));
    }
    _videoPlayerController?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoPlayerController;
    if (controller == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.bookmarkAttachedVideo,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AppVideoPlayer(controller: controller),
        ),
      ],
    );
  }
}
