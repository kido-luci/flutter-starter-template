import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../widgets/bookmark_form_widgets.dart';

class BookmarkFormScreen extends StatelessWidget {
  const BookmarkFormScreen({super.key, this.id});

  /// `null` for create, populated for edit.
  final String? id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookmarkFormBloc>()..add(BookmarkFormInitialized(id)),
      child: BookmarkFormView(isEditing: id != null),
    );
  }
}
