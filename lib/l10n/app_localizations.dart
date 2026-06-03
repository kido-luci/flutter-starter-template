import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Starter'**
  String get appTitle;

  /// No description provided for @loginAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAppBarTitle;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to organize your digital space.'**
  String get loginSubtitle;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginUsernameLabel;

  /// No description provided for @loginUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'hello@example.com'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginSubmit;

  /// No description provided for @loginDividerLabel.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get loginDividerLabel;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get loginApple;

  /// No description provided for @loginRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Flutter Starter? '**
  String get loginRegisterPrompt;

  /// No description provided for @loginNavigateToRegister.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginNavigateToRegister;

  /// No description provided for @loginPasswordRecoveryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password recovery isn\'t configured yet.'**
  String get loginPasswordRecoveryUnavailable;

  /// No description provided for @loginSocialUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Social sign-in isn\'t configured yet.'**
  String get loginSocialUnavailable;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAppBarTitle;

  /// No description provided for @registerHeadline.
  ///
  /// In en, this message translates to:
  /// **'Join Flutter Starter'**
  String get registerHeadline;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start organizing your digital life with clarity and ease.'**
  String get registerSubtitle;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'jane@example.com'**
  String get registerEmailHint;

  /// No description provided for @registerInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get registerInvalidEmail;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 8 characters.'**
  String get registerPasswordHelp;

  /// No description provided for @registerPasswordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get registerPasswordMinLengthError;

  /// No description provided for @registerShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get registerShowPassword;

  /// No description provided for @registerHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get registerHidePassword;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Join Flutter Starter'**
  String get registerSubmit;

  /// No description provided for @registerLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerLoginPrompt;

  /// No description provided for @registerNavigateToLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registerNavigateToLogin;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username and password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get errorInvalidInput;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get commonImageLoadFailed;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeAppBarTitle;

  /// No description provided for @homeViewAllBookmarks.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAllBookmarks;

  /// No description provided for @homeNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get homeNoDescription;

  /// No description provided for @homeRecentBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Recent Bookmarks'**
  String get homeRecentBookmarks;

  /// No description provided for @homeNoBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Tap + to add one.'**
  String get homeNoBookmarks;

  /// Section title above the home dashboard bookmark search field.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchTitle;

  /// Supporting text below the home dashboard search title.
  ///
  /// In en, this message translates to:
  /// **'Find your saved articles, tools, and inspirations instantly.'**
  String get homeSearchSubtitle;

  /// Placeholder text in the home dashboard bookmark search field.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks...'**
  String get homeSearchHint;

  /// Label for the quick action that opens the new bookmark form.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get homeQuickAdd;

  /// Label for the quick action that opens the full bookmarks library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeQuickLibrary;

  /// Label for the quick action that opens bookmark tag-related content.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get homeQuickTags;

  /// Filter chip label for showing all recent bookmarks.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeFilterAll;

  /// Filter chip and fallback collection label for design-related bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get homeFilterDesign;

  /// Filter chip and fallback collection label for article or blog bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get homeFilterArticles;

  /// Filter chip label for inspiration-related bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get homeFilterInspiration;

  /// Filter chip and fallback collection label for tool-related bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get homeFilterTools;

  /// Section title for suggested bookmark cards on the home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Suggested for You'**
  String get homeSuggestedTitle;

  /// Section title for featured bookmark collection cards on the home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Featured Collections'**
  String get homeFeaturedCollections;

  /// Section title for the weekly digest panel on the home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Weekly Digest'**
  String get homeWeeklyDigestTitle;

  /// Short eyebrow label displayed above the weekly digest headline.
  ///
  /// In en, this message translates to:
  /// **'Most Read'**
  String get homeWeeklyDigestEyebrow;

  /// Headline text inside the weekly digest panel on the home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Your saved knowledge catch-up'**
  String get homeWeeklyDigestHeadline;

  /// Body text inside the weekly digest panel. The count is the number of bookmarks saved in the recent window.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You have no recent bookmarks. Review saved highlights when you add one.} =1{You saved 1 bookmark recently. Review the highlight and keep your reading flow moving.} other{You saved {count} bookmarks recently. Review the highlights and keep your reading flow moving.}}'**
  String homeWeeklyDigestBody(int count);

  /// Call-to-action button label in the weekly digest panel.
  ///
  /// In en, this message translates to:
  /// **'Read Digest'**
  String get homeReadDigest;

  /// Empty-state message shown when active search or filters hide all recent bookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks match this view.'**
  String get homeNoMatches;

  /// Short fallback label shown on bookmark artwork when a bookmark has no tags.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeBookmarkVisualFallback;

  /// No description provided for @profileAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileAppBarTitle;

  /// No description provided for @profileSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileSectionAppearance;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteAccountDialogTitle;

  /// No description provided for @profileDeleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your account and all of its data. This action cannot be undone.'**
  String get profileDeleteAccountDialogMessage;

  /// No description provided for @profileDeleteAccountConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type \"{username}\" to confirm'**
  String profileDeleteAccountConfirmLabel(String username);

  /// No description provided for @profileDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get profileDeleteAccountSuccess;

  /// No description provided for @profileDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get profileDeleteAccountError;

  /// No description provided for @changePasswordAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordAppBarTitle;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get changePasswordSuccessMessage;

  /// No description provided for @changePasswordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get changePasswordMismatchError;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @profileUserIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User ID copied'**
  String get profileUserIdCopied;

  /// No description provided for @profileThemeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileThemeSystemDefault;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileAppVersionBuild.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {buildNumber})'**
  String profileAppVersionBuild(String version, String buildNumber);

  /// No description provided for @profileSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirmMessage;

  /// No description provided for @bookmarksAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksAppBarTitle;

  /// No description provided for @bookmarksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, URL, or tag'**
  String get bookmarksSearchHint;

  /// No description provided for @bookmarksNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get bookmarksNoMatchesTitle;

  /// No description provided for @bookmarksNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks match your search.'**
  String get bookmarksNoMatchesMessage;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first bookmark.'**
  String get bookmarksEmptyMessage;

  /// No description provided for @bookmarksNotYetSynced.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get bookmarksNotYetSynced;

  /// No description provided for @bookmarksSyncFailedRetryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync failed - tap to retry'**
  String get bookmarksSyncFailedRetryTooltip;

  /// No description provided for @bookmarksAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get bookmarksAddTooltip;

  /// No description provided for @bookmarksSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get bookmarksSearchClear;

  /// No description provided for @bookmarksSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort bookmarks'**
  String get bookmarksSortTooltip;

  /// No description provided for @bookmarksSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get bookmarksSortNewest;

  /// No description provided for @bookmarksSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get bookmarksSortOldest;

  /// No description provided for @bookmarksSortTitleAz.
  ///
  /// In en, this message translates to:
  /// **'Title (A–Z)'**
  String get bookmarksSortTitleAz;

  /// No description provided for @bookmarkAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Details'**
  String get bookmarkAppBarTitle;

  /// No description provided for @bookmarkSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get bookmarkSourceLabel;

  /// No description provided for @bookmarkVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get bookmarkVisitWebsite;

  /// No description provided for @bookmarkDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get bookmarkDetailsLabel;

  /// No description provided for @bookmarkDateCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get bookmarkDateCreatedLabel;

  /// No description provided for @bookmarkLastModifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get bookmarkLastModifiedLabel;

  /// No description provided for @bookmarkMediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get bookmarkMediaLabel;

  /// No description provided for @bookmarkOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get bookmarkOpenInBrowser;

  /// No description provided for @bookmarkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bookmark not found.'**
  String get bookmarkNotFound;

  /// No description provided for @bookmarkDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark?'**
  String get bookmarkDeleteDialogTitle;

  /// No description provided for @bookmarkDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed.'**
  String bookmarkDeleteDialogMessage(String title);

  /// No description provided for @bookmarkOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Open URL'**
  String get bookmarkOpenUrl;

  /// No description provided for @bookmarkAttachedVideo.
  ///
  /// In en, this message translates to:
  /// **'Attached video'**
  String get bookmarkAttachedVideo;

  /// No description provided for @bookmarkInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get bookmarkInvalidUrl;

  /// No description provided for @bookmarkCouldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get bookmarkCouldNotOpenUrl;

  /// No description provided for @bookmarkFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bookmark'**
  String get bookmarkFormEditTitle;

  /// No description provided for @bookmarkFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New bookmark'**
  String get bookmarkFormNewTitle;

  /// No description provided for @bookmarkFormLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmark.'**
  String get bookmarkFormLoadFailed;

  /// No description provided for @bookmarkTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookmarkTitleLabel;

  /// No description provided for @bookmarkUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get bookmarkUrlLabel;

  /// No description provided for @bookmarkDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get bookmarkDescriptionLabel;

  /// No description provided for @bookmarkTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get bookmarkTagsLabel;

  /// No description provided for @bookmarkTagsHint.
  ///
  /// In en, this message translates to:
  /// **'comma, separated, values'**
  String get bookmarkTagsHint;

  /// Short label shown in the bookmark form preview placeholder.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmarkPreviewLabel;

  /// No description provided for @bookmarkTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get bookmarkTitleRequired;

  /// No description provided for @bookmarkUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get bookmarkUrlRequired;

  /// No description provided for @bookmarkUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (https://…)'**
  String get bookmarkUrlInvalid;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get errorPermissionDenied;

  /// No description provided for @errorGalleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo gallery access is required to attach images.'**
  String get errorGalleryPermissionRequired;

  /// No description provided for @errorCameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to take photos.'**
  String get errorCameraPermissionRequired;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// No description provided for @bookmarksDetailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a bookmark to view its details'**
  String get bookmarksDetailPlaceholder;

  /// Accessibility label for a bookmark's attached image.
  ///
  /// In en, this message translates to:
  /// **'Image for {title}'**
  String bookmarkImageLabel(String title);

  /// No description provided for @bookmarkAttachedImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Attached image'**
  String get bookmarkAttachedImageLabel;

  /// No description provided for @bookmarkRemoveImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get bookmarkRemoveImageLabel;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @notificationsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsAppBarTitle;

  /// No description provided for @notificationsActivitySection.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get notificationsActivitySection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your notifications and recent activity will appear here.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsNoNotifications;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your notifications. Pull to refresh or try again.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notificationsUnreadCount(int count);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
