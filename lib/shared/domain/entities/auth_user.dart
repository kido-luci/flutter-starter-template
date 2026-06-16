/// Re-exports the `AuthUser` contract from `package:shared_contracts`.
///
/// Thin shim so existing in-app imports of this path keep working; feature
/// packages import `package:shared_contracts` directly.
library;

export 'package:shared_contracts/shared_contracts.dart' show AuthUser;
