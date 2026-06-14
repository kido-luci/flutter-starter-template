import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../shared/domain/activity_notifier.dart';

import '../../../domain/usecases/create_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import '../../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_loader.dart';
import 'bookmark_form_media_handler.dart';
import 'bookmark_form_state.dart';
import 'bookmark_form_submitter.dart';
import 'bookmark_tag_parser.dart';

part 'bookmark_form_event.dart';

@injectable
class BookmarkFormBloc extends Bloc<BookmarkFormEvent, BookmarkFormState> {
  BookmarkFormBloc(
    GetBookmark get,
    CreateBookmark create,
    UpdateBookmark update,
    AnalyticsService analytics,
    ImagePickerService imagePickerService,
    PermissionService permissionService,
    ActivityNotifier activityNotifier,
  ) : _loader = BookmarkFormLoader(get),
      _submitter = BookmarkFormSubmitter(create, update, analytics),
      _activityNotifier = activityNotifier,
      _mediaHandler = BookmarkFormMediaHandler(
        imagePickerService,
        permissionService,
      ),
      super(const BookmarkFormState()) {
    on<BookmarkFormInitialized>(_onInitialized, transformer: droppable());
    on<BookmarkFormTitleChanged>(_onTitleChanged);
    on<BookmarkFormUrlChanged>(_onUrlChanged);
    on<BookmarkFormDescriptionChanged>(_onDescriptionChanged);
    on<BookmarkFormTagsChanged>(_onTagsChanged);
    on<BookmarkFormImageRemoved>(_onImageRemoved);
    on<BookmarkFormVideoRemoved>(_onVideoRemoved);
    on<BookmarkFormImagesPicked>(_onImagesPicked, transformer: sequential());
    on<BookmarkFormCameraImageTaken>(
      _onCameraImageTaken,
      transformer: sequential(),
    );
    on<BookmarkFormVideoPicked>(_onVideoPicked, transformer: sequential());
    on<BookmarkFormCameraVideoTaken>(
      _onCameraVideoTaken,
      transformer: sequential(),
    );
    on<BookmarkFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  final BookmarkFormLoader _loader;
  final BookmarkFormSubmitter _submitter;
  final BookmarkFormMediaHandler _mediaHandler;
  final ActivityNotifier _activityNotifier;

  Future<void> _onInitialized(
    BookmarkFormInitialized event,
    Emitter<BookmarkFormState> emit,
  ) async {
    final id = event.id;
    if (id == null) {
      emit(const BookmarkFormState());
      return;
    }

    emit(state.copyWith(id: id, status: BookmarkFormStatus.loading));
    final result = await _loader.load(id);
    switch (result) {
      case Ok(value: final loadedState):
        emit(loadedState);
      case Err(:final failure):
        emit(
          state.copyWith(
            status: BookmarkFormStatus.loadFailed,
            failure: failure,
          ),
        );
    }
  }

  void _onTitleChanged(
    BookmarkFormTitleChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(title: event.value));
  }

  void _onUrlChanged(
    BookmarkFormUrlChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(url: event.value));
  }

  void _onDescriptionChanged(
    BookmarkFormDescriptionChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(description: event.value));
  }

  void _onTagsChanged(
    BookmarkFormTagsChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(tags: parseBookmarkTagsCsv(event.csv)));
  }

  Future<void> _onImagesPicked(
    BookmarkFormImagesPicked event,
    Emitter<BookmarkFormState> emit,
  ) async {
    final result = await _mediaHandler.pickGalleryImages();
    _emitImagePickResult(result, emit);
  }

  Future<void> _onCameraImageTaken(
    BookmarkFormCameraImageTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    final result = await _mediaHandler.takeCameraImage();
    _emitImagePickResult(result, emit);
  }

  void _onImageRemoved(
    BookmarkFormImageRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(
      state.copyWith(
        imageUrls: state.imageUrls
            .where((p) => p != event.path)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _onVideoPicked(
    BookmarkFormVideoPicked event,
    Emitter<BookmarkFormState> emit,
  ) async {
    final result = await _mediaHandler.pickGalleryVideo();
    _emitVideoPickResult(result, emit);
  }

  Future<void> _onCameraVideoTaken(
    BookmarkFormCameraVideoTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    final result = await _mediaHandler.recordCameraVideo();
    _emitVideoPickResult(result, emit);
  }

  void _onVideoRemoved(
    BookmarkFormVideoRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(videoUrl: null));
  }

  Future<void> _onSubmitted(
    BookmarkFormSubmitted event,
    Emitter<BookmarkFormState> emit,
  ) async {
    emit(state.copyWith(status: BookmarkFormStatus.submitting, failure: null));

    final result = await _submitter.submit(state);
    switch (result) {
      case Ok<void>():
        emit(state.copyWith(status: BookmarkFormStatus.submitted));
        _activityNotifier.notifyActivityOccurred();
      case Err(:final failure):
        emit(state.copyWith(status: BookmarkFormStatus.idle, failure: failure));
    }
  }

  void _emitImagePickResult(
    BookmarkMediaResult<List<String>> result,
    Emitter<BookmarkFormState> emit,
  ) {
    _recordMediaError(result);
    switch (result) {
      case BookmarkMediaSuccess(value: final paths):
        if (paths.isNotEmpty) {
          // Use a set merge so picking the same image twice doesn't duplicate
          // it; LinkedHashSet preserves insertion order (existing first).
          final merged = {...state.imageUrls, ...paths}.toList(growable: false);
          emit(state.copyWith(imageUrls: merged));
        }
      case BookmarkMediaFailure(:final failure):
        emit(state.copyWith(status: BookmarkFormStatus.idle, failure: failure));
    }
  }

  void _emitVideoPickResult(
    BookmarkMediaResult<String?> result,
    Emitter<BookmarkFormState> emit,
  ) {
    _recordMediaError(result);
    switch (result) {
      case BookmarkMediaSuccess(value: final path):
        if (path != null) emit(state.copyWith(videoUrl: path));
      case BookmarkMediaFailure(:final failure):
        emit(state.copyWith(status: BookmarkFormStatus.idle, failure: failure));
    }
  }

  void _recordMediaError<T>(BookmarkMediaResult<T> result) {
    switch (result) {
      case BookmarkMediaSuccess():
        break;
      case BookmarkMediaFailure(:final error, :final stackTrace):
        if (error != null && stackTrace != null) addError(error, stackTrace);
    }
  }
}
