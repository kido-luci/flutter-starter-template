import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/presentation/collection_visuals.dart';
import '../bloc/collection_form/collection_form_cubit.dart';
import '../bloc/collection_form/collection_form_state.dart';

/// Create or edit a collection. Pass [id] to edit an existing one.
class CollectionFormScreen extends StatelessWidget {
  const CollectionFormScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<CollectionFormCubit>();
        if (id != null) cubit.loadForEdit(id!);
        return cubit;
      },
      child: _CollectionFormView(isEditing: id != null),
    );
  }
}

class _CollectionFormView extends StatefulWidget {
  const _CollectionFormView({required this.isEditing});

  final bool isEditing;

  @override
  State<_CollectionFormView> createState() => _CollectionFormViewState();
}

class _CollectionFormViewState extends State<_CollectionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedIndex = 0;
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _hydrateFrom(CollectionFormState state) {
    if (_hydrated || state.initial == null) return;
    final initial = state.initial!;
    _nameController.text = initial.name;
    final index = collectionPalette.indexWhere((o) => o.token == initial.icon);
    if (index != -1) _selectedIndex = index;
    _hydrated = true;
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final option = collectionPalette[_selectedIndex];
    context.read<CollectionFormCubit>().submit(
      name: _nameController.text,
      icon: option.token,
      color: option.color.toARGB32(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollectionFormCubit, CollectionFormState>(
      listener: (context, state) {
        _hydrateFrom(state);
        if (state.saved) Navigator.of(context).pop();
        if (state.failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: widget.isEditing
              ? context.l10n.collectionsEditTitle
              : context.l10n.collectionsCreateTitle,
          isLoading: state.isLoading,
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppTextField(
                  controller: _nameController,
                  label: context.l10n.collectionNameLabel,
                  hint: context.l10n.collectionNameHint,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.l10n.collectionNameRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  context.l10n.collectionAppearanceLabel,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PalettePicker(
                  selectedIndex: _selectedIndex,
                  onSelected: (index) => setState(() => _selectedIndex = index),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: context.l10n.collectionSave,
                  icon: FontAwesomeIcons.check,
                  expand: true,
                  isLoading: state.isSubmitting,
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PalettePicker extends StatelessWidget {
  const _PalettePicker({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (index, option) in collectionPalette.indexed)
          Semantics(
            button: true,
            selected: index == selectedIndex,
            label: '${context.l10n.collectionAppearanceLabel} ${index + 1}',
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: collectionGradientFor(option.color.toARGB32()),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: index == selectedIndex
                      ? Border.all(
                          color: context.colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: FaIcon(option.icon, color: Colors.white, size: 22),
              ),
            ),
          ),
      ],
    );
  }
}
