import 'package:app_platform/app_platform.dart';
import 'package:feature_bookmarks/src/presentation/widgets/app_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_utils/test_utils.dart';

class MockAppVideoPlayerController extends Mock
    implements AppVideoPlayerController {}

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

void main() {
  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('AppVideoPlayer', () {
    late MockAppVideoPlayerController mockController;
    late MockVideoPlayerController mockRawController;
    late ValueNotifier<VideoPlayerValue> valueNotifier;

    setUp(() {
      mockController = MockAppVideoPlayerController();
      mockRawController = MockVideoPlayerController();
      valueNotifier = ValueNotifier<VideoPlayerValue>(
        const VideoPlayerValue(
          duration: Duration(seconds: 60),
          isInitialized: false,
        ),
      );

      when(() => mockController.valueListenable).thenReturn(valueNotifier);
      when(() => mockController.value).thenReturn(valueNotifier.value);
      when(() => mockController.rawController).thenReturn(mockRawController);
    });

    testWidgets('renders placeholder when rawController is null', (
      tester,
    ) async {
      when(() => mockController.rawController).thenReturn(null);

      await tester.pumpWidget(
        wrapWithMaterial(AppVideoPlayer(controller: mockController)),
      );

      expect(find.text('Mock Video Player View'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.video.codePoint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders error view when video fails to load', (
      tester,
    ) async {
      // Update state to have error
      const errorValue = VideoPlayerValue(
        duration: Duration.zero,
        errorDescription: 'Invalid video file format',
      );
      when(() => mockController.value).thenReturn(errorValue);

      await tester.pumpWidget(
        wrapWithMaterial(AppVideoPlayer(controller: mockController)),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is FaIcon &&
              w.icon?.codePoint == FontAwesomeIcons.circleExclamation.codePoint,
        ),
        findsOneWidget,
      );
      expect(find.text('Invalid video file format'), findsOneWidget);
    });
  });
}
