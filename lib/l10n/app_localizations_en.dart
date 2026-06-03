// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get loginAppBarTitle => 'Sign in';

  @override
  String get loginHeadline => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to organize your digital space.';

  @override
  String get loginUsernameLabel => 'Email Address';

  @override
  String get loginUsernameHint => 'hello@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginForgotPassword => 'Forgot?';

  @override
  String get loginSubmit => 'Log In';

  @override
  String get loginDividerLabel => 'OR CONTINUE WITH';

  @override
  String get loginGoogle => 'Google';

  @override
  String get loginApple => 'Apple';

  @override
  String get loginRegisterPrompt => 'New to Flutter Starter? ';

  @override
  String get loginNavigateToRegister => 'Create an account';

  @override
  String get loginPasswordRecoveryUnavailable =>
      'Password recovery isn\'t configured yet.';

  @override
  String get loginSocialUnavailable => 'Social sign-in isn\'t configured yet.';

  @override
  String get registerAppBarTitle => 'Register';

  @override
  String get registerHeadline => 'Join Flutter Starter';

  @override
  String get registerSubtitle =>
      'Create an account to start organizing your digital life with clarity and ease.';

  @override
  String get registerEmailLabel => 'Email Address';

  @override
  String get registerEmailHint => 'jane@example.com';

  @override
  String get registerInvalidEmail => 'Enter a valid email address.';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => '••••••••';

  @override
  String get registerPasswordHelp => 'Must be at least 8 characters.';

  @override
  String get registerPasswordMinLengthError =>
      'Password must be at least 8 characters.';

  @override
  String get registerShowPassword => 'Show password';

  @override
  String get registerHidePassword => 'Hide password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerSubmit => 'Join Flutter Starter';

  @override
  String get registerLoginPrompt => 'Already have an account? ';

  @override
  String get registerNavigateToLogin => 'Log in';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get errorInvalidCredentials => 'Please enter a username and password.';

  @override
  String get errorInvalidInput => 'Invalid input.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonImageLoadFailed => 'Failed to load image';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get homeAppBarTitle => 'Home';

  @override
  String get homeViewAllBookmarks => 'View all';

  @override
  String get homeNoDescription => 'No description';

  @override
  String get homeRecentBookmarks => 'Recent Bookmarks';

  @override
  String get homeNoBookmarks => 'No bookmarks yet. Tap + to add one.';

  @override
  String get homeSearchTitle => 'Search';

  @override
  String get homeSearchSubtitle =>
      'Find your saved articles, tools, and inspirations instantly.';

  @override
  String get homeSearchHint => 'Search bookmarks...';

  @override
  String get homeQuickAdd => 'Add Link';

  @override
  String get homeQuickLibrary => 'Library';

  @override
  String get homeQuickTags => 'Tags';

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeFilterDesign => 'Design';

  @override
  String get homeFilterArticles => 'Articles';

  @override
  String get homeFilterInspiration => 'Inspiration';

  @override
  String get homeFilterTools => 'Tools';

  @override
  String get homeSuggestedTitle => 'Suggested for You';

  @override
  String get homeFeaturedCollections => 'Featured Collections';

  @override
  String get homeWeeklyDigestTitle => 'Weekly Digest';

  @override
  String get homeWeeklyDigestEyebrow => 'Most Read';

  @override
  String get homeWeeklyDigestHeadline => 'Your saved knowledge catch-up';

  @override
  String homeWeeklyDigestBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You saved $count bookmarks recently. Review the highlights and keep your reading flow moving.',
      one:
          'You saved 1 bookmark recently. Review the highlight and keep your reading flow moving.',
      zero:
          'You have no recent bookmarks. Review saved highlights when you add one.',
    );
    return '$_temp0';
  }

  @override
  String get homeReadDigest => 'Read Digest';

  @override
  String get homeNoMatches => 'No bookmarks match this view.';

  @override
  String get homeBookmarkVisualFallback => 'Recent';

  @override
  String get profileAppBarTitle => 'Profile';

  @override
  String get profileSectionAppearance => 'Appearance';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get profileDeleteAccountDialogMessage =>
      'This permanently removes your account and all of its data. This action cannot be undone.';

  @override
  String profileDeleteAccountConfirmLabel(String username) {
    return 'Type \"$username\" to confirm';
  }

  @override
  String get profileDeleteAccountSuccess => 'Your account has been deleted.';

  @override
  String get profileDeleteAccountError =>
      'Couldn\'t delete your account. Please try again.';

  @override
  String get changePasswordAppBarTitle => 'Change Password';

  @override
  String get changePasswordCurrentLabel => 'Current Password';

  @override
  String get changePasswordNewLabel => 'New Password';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePasswordSubmit => 'Update Password';

  @override
  String get changePasswordSuccessMessage => 'Password updated successfully.';

  @override
  String get changePasswordMismatchError => 'New passwords do not match.';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get profileUserIdCopied => 'User ID copied';

  @override
  String get profileThemeSystemDefault => 'System default';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String profileAppVersionBuild(String version, String buildNumber) {
    return 'Version $version (build $buildNumber)';
  }

  @override
  String get profileSignOutConfirmMessage =>
      'Are you sure you want to sign out?';

  @override
  String get bookmarksAppBarTitle => 'Bookmarks';

  @override
  String get bookmarksSearchHint => 'Search title, URL, or tag';

  @override
  String get bookmarksNoMatchesTitle => 'No matches';

  @override
  String get bookmarksNoMatchesMessage => 'No bookmarks match your search.';

  @override
  String get bookmarksEmptyTitle => 'No bookmarks yet';

  @override
  String get bookmarksEmptyMessage => 'Tap + to add your first bookmark.';

  @override
  String get bookmarksNotYetSynced => 'Not yet synced';

  @override
  String get bookmarksSyncFailedRetryTooltip => 'Sync failed - tap to retry';

  @override
  String get bookmarksAddTooltip => 'Add bookmark';

  @override
  String get bookmarksSearchClear => 'Clear search';

  @override
  String get bookmarksSortTooltip => 'Sort bookmarks';

  @override
  String get bookmarksSortNewest => 'Newest first';

  @override
  String get bookmarksSortOldest => 'Oldest first';

  @override
  String get bookmarksSortTitleAz => 'Title (A–Z)';

  @override
  String get bookmarkAppBarTitle => 'Bookmark';

  @override
  String get bookmarkNotFound => 'Bookmark not found.';

  @override
  String get bookmarkDeleteDialogTitle => 'Delete bookmark?';

  @override
  String bookmarkDeleteDialogMessage(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get bookmarkOpenUrl => 'Open URL';

  @override
  String get bookmarkAttachedVideo => 'Attached video';

  @override
  String get bookmarkInvalidUrl => 'Invalid URL';

  @override
  String get bookmarkCouldNotOpenUrl => 'Could not open URL';

  @override
  String get bookmarkFormEditTitle => 'Edit bookmark';

  @override
  String get bookmarkFormNewTitle => 'New bookmark';

  @override
  String get bookmarkFormLoadFailed => 'Failed to load bookmark.';

  @override
  String get bookmarkTitleLabel => 'Title';

  @override
  String get bookmarkUrlLabel => 'URL';

  @override
  String get bookmarkDescriptionLabel => 'Description (optional)';

  @override
  String get bookmarkTagsLabel => 'Tags';

  @override
  String get bookmarkTagsHint => 'comma, separated, values';

  @override
  String get bookmarkPreviewLabel => 'Bookmark';

  @override
  String get bookmarkTitleRequired => 'Title is required';

  @override
  String get bookmarkUrlRequired => 'URL is required';

  @override
  String get bookmarkUrlInvalid => 'Enter a valid URL (https://…)';

  @override
  String get errorPermissionDenied => 'Permission denied.';

  @override
  String get errorGalleryPermissionRequired =>
      'Photo gallery access is required to attach images.';

  @override
  String get errorCameraPermissionRequired =>
      'Camera access is required to take photos.';

  @override
  String get navHome => 'Home';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get bookmarksDetailPlaceholder =>
      'Select a bookmark to view its details';

  @override
  String bookmarkImageLabel(String title) {
    return 'Image for $title';
  }

  @override
  String get bookmarkAttachedImageLabel => 'Attached image';

  @override
  String get bookmarkRemoveImageLabel => 'Remove image';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get notificationsAppBarTitle => 'Notifications';

  @override
  String get notificationsActivitySection => 'Your activity';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'Nothing here yet';

  @override
  String get notificationsEmptyMessage =>
      'Your notifications and recent activity will appear here.';

  @override
  String get notificationsNoNotifications => 'No notifications yet.';

  @override
  String get notificationsLoadError =>
      'Couldn\'t load your notifications. Pull to refresh or try again.';

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }
}
