import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/bookmark_detail/bookmark_detail_bloc.dart';
import '../widgets/bookmark_detail_widgets.dart';

class BookmarkDetailScreen extends StatelessWidget {
  const BookmarkDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookmarkDetailBloc>()..add(BookmarkDetailLoadRequested(id)),
      child: BookmarkDetailView(id: id),
    );
  }
}
