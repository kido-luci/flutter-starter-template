import 'package:architecture/architecture.dart';
import 'package:flutter/widgets.dart';

import 'package:localization/localization.dart';

String bookmarkFailureMessage(BuildContext context, Failure failure) {
  if (failure is NotFoundFailure) return context.l10n.bookmarkNotFound;
  if (failure is ValidationFailure) return context.l10n.errorInvalidInput;
  if (failure is CameraPermissionFailure) {
    return context.l10n.errorCameraPermissionRequired;
  }
  if (failure is PermissionFailure) {
    return context.l10n.errorGalleryPermissionRequired;
  }
  return context.l10n.errorUnknown;
}
