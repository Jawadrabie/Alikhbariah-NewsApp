// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Syrian News';

  @override
  String get search => 'Search';

  @override
  String get savedNews => 'Saved News';

  @override
  String get refresh => 'Refresh';

  @override
  String get quickSearchInProgress => 'Quick search is in progress';

  @override
  String get categories => 'Categories';

  @override
  String get featuredNews => 'Featured News';

  @override
  String get latestNews => 'Latest News';

  @override
  String get relatedNews => 'Related News';

  @override
  String failedLoadCategories(Object error) {
    return 'Failed to load categories: $error';
  }

  @override
  String failedLoadFeaturedNews(Object error) {
    return 'Failed to load featured news: $error';
  }

  @override
  String get noNewsNow => 'No news available now';

  @override
  String get allNewsShown => 'All news has been displayed';

  @override
  String get liveStream => 'Live Stream';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsComingSoon => 'Notifications feature is coming soon';

  @override
  String get notificationsInboxEmpty => 'No notifications yet';

  @override
  String get notificationsInboxClearAll => 'Clear all';

  @override
  String get notificationsInboxCleared => 'Notifications cleared';

  @override
  String get notificationsInboxUntitled => 'Notification';

  @override
  String notificationsInboxLoadFailed(Object error) {
    return 'Failed to load notifications: $error';
  }

  @override
  String get videos => 'Videos';

  @override
  String get viewAll => 'View all';

  @override
  String get readMore => 'See more';

  @override
  String get programs => 'Programs';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String dateLabel(Object date) {
    return 'Date: $date';
  }

  @override
  String timeLabel(Object time) {
    return 'Time: $time';
  }

  @override
  String get openLiveStream => 'Open Live Stream';

  @override
  String get failedOpenLiveLink => 'Failed to open live stream link';

  @override
  String failedLoadLiveStream(Object error) {
    return 'Failed to load live stream: $error';
  }

  @override
  String get noLiveNow => 'No active live stream at the moment';

  @override
  String get defaultLiveTitle => 'Live Stream - Syrian News';

  @override
  String get defaultLiveMessage => 'The Syrian News channel is broadcast live 24 hours a day.';

  @override
  String failedLoadVideos(Object error) {
    return 'Failed to load videos: $error';
  }

  @override
  String get noVideosNow => 'No videos available now';

  @override
  String programEpisodes(Object programName) {
    return '$programName Episodes';
  }

  @override
  String get failedOpenVideoLink => 'Failed to open video link';

  @override
  String failedLoadPrograms(Object error) {
    return 'Failed to load programs: $error';
  }

  @override
  String get noProgramsNow => 'No programs available now';

  @override
  String failedLoadSavedNews(Object error) {
    return 'Failed to load saved news: $error';
  }

  @override
  String get noSavedNewsYet => 'No saved news yet';

  @override
  String get savedNewsDeleted => 'News removed from saved items';

  @override
  String get articleDetails => 'Details';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: 'A minute ago',
      zero: 'Less than a minute ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: 'An hour ago',
      zero: 'Less than an hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'A day ago',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: 'A week ago',
      zero: 'This week',
    );
    return '$_temp0';
  }

  @override
  String get increaseFontSize => 'Increase Font Size';

  @override
  String get decreaseFontSize => 'Decrease Font Size';

  @override
  String get share => 'Share';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get saveNews => 'Save news';

  @override
  String get newsSavedLocally => 'News saved locally';

  @override
  String get newsRemovedFromSaved => 'News removed from saved items';

  @override
  String get categoryNews => 'News';

  @override
  String get allCategories => 'Home';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get breakingNow => 'Breaking';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get cancel => 'Cancel';

  @override
  String get openLinkFailed => 'Failed to open link';

  @override
  String get userReports => 'User Reports';

  @override
  String get userReportsDrawerSubtitle => 'Send a report that appears directly in the dashboard';

  @override
  String get channelSectionTitle => 'About Channel';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutUsDescription => 'The official website of the Syrian News channel of the Syrian Arab Republic. The platform provides professional and balanced media coverage that reflects the state\'s direction toward building a modern Syria, covering politics, economy, local news, and key Arab and international headlines.';

  @override
  String get channelFrequencies => 'Channel Frequencies';

  @override
  String get nilesat => 'Nilesat';

  @override
  String get frequencySd => 'SD';

  @override
  String get frequencyHd => 'HD';

  @override
  String get developmentTeam => 'Development Team';

  @override
  String get developerRole => 'App Developer';

  @override
  String get developerNameAbduljawad => 'عبدالجواد الحاج ربيع';

  @override
  String get developerNameAsmaa => 'أسماء حموي';

  @override
  String get reportName => 'Name (optional)';

  @override
  String get reportPhone => 'Phone (optional)';

  @override
  String get reportMessage => 'Report message';

  @override
  String get reportMessageHint => 'Write your report details here...';

  @override
  String get sendReport => 'Send report';

  @override
  String get reportMessageRequired => 'Please enter report message';

  @override
  String get reportSentSuccessfully => 'Report sent successfully';

  @override
  String get reportSendFailed => 'Failed to send report';

  @override
  String get reportAttachImage => 'Attach image';

  @override
  String get reportAttachmentUploaded => 'Attachment uploaded successfully';

  @override
  String get reportAttachmentReady => 'Image attached and will be sent with your report';

  @override
  String get reportAttachmentUploadFailed => 'Failed to upload attachment';

  @override
  String get reportAttachmentTooLarge => 'Attachment is too large (max 8MB)';
}
