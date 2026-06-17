part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

final class ProfileUserIdCopied extends ProfileEvent {
  const ProfileUserIdCopied();
}
