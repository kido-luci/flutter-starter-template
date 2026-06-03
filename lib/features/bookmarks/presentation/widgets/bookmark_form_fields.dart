import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';

class BookmarkFormFields extends StatelessWidget {
  const BookmarkFormFields({
    super.key,
    required this.titleController,
    required this.urlController,
    required this.descriptionController,
    required this.tagsController,
    required this.validateUrl,
  });

  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final String? Function(String?) validateUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UrlInput(
          controller: urlController,
          validateUrl: validateUrl,
        ).animateSlideLeft(),
        const SizedBox(height: AppSpacing.xxl),
        _BookmarkPreviewEditorCard(
          controller: titleController,
          descriptionController: descriptionController,
        ).animateSlideLeft(delay: 50.ms),
        const SizedBox(height: AppSpacing.xxl),
        _TagsPanel(controller: tagsController).animateSlideLeft(delay: 100.ms),
      ],
    );
  }
}

class _UrlInput extends StatelessWidget {
  const _UrlInput({required this.controller, required this.validateUrl});

  final TextEditingController controller;
  final String? Function(String?) validateUrl;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      validator: validateUrl,
      onChanged: (value) => context.read<BookmarkFormBloc>().add(
        BookmarkFormUrlChanged(value),
      ),
      decoration: InputDecoration(
        hintText: 'https://example.com',
        prefixIcon: const Center(
          widthFactor: 1,
          heightFactor: 1,
          child: FaIcon(FontAwesomeIcons.link, size: 20),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
              style: IconButton.styleFrom(
                backgroundColor: _BookmarkFieldColors.surfaceHigh,
                foregroundColor: _BookmarkFieldColors.mutedText,
                fixedSize: const Size(28, 28),
                minimumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                controller.clear();
                context.read<BookmarkFormBloc>().add(
                  const BookmarkFormUrlChanged(''),
                );
              },
            );
          },
        ),
        filled: true,
        fillColor: _BookmarkFieldColors.surfaceLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: _BookmarkFieldColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: context.colorScheme.error, width: 2),
        ),
      ),
    );
  }
}

class _BookmarkPreviewEditorCard extends StatelessWidget {
  const _BookmarkPreviewEditorCard({
    required this.controller,
    required this.descriptionController,
  });

  final TextEditingController controller;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _BookmarkFieldColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0A192F),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PreviewImagePlaceholder(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: controller,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.bookmarkTitleRequired
                        : null,
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormTitleChanged(value),
                    ),
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: _BookmarkFieldColors.text,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                    decoration: _borderlessDecoration(
                      hint: context.l10n.bookmarkTitleLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormDescriptionChanged(value),
                    ),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: _BookmarkFieldColors.mutedText,
                      letterSpacing: 0,
                    ),
                    decoration: _borderlessDecoration(
                      hint: context.l10n.bookmarkDescriptionLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _borderlessDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: false,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }
}

class _PreviewImagePlaceholder extends StatelessWidget {
  const _PreviewImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 4.5,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8ECEF),
              Color(0xFFD8E2E8),
              Color(0xFF9FB6BD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    child: FaIcon(
                      FontAwesomeIcons.bookmark,
                      size: 12,
                      color: _BookmarkFieldColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  context.l10n.bookmarkPreviewLabel,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagsPanel extends StatelessWidget {
  const _TagsPanel({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FieldPanel(
      icon: FontAwesomeIcons.tag,
      label: context.l10n.bookmarkTagsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final tags = value.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
              if (tags.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final tag in tags)
                      Chip(
                        label: Text(tag),
                        avatar: const FaIcon(FontAwesomeIcons.check, size: 12),
                        backgroundColor: const Color(0xFFD2E0FE),
                        side: BorderSide.none,
                        labelStyle: const TextStyle(
                          color: Color(0xFF55637D),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                        shape: const StadiumBorder(),
                      ),
                  ],
                ),
              );
            },
          ),
          AppTextField(
            controller: controller,
            hint: context.l10n.bookmarkTagsHint,
            onChanged: (value) => context.read<BookmarkFormBloc>().add(
              BookmarkFormTagsChanged(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldPanel extends StatelessWidget {
  const _FieldPanel({
    required this.icon,
    required this.label,
    required this.child,
  });

  final FaIconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _BookmarkFieldColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _BookmarkFieldColors.surfaceHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FaIcon(icon, size: 16, color: _BookmarkFieldColors.mutedText),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: _BookmarkFieldColors.mutedText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

abstract final class _BookmarkFieldColors {
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2F4F6);
  static const surfaceHigh = Color(0xFFE0E3E5);
  static const primary = Color(0xFF0052FF);
  static const text = Color(0xFF191C1E);
  static const mutedText = Color(0xFF434656);
}
