import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../bloc/bookmark_form/bookmark_form_state.dart';
import 'bookmark_attachments_section.dart';
import 'bookmark_failure_messages.dart';
import 'bookmark_form_fields.dart';

class BookmarkFormView extends StatefulWidget {
  const BookmarkFormView({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<BookmarkFormView> createState() => _BookmarkFormViewState();
}

class _BookmarkFormViewState extends State<BookmarkFormView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _hydrateFromState(BookmarkFormState state) {
    if (_hydrated) return;
    _title.text = state.title;
    _url.text = state.url;
    _description.text = state.description;
    _tags.text = state.tags.join(', ');
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      safeArea: false,
      backgroundColor: _BookmarkFormColors.background,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<BookmarkFormBloc, BookmarkFormState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == BookmarkFormStatus.submitted) {
            context.pop(true);
          }
          if (state.status == BookmarkFormStatus.idle &&
              state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bookmarkFailureMessage(context, state.failure!)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookmarkFormStatus.loading) {
            return const AppLoading();
          }
          if (state.status == BookmarkFormStatus.loadFailed) {
            return AppErrorView(
              message: state.failure == null
                  ? context.l10n.bookmarkFormLoadFailed
                  : bookmarkFailureMessage(context, state.failure!),
            );
          }
          _hydrateFromState(state);
          final isSubmitting = state.status == BookmarkFormStatus.submitting;
          return Form(
            key: _formKey,
            child: Stack(
              children: [
                CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _BookmarkTaskHeader(
                        title: widget.isEditing
                            ? context.l10n.bookmarkFormEditTitle
                            : context.l10n.bookmarkFormNewTitle,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        128,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BookmarkFormFields(
                              titleController: _title,
                              urlController: _url,
                              descriptionController: _description,
                              tagsController: _tags,
                              validateUrl: (value) =>
                                  _validateUrl(context, value),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            BookmarkAttachmentsSection(
                              state: state,
                            ).animateSlideLeft(delay: 175.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _StickySubmitBar(
                    isEditing: widget.isEditing,
                    isSubmitting: isSubmitting,
                    onSubmit: () {
                      if (_formKey.currentState?.validate() != true) return;
                      context.read<BookmarkFormBloc>().add(
                        const BookmarkFormSubmitted(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _validateUrl(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.bookmarkUrlRequired;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) {
      return context.l10n.bookmarkUrlInvalid;
    }
    return null;
  }
}

class _BookmarkTaskHeader extends StatelessWidget {
  const _BookmarkTaskHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark),
                  color: _BookmarkFormColors.mutedText,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: _BookmarkFormColors.text,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySubmitBar extends StatelessWidget {
  const _StickySubmitBar({
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isEditing;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _BookmarkFormColors.background.withValues(alpha: 0.94),
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
            label: isEditing
                ? context.l10n.commonSave
                : context.l10n.commonCreate,
            icon: FontAwesomeIcons.bookmark,
            size: AppButtonSize.large,
            isLoading: isSubmitting,
            expand: true,
            onPressed: onSubmit,
          ).animateSlideUp(delay: 200.ms),
        ),
      ),
    );
  }
}

abstract final class _BookmarkFormColors {
  static const background = Color(0xFFF7F9FB);
  static const text = Color(0xFF191C1E);
  static const mutedText = Color(0xFF434656);
}
