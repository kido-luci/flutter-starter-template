/// Re-exports the `Session` contract from `package:shared_ui`.
///
/// Thin shim so existing in-app imports of this path keep working; feature
/// packages import `package:shared_ui` directly.
library;

export 'package:shared_ui/shared_ui.dart' show Session;
