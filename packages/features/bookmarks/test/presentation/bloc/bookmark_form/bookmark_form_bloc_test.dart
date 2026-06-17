import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_bookmarks/src/domain/usecases/update_bookmark.dart';
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_form/bookmark_form_bloc.dart';
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_form/bookmark_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support.dart';

void main() {
  late MockGetBookmark mockGet;
  late MockCreateBookmark mockCreate;
  late MockUpdateBookmark mockUpdate;
  late MockAnalyticsService mockAnalytics;
  late MockImagePickerService mockImagePicker;
  late MockPermissionService mockPermission;

  setUpAll(() {
    registerFallbackValue(FakeBookmarkInput());
    final UpdateBookmarkParams fallbackUpdateParams = (
      id: '',
      input: FakeBookmarkInput(),
    );
    registerFallbackValue(fallbackUpdateParams);
  });

  late MockActivityNotifier mockActivityNotifier;

  setUp(() {
    mockGet = MockGetBookmark();
    mockCreate = MockCreateBookmark();
    mockUpdate = MockUpdateBookmark();
    mockAnalytics = MockAnalyticsService();
    mockImagePicker = MockImagePickerService();
    mockPermission = MockPermissionService();
    mockActivityNotifier = MockActivityNotifier();
    stubAnalyticsService(mockAnalytics);
  });

  BookmarkFormBloc buildBloc() => BookmarkFormBloc(
    mockGet,
    mockCreate,
    mockUpdate,
    mockAnalytics,
    mockImagePicker,
    mockPermission,
    mockActivityNotifier,
  );

  group('BookmarkFormBloc', () {
    group('initialize', () {
      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'stays idle with empty state for create mode (null id)',
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormInitialized(null)),
        expect: () => [const BookmarkFormState()],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'loads existing bookmark for edit mode',
        setUp: () {
          when(() => mockGet('1')).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormInitialized('1')),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loading,
          ),
          predicate<BookmarkFormState>(
            (s) =>
                s.status == BookmarkFormStatus.idle &&
                s.title == 'Flutter' &&
                s.url == 'https://flutter.dev',
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'emits loadFailed when bookmark not found',
        setUp: () {
          when(
            () => mockGet('1'),
          ).thenAnswer((_) async => const Err(NotFoundFailure('Not found')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormInitialized('1')),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loading,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loadFailed,
          ),
        ],
      );
    });

    group('field setters', () {
      test('setTitle updates title', () async {
        final bloc = buildBloc();
        bloc.add(const BookmarkFormTitleChanged('Dart'));
        await bloc.stream.first;
        expect(bloc.state.title, 'Dart');
        await bloc.close();
      });

      test('setUrl updates url', () async {
        final bloc = buildBloc();
        bloc.add(const BookmarkFormUrlChanged('https://dart.dev'));
        await bloc.stream.first;
        expect(bloc.state.url, 'https://dart.dev');
        await bloc.close();
      });

      test('setDescription updates description', () async {
        final bloc = buildBloc();
        bloc.add(const BookmarkFormDescriptionChanged('The Dart language'));
        await bloc.stream.first;
        expect(bloc.state.description, 'The Dart language');
        await bloc.close();
      });

      test('setTagsFromCsv parses comma-separated tags', () async {
        final bloc = buildBloc();
        bloc.add(const BookmarkFormTagsChanged('a, b, c ,'));
        await bloc.stream.first;
        expect(bloc.state.tags, ['a', 'b', 'c']);
        await bloc.close();
      });

      test('setTagsFromCsv with empty string yields empty list', () async {
        final bloc = buildBloc();
        bloc.add(const BookmarkFormTagsChanged(''));
        await bloc.stream.first;
        expect(bloc.state.tags, isEmpty);
        await bloc.close();
      });
    });

    group('submit', () {
      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'creates new bookmark on success',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: ['dev'],
        ),
        act: (bloc) => bloc.add(const BookmarkFormSubmitted()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_created',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'updates existing bookmark on success',
        setUp: () {
          when(
            () => mockUpdate(any<UpdateBookmarkParams>()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(
          id: '1',
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: ['dev'],
        ),
        act: (bloc) => bloc.add(const BookmarkFormSubmitted()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_updated',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'returns to idle with failure on error',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => const Err(ValidationFailure('Invalid')));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(title: '.', url: '.'),
        act: (bloc) => bloc.add(const BookmarkFormSubmitted()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.idle && s.failure != null,
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'drops duplicate submit while one is in flight',
        setUp: () {
          when(() => mockCreate.call(any())).thenAnswer(
            (_) => Future.delayed(
              const Duration(milliseconds: 50),
              () => Ok(testBookmark),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) {
          bloc
            ..add(const BookmarkFormSubmitted())
            ..add(const BookmarkFormSubmitted());
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
        verify: (_) {
          verify(() => mockCreate.call(any())).called(1);
        },
      );
    });

    group('image picking', () {
      final mockFile = XFile('test/path.png');

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'picks images from the gallery without requesting permission',
        setUp: () {
          when(
            () => mockImagePicker.pickMultiImage(),
          ).thenAnswer((_) async => [mockFile]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormImagesPicked()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) =>
                s.imageUrls.length == 1 && s.imageUrls.first == 'test/path.png',
          ),
        ],
        verify: (_) {
          // The system photo picker needs no permission; gating it would
          // wrongly block the picker from opening (regression guard).
          verifyNever(() => mockPermission.hasGalleryPermission());
          verifyNever(() => mockPermission.requestGalleryPermission());
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'emits MediaPickFailure when image picker throws',
        setUp: () {
          when(
            () => mockImagePicker.pickMultiImage(),
          ).thenThrow(Exception('picker failed'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormImagesPicked()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.failure is MediaPickFailure,
          ),
        ],
        errors: () => [isA<Exception>()],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'takes image successfully when camera permission is already granted',
        setUp: () {
          when(
            () => mockPermission.hasCameraPermission(),
          ).thenAnswer((_) async => true);
          when(
            () => mockImagePicker.pickImage(source: ImageSource.camera),
          ).thenAnswer((_) async => mockFile);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormCameraImageTaken()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) =>
                s.imageUrls.length == 1 && s.imageUrls.first == 'test/path.png',
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'takes image successfully after requesting and getting camera permission',
        setUp: () {
          when(
            () => mockPermission.hasCameraPermission(),
          ).thenAnswer((_) async => false);
          when(
            () => mockPermission.requestCameraPermission(),
          ).thenAnswer((_) async => true);
          when(
            () => mockImagePicker.pickImage(source: ImageSource.camera),
          ).thenAnswer((_) async => mockFile);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormCameraImageTaken()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) =>
                s.imageUrls.length == 1 && s.imageUrls.first == 'test/path.png',
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'fails to take image when camera permission is denied',
        setUp: () {
          when(
            () => mockPermission.hasCameraPermission(),
          ).thenAnswer((_) async => false);
          when(
            () => mockPermission.requestCameraPermission(),
          ).thenAnswer((_) async => false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormCameraImageTaken()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.failure is CameraPermissionFailure,
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'removes image successfully',
        build: buildBloc,
        seed: () => const BookmarkFormState(imageUrls: ['test/path.png']),
        act: (bloc) =>
            bloc.add(const BookmarkFormImageRemoved('test/path.png')),
        expect: () => [
          predicate<BookmarkFormState>((s) => s.imageUrls.isEmpty),
        ],
      );
    });

    group('video picking', () {
      final mockVideo = XFile('test/video.mp4');

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'picks video from the gallery without requesting permission',
        setUp: () {
          when(
            () => mockImagePicker.pickVideo(source: ImageSource.gallery),
          ).thenAnswer((_) async => mockVideo);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormVideoPicked()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.videoUrl == 'test/video.mp4',
          ),
        ],
        verify: (_) {
          verifyNever(() => mockPermission.hasGalleryPermission());
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'records video successfully when camera permission is already granted',
        setUp: () {
          when(
            () => mockPermission.hasCameraPermission(),
          ).thenAnswer((_) async => true);
          when(
            () => mockImagePicker.pickVideo(source: ImageSource.camera),
          ).thenAnswer((_) async => mockVideo);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarkFormCameraVideoTaken()),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.videoUrl == 'test/video.mp4',
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'removes video successfully',
        build: buildBloc,
        seed: () => const BookmarkFormState(videoUrl: 'test/video.mp4'),
        act: (bloc) => bloc.add(const BookmarkFormVideoRemoved()),
        expect: () => [
          predicate<BookmarkFormState>((s) => s.videoUrl == null),
        ],
      );
    });
  });
}
