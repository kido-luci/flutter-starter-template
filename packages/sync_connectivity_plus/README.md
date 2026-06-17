# sync_connectivity_plus

`connectivity_plus` adapter for the offline-first `sync` engine. Exported
through `package:sync_connectivity_plus/sync_connectivity_plus.dart`.

The `sync` package defines the `ConnectivitySource` port but stays pure Dart
and plugin-agnostic. This package supplies the concrete platform
implementation, keeping the `connectivity_plus` dependency out of both `sync`
and the host app.

## Public API

- `ConnectivityPlusSource` — adapts `connectivity_plus` to `sync`'s
  `ConnectivitySource`, collapsing the platform's list of links into a single
  online/offline signal.
- `SyncConnectivityPlusPackageModule` — the injectable micro-package module the
  app registers via `externalPackageModulesBefore`. Provides the
  `Connectivity` instance and binds `ConnectivitySource`.
