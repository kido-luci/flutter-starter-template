import 'package:flutter/services.dart';
import 'package:flutter_starter_template/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
  });

  group('ProfileBloc', () {
    test('initial state has no packageInfo', () async {
      final bloc = ProfileBloc(mockAnalytics);

      expect(bloc.state.packageInfo, isNull);

      await bloc.close();
    });

    test('ProfileLoaded populates packageInfo', () async {
      _stubPackageInfo();
      final bloc = ProfileBloc(mockAnalytics);

      bloc.add(const ProfileLoaded());
      await bloc.stream.firstWhere((state) => state.packageInfo != null);

      expect(bloc.state.packageInfo, isNotNull);
      expect(bloc.state.packageInfo!.appName, 'TestApp');
      expect(bloc.state.packageInfo!.version, '1.0.0');
      expect(bloc.state.packageInfo!.buildNumber, '42');

      await bloc.close();
    });

    test('ProfileUserIdCopied logs the analytics event', () async {
      final bloc = ProfileBloc(mockAnalytics);

      bloc.add(const ProfileUserIdCopied());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => mockAnalytics.logEvent(
          'user_id_copied',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);

      await bloc.close();
    });
  });
}

void _stubPackageInfo() {
  const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getAll') {
          return <String, dynamic>{
            'appName': 'TestApp',
            'packageName': 'com.test.app',
            'version': '1.0.0',
            'buildNumber': '42',
          };
        }
        return null;
      });
}
