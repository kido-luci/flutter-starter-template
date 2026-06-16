import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';

sealed class BookmarkMediaResult<T> {
  const BookmarkMediaResult();
}

final class BookmarkMediaSuccess<T> extends BookmarkMediaResult<T> {
  const BookmarkMediaSuccess(this.value);

  final T value;
}

final class BookmarkMediaFailure<T> extends BookmarkMediaResult<T> {
  const BookmarkMediaFailure(this.failure, {this.error, this.stackTrace});

  final Failure failure;
  final Object? error;
  final StackTrace? stackTrace;
}

class BookmarkFormMediaHandler {
  const BookmarkFormMediaHandler(
    this._imagePickerService,
    this._permissionService,
  );

  final ImagePickerService _imagePickerService;
  final PermissionService _permissionService;

  Future<BookmarkMediaResult<List<String>>> pickGalleryImages() async {
    try {
      final images = await _imagePickerService.pickMultiImage();
      return BookmarkMediaSuccess(
        images.map((image) => image.path).toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      return BookmarkMediaFailure(
        const MediaPickFailure(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<BookmarkMediaResult<List<String>>> takeCameraImage() async {
    final permissionFailure = await _ensureCameraPermission();
    if (permissionFailure != null) {
      return BookmarkMediaFailure(permissionFailure);
    }
    try {
      final image = await _imagePickerService.pickImage(
        source: ImageSource.camera,
      );
      return BookmarkMediaSuccess(image == null ? [] : [image.path]);
    } on Object catch (error, stackTrace) {
      return BookmarkMediaFailure(
        const MediaPickFailure(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<BookmarkMediaResult<String?>> pickGalleryVideo() async {
    try {
      final video = await _imagePickerService.pickVideo(
        source: ImageSource.gallery,
      );
      return BookmarkMediaSuccess(video?.path);
    } on Object catch (error, stackTrace) {
      return BookmarkMediaFailure(
        const MediaPickFailure(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<BookmarkMediaResult<String?>> recordCameraVideo() async {
    final permissionFailure = await _ensureCameraPermission();
    if (permissionFailure != null) {
      return BookmarkMediaFailure(permissionFailure);
    }
    try {
      final video = await _imagePickerService.pickVideo(
        source: ImageSource.camera,
      );
      return BookmarkMediaSuccess(video?.path);
    } on Object catch (error, stackTrace) {
      return BookmarkMediaFailure(
        const MediaPickFailure(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Failure?> _ensureCameraPermission() async {
    if (await _permissionService.hasCameraPermission()) return null;
    if (await _permissionService.requestCameraPermission()) return null;
    return const CameraPermissionFailure();
  }
}
