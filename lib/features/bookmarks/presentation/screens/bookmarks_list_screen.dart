import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../widgets/bookmarks_list_widgets.dart';

class BookmarksListScreen extends StatelessWidget {
  const BookmarksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookmarksListBloc>()..add(const BookmarksListLoadRequested()),
      child: const BookmarksListView(),
    );
  }
}
