import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/notifications_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsBloc>()
        ..add(const NotificationsLoadRequested()),
      child: const NotificationsView(),
    );
  }
}
