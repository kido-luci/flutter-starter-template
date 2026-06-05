import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../widgets/collections_list_view.dart';

/// Standalone collections browser (reachable at `/collections`).
class CollectionsListScreen extends StatelessWidget {
  const CollectionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.collectionsTitle,
      padding: EdgeInsets.zero,
      floatingActionButton: FloatingActionButton(
        heroTag: 'collections-add-fab',
        tooltip: context.l10n.collectionsCreate,
        onPressed: () => const CollectionNewRoute().push<void>(context),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      body: const CollectionsListView(),
    );
  }
}
