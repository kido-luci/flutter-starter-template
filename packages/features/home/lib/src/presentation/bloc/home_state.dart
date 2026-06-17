import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_contracts/shared_contracts.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(0) int totalBookmarks,
    @Default(0) int recentBookmarks,
    @Default(0) int uniqueTags,
    @Default([]) List<BookmarkSummary> recentItems,
    @Default([]) List<CollectionSummary> collections,
    @Default(false) bool isLoading,
    Failure? failure,
  }) = _HomeState;
}
