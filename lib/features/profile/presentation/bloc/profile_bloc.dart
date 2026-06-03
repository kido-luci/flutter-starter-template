import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'profile_state.dart';

part 'profile_event.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._analytics) : super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded, transformer: droppable());
    on<ProfileUserIdCopied>(_onUserIdCopied);
  }

  final AnalyticsService _analytics;

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    final info = await PackageInfo.fromPlatform();
    emit(state.copyWith(packageInfo: info));
  }

  void _onUserIdCopied(
    ProfileUserIdCopied event,
    Emitter<ProfileState> emit,
  ) {
    _analytics.trackUserIdCopied().uw();
  }
}
