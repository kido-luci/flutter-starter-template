import 'package:database/database.dart';
import 'package:injectable/injectable.dart';

/// Bridges ObjectBox into the injectable DI graph. `@preResolve` makes
/// `configureDependencies()` async so the native store has a chance to open
/// before any consumer is constructed.
///
/// The [ObjectBox] wrapper and [Store] type live in `package:database`; the app
/// owns the registration so the async open is awaited by the host's
/// `configureDependencies()` (micro-package modules don't drive `@preResolve`).
@module
abstract class ObjectBoxModule {
  @preResolve
  @singleton
  Future<ObjectBox> provideObjectBox() => ObjectBox.open();

  @singleton
  Store provideStore(ObjectBox objectBox) => objectBox.store;
}
