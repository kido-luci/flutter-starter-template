import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../collections/presentation/widgets/add_to_collection_sheet.dart';
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
        backgroundColor: _BookmarkDetailColors.background,
        actions: [
          BlocBuilder<BookmarkDetailBloc, BookmarkDetailState>(
            builder: (context, state) {
              if (state is! BookmarkDetailReady) return const SizedBox.shrink();
              final l10n = context.l10n;
              return PopupMenuButton<_DetailAction>(
                icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
                onSelected: (action) {
                  switch (action) {
                    case _DetailAction.share:
                      context.read<BookmarkDetailBloc>().add(
                        BookmarkDetailShareRequested(state.bookmark),
                      );
                    case _DetailAction.addToCollection:
                      AddToCollectionSheet.show(
                        context,
                        bookmarkId: state.bookmark.id,
                      );
                    case _DetailAction.edit:
                      _openEditor(context);
                    case _DetailAction.delete:
                      _confirmAndDelete(context, state.bookmark);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _DetailAction.share,
                    child: _MenuItem(
                      icon: FontAwesomeIcons.shareNodes,
                      label: l10n.commonShare,
                    ),
                  ),
                  PopupMenuItem(
                    value: _DetailAction.addToCollection,
                    child: _MenuItem(
                      icon: FontAwesomeIcons.layerGroup,
                      label: l10n.addToCollectionTitle,
                    ),
                  ),
                  PopupMenuItem(
                    value: _DetailAction.edit,
                    child: _MenuItem(
                      icon: FontAwesomeIcons.pen,
                      label: l10n.commonEdit,
                    ),
                  ),
                  PopupMenuItem(
                    value: _DetailAction.delete,
                    child: _MenuItem(
                      icon: FontAwesomeIcons.trashCan,
                      label: l10n.commonDelete,
                      color: context.colorScheme.error,
                    ),
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
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.bookmarkDeleteDialogTitle,
      message: l10n.bookmarkDeleteDialogBody,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    context.read<BookmarkDetailBloc>().add(BookmarkDetailDeleteRequested(b.id));
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.bookmark});

  final Bookmark bookmark;

  bool get _hasMedia => bookmark.imageUrls.isNotEmpty;
  bool get _hasVideo =>
      bookmark.videoUrl != null && bookmark.videoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            112,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppLinkPreview(
                url: bookmark.url,
                maxWidth: double.infinity,
                enableAnimation: true,
              ).animateFadeIn(),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                bookmark.title,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: _BookmarkDetailColors.text,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ).animateSlideDown(),
              if (bookmark.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  bookmark.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: _BookmarkDetailColors.mutedText,
                    letterSpacing: 0,
                  ),
                ).animateFadeIn(delay: 100.ms),
              ],
              const SizedBox(height: AppSpacing.xxl),
              _SourceSection(
                bookmark: bookmark,
              ).animateSlideLeft(delay: 150.ms),
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                _TagsSection(
                  tags: bookmark.tags,
                ).animateSlideLeft(delay: 200.ms),
              ],
              const SizedBox(height: AppSpacing.xxl),
              _DetailsSection(
                bookmark: bookmark,
              ).animateSlideLeft(delay: 250.ms),
              if (_hasMedia) ...[
                const SizedBox(height: AppSpacing.xxl),
                _MediaSection(
                  bookmark: bookmark,
                ).animateSlideLeft(delay: 300.ms),
              ],
              if (_hasVideo) ...[
                const SizedBox(height: AppSpacing.xxl),
                _VideoSection(
                  videoUrl: bookmark.videoUrl!,
                ).animateFadeIn(delay: 350.ms),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _OpenInBrowserBar(bookmark: bookmark),
        ),
      ],
    );
  }
}

/// "Source" card: shows the bookmark URL and a button to open it.
class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: FontAwesomeIcons.link,
            label: context.l10n.bookmarkSourceLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            bookmark.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: _BookmarkDetailColors.mutedText,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SubtleButton(
            label: context.l10n.bookmarkVisitWebsite,
            icon: FontAwesomeIcons.arrowUpRightFromSquare,
            onPressed: () => _openBookmarkUrl(context, bookmark),
          ),
        ],
      ),
    );
  }
}

/// "Tags" card: pill chips for each tag.
class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: FontAwesomeIcons.tag,
            label: context.l10n.bookmarkTagsLabel,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in tags)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _BookmarkDetailColors.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: _BookmarkDetailColors.surfaceHigh,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    child: Text(
                      tag,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _BookmarkDetailColors.secondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Details" card: created / last-modified dates and sync status.
class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final rows = <_DetailRow>[
      _DetailRow(
        label: context.l10n.bookmarkDateCreatedLabel,
        value: dateFormat.format(bookmark.createdAt),
      ),
      _DetailRow(
        label: context.l10n.bookmarkLastModifiedLabel,
        value: dateFormat.format(bookmark.updatedAt),
      ),
      if (bookmark.isPendingSync)
        _DetailRow(
          label: context.l10n.bookmarksNotYetSynced,
          value: '',
          valueIcon: FontAwesomeIcons.solidClock,
        ),
    ];

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: FontAwesomeIcons.circleInfo,
            label: context.l10n.bookmarkDetailsLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: _BookmarkDetailColors.surfaceHigh,
                        ),
                      ),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: _BookmarkDetailColors.mutedText,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (rows[i].valueIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: FaIcon(
                        rows[i].valueIcon,
                        size: 12,
                        color: _BookmarkDetailColors.mutedText,
                      ),
                    ),
                  if (rows[i].value.isNotEmpty)
                    Text(
                      rows[i].value,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _BookmarkDetailColors.text,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({required this.label, required this.value, this.valueIcon});

  final String label;
  final String value;
  final FaIconData? valueIcon;
}

/// "Media" card: a grid of attached image thumbnails.
class _MediaSection extends StatelessWidget {
  const _MediaSection({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: FontAwesomeIcons.images,
            label: context.l10n.bookmarkMediaLabel,
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookmark.imageUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final path = bookmark.imageUrls[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: path.startsWith('http')
                    ? AppNetworkImage(
                        imageUrl: path,
                        fit: BoxFit.cover,
                        semanticLabel: context.l10n.bookmarkImageLabel(
                          bookmark.title,
                        ),
                      )
                    : Image.file(File(path), fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom action bar with the primary "Open in Browser" button.
class _OpenInBrowserBar extends StatelessWidget {
  const _OpenInBrowserBar({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _BookmarkDetailColors.background.withValues(alpha: 0.94),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080A192F),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: AppButton(
            label: context.l10n.bookmarkOpenInBrowser,
            icon: FontAwesomeIcons.arrowUpRightFromSquare,
            size: AppButtonSize.large,
            expand: true,
            onPressed: () => _openBookmarkUrl(context, bookmark),
          ),
        ),
      ),
    );
  }
}

/// White surface card with the soft ambient shadow used across the detail view.
class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _BookmarkDetailColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0A192F),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}

/// Overflow-menu actions on the detail app bar.
enum _DetailAction { share, addToCollection, edit, delete }

/// A single row in the app-bar overflow menu: leading icon + label.
class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});

  final FaIconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colorScheme.onSurface;
    return Row(
      children: [
        FaIcon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Icon + title header shared by the detail cards.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final FaIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 16, color: _BookmarkDetailColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: _BookmarkDetailColors.text,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

/// Ghost-style button used inside cards (subtle fill, primary text).
class _SubtleButton extends StatelessWidget {
  const _SubtleButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final FaIconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _BookmarkDetailColors.surfaceLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: _BookmarkDetailColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FaIcon(icon, size: 14, color: _BookmarkDetailColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openBookmarkUrl(BuildContext context, Bookmark bookmark) async {
  final uri = Uri.tryParse(bookmark.url);
  if (uri == null || !uri.hasScheme) {
    _toast(context, context.l10n.bookmarkInvalidUrl);
    return;
  }
  final bloc = context.read<BookmarkDetailBloc>();
  bool launched;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object catch (_) {
    launched = false;
  }
  if (launched) {
    bloc.add(BookmarkDetailUrlOpened(bookmark));
  } else if (context.mounted) {
    _toast(context, context.l10n.bookmarkCouldNotOpenUrl);
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: FontAwesomeIcons.film,
            label: context.l10n.bookmarkAttachedVideo,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AppVideoPlayer(controller: controller),
          ),
        ],
      ),
    );
  }
}

abstract final class _BookmarkDetailColors {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2F4F6);
  static const surfaceHigh = Color(0xFFE0E3E5);
  static const primary = Color(0xFF0052FF);
  static const secondary = Color(0xFF515F78);
  static const text = Color(0xFF191C1E);
  static const mutedText = Color(0xFF434656);
}
