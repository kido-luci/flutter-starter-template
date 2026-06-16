part of 'bookmark_form_bloc.dart';

sealed class BookmarkFormEvent {
  const BookmarkFormEvent();
}

final class BookmarkFormInitialized extends BookmarkFormEvent {
  const BookmarkFormInitialized(this.id);

  final String? id;
}

final class BookmarkFormTitleChanged extends BookmarkFormEvent {
  const BookmarkFormTitleChanged(this.value);

  final String value;
}

final class BookmarkFormUrlChanged extends BookmarkFormEvent {
  const BookmarkFormUrlChanged(this.value);

  final String value;
}

final class BookmarkFormDescriptionChanged extends BookmarkFormEvent {
  const BookmarkFormDescriptionChanged(this.value);

  final String value;
}

final class BookmarkFormTagsChanged extends BookmarkFormEvent {
  const BookmarkFormTagsChanged(this.csv);

  final String csv;
}

final class BookmarkFormImagesPicked extends BookmarkFormEvent {
  const BookmarkFormImagesPicked();
}

final class BookmarkFormCameraImageTaken extends BookmarkFormEvent {
  const BookmarkFormCameraImageTaken();
}

final class BookmarkFormImageRemoved extends BookmarkFormEvent {
  const BookmarkFormImageRemoved(this.path);

  final String path;
}

final class BookmarkFormVideoPicked extends BookmarkFormEvent {
  const BookmarkFormVideoPicked();
}

final class BookmarkFormCameraVideoTaken extends BookmarkFormEvent {
  const BookmarkFormCameraVideoTaken();
}

final class BookmarkFormVideoRemoved extends BookmarkFormEvent {
  const BookmarkFormVideoRemoved();
}

final class BookmarkFormSubmitted extends BookmarkFormEvent {
  const BookmarkFormSubmitted();
}
