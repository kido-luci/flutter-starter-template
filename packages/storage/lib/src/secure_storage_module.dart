import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Provides the app-wide [FlutterSecureStorage] instance to the DI graph.
@module
abstract class SecureStorageModule {
  @lazySingleton
  FlutterSecureStorage provideSecureStorage() => const FlutterSecureStorage(
    // iOS: tokens stay accessible after the first unlock (so background token
    // refresh keeps working) but are device-only — never synced to iCloud
    // Keychain and never restored onto a different device. Android needs no
    // tuning here: this version already defaults to a strong AES-GCM +
    // RSA-OAEP KeyStore backend.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}
