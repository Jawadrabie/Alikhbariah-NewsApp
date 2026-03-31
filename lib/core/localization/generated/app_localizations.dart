import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإخبارية السورية'**
  String get appTitle;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @savedNews.
  ///
  /// In ar, this message translates to:
  /// **'الأخبار المحفوظة'**
  String get savedNews;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @quickSearchInProgress.
  ///
  /// In ar, this message translates to:
  /// **'البحث السريع قيد التنفيذ'**
  String get quickSearchInProgress;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get categories;

  /// No description provided for @featuredNews.
  ///
  /// In ar, this message translates to:
  /// **'الأخبار المميزة'**
  String get featuredNews;

  /// No description provided for @latestNews.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الأخبار'**
  String get latestNews;

  /// No description provided for @relatedNews.
  ///
  /// In ar, this message translates to:
  /// **'أخبار متعلقة'**
  String get relatedNews;

  /// No description provided for @failedLoadCategories.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التصنيفات: {error}'**
  String failedLoadCategories(Object error);

  /// No description provided for @failedLoadFeaturedNews.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الأخبار المميزة: {error}'**
  String failedLoadFeaturedNews(Object error);

  /// No description provided for @noNewsNow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أخبار حالياً'**
  String get noNewsNow;

  /// No description provided for @allNewsShown.
  ///
  /// In ar, this message translates to:
  /// **'تم عرض كل الأخبار'**
  String get allNewsShown;

  /// No description provided for @liveStream.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر'**
  String get liveStream;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'ميزة الإشعارات قيد التنفيذ'**
  String get notificationsComingSoon;

  /// No description provided for @videos.
  ///
  /// In ar, this message translates to:
  /// **'الفيديوهات'**
  String get videos;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @readMore.
  ///
  /// In ar, this message translates to:
  /// **'قراءة المزيد'**
  String get readMore;

  /// No description provided for @programs.
  ///
  /// In ar, this message translates to:
  /// **'البرامج'**
  String get programs;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @dateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ: {date}'**
  String dateLabel(Object date);

  /// No description provided for @timeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت: {time}'**
  String timeLabel(Object time);

  /// No description provided for @openLiveStream.
  ///
  /// In ar, this message translates to:
  /// **'فتح البث المباشر'**
  String get openLiveStream;

  /// No description provided for @failedOpenLiveLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح رابط البث المباشر'**
  String get failedOpenLiveLink;

  /// No description provided for @failedLoadLiveStream.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البث المباشر: {error}'**
  String failedLoadLiveStream(Object error);

  /// No description provided for @noLiveNow.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد بث مباشر مفعّل حالياً'**
  String get noLiveNow;

  /// No description provided for @defaultLiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر - الإخبارية السورية'**
  String get defaultLiveTitle;

  /// No description provided for @defaultLiveMessage.
  ///
  /// In ar, this message translates to:
  /// **'يتم بث القناة الإخبارية السورية على مدار 24 ساعة.'**
  String get defaultLiveMessage;

  /// No description provided for @failedLoadVideos.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الفيديوهات: {error}'**
  String failedLoadVideos(Object error);

  /// No description provided for @noVideosNow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فيديوهات حالياً'**
  String get noVideosNow;

  /// No description provided for @programEpisodes.
  ///
  /// In ar, this message translates to:
  /// **'حلقات برنامج {programName}'**
  String programEpisodes(Object programName);

  /// No description provided for @failedOpenVideoLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح رابط الفيديو'**
  String get failedOpenVideoLink;

  /// No description provided for @failedLoadPrograms.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البرامج: {error}'**
  String failedLoadPrograms(Object error);

  /// No description provided for @noProgramsNow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد برامج حالياً'**
  String get noProgramsNow;

  /// No description provided for @failedLoadSavedNews.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الأخبار المحفوظة: {error}'**
  String failedLoadSavedNews(Object error);

  /// No description provided for @noSavedNewsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أخبار محفوظة حتى الآن'**
  String get noSavedNewsYet;

  /// No description provided for @savedNewsDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الخبر من المحفوظات'**
  String get savedNewsDeleted;

  /// No description provided for @articleDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get articleDetails;

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count, plural, =0 {أقل من دقيقة} =1 {دقيقة واحدة} =2 {دقيقتين} few {{count} دقائق} many {{count} دقيقة} other {{count} دقيقة}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count, plural, =0 {أقل من ساعة} =1 {ساعة واحدة} =2 {ساعتين} few {{count} ساعات} many {{count} ساعة} other {{count} ساعة}}'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count, plural, =0 {اليوم} =1 {يوم واحد} =2 {يومين} few {{count} أيام} many {{count} يوماً} other {{count} يوم}}'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count, plural, =0 {هذا الأسبوع} =1 {أسبوع واحد} =2 {أسبوعين} few {{count} أسابيع} many {{count} أسبوعاً} other {{count} أسبوع}}'**
  String weeksAgo(int count);

  /// No description provided for @increaseFontSize.
  ///
  /// In ar, this message translates to:
  /// **'تكبير الخط'**
  String get increaseFontSize;

  /// No description provided for @decreaseFontSize.
  ///
  /// In ar, this message translates to:
  /// **'تصغير الخط'**
  String get decreaseFontSize;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @removeFromSaved.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المحفوظات'**
  String get removeFromSaved;

  /// No description provided for @saveNews.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الخبر'**
  String get saveNews;

  /// No description provided for @newsSavedLocally.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الخبر محلياً'**
  String get newsSavedLocally;

  /// No description provided for @newsRemovedFromSaved.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة الخبر من المحفوظات'**
  String get newsRemovedFromSaved;

  /// No description provided for @categoryNews.
  ///
  /// In ar, this message translates to:
  /// **'خبر'**
  String get categoryNews;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get allCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات'**
  String get noCategoriesAvailable;

  /// No description provided for @breakingNow.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get breakingNow;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @openLinkFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط'**
  String get openLinkFailed;

  /// No description provided for @userReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير المستخدمين'**
  String get userReports;

  /// No description provided for @userReportsDrawerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال بلاغ أو معلومة تصل مباشرة إلى الداشبورد'**
  String get userReportsDrawerSubtitle;

  /// No description provided for @channelSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن القناة'**
  String get channelSectionTitle;

  /// No description provided for @aboutUs.
  ///
  /// In ar, this message translates to:
  /// **'من نحن'**
  String get aboutUs;

  /// No description provided for @aboutUsDescription.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني لقناة الإخبارية السورية، وهي القناة الرسمية للجمهورية العربية السورية، ويهدف الموقع إلى تقديم تغطية إعلامية مهنية ومتوازنة، تعكس توجهات الدولة في بناء سوريا الحديثة، ويتناول مختلف قضايا السياسة والاقتصاد والأخبار المحلية، بالإضافة إلى أهم الأخبار العربية والدولية.'**
  String get aboutUsDescription;

  /// No description provided for @channelFrequencies.
  ///
  /// In ar, this message translates to:
  /// **'ترددات القناة'**
  String get channelFrequencies;

  /// No description provided for @nilesat.
  ///
  /// In ar, this message translates to:
  /// **'قمر النايلسات'**
  String get nilesat;

  /// No description provided for @frequencySd.
  ///
  /// In ar, this message translates to:
  /// **'SD'**
  String get frequencySd;

  /// No description provided for @frequencyHd.
  ///
  /// In ar, this message translates to:
  /// **'HD'**
  String get frequencyHd;

  /// No description provided for @developmentTeam.
  ///
  /// In ar, this message translates to:
  /// **'فريق التطوير'**
  String get developmentTeam;

  /// No description provided for @developerRole.
  ///
  /// In ar, this message translates to:
  /// **'مطور تطبيق'**
  String get developerRole;

  /// No description provided for @developerNameAbduljawad.
  ///
  /// In ar, this message translates to:
  /// **'عبدالجواد الحاج ربيع'**
  String get developerNameAbduljawad;

  /// No description provided for @developerNameAsmaa.
  ///
  /// In ar, this message translates to:
  /// **'أسماء حموي'**
  String get developerNameAsmaa;

  /// No description provided for @reportName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (اختياري)'**
  String get reportName;

  /// No description provided for @reportPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get reportPhone;

  /// No description provided for @reportMessage.
  ///
  /// In ar, this message translates to:
  /// **'نص التقرير'**
  String get reportMessage;

  /// No description provided for @reportMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تفاصيل البلاغ هنا...'**
  String get reportMessageHint;

  /// No description provided for @sendReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقرير'**
  String get sendReport;

  /// No description provided for @reportMessageRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة نص التقرير'**
  String get reportMessageRequired;

  /// No description provided for @reportSentSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التقرير بنجاح'**
  String get reportSentSuccessfully;

  /// No description provided for @reportSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال التقرير'**
  String get reportSendFailed;

  /// No description provided for @reportAttachImage.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق صورة'**
  String get reportAttachImage;

  /// No description provided for @reportAttachmentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع المرفق بنجاح'**
  String get reportAttachmentUploaded;

  /// No description provided for @reportAttachmentReady.
  ///
  /// In ar, this message translates to:
  /// **'تم إرفاق صورة وسيتم إرسالها مع التقرير'**
  String get reportAttachmentReady;

  /// No description provided for @reportAttachmentUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر رفع المرفق'**
  String get reportAttachmentUploadFailed;

  /// No description provided for @reportAttachmentTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم المرفق كبير جداً (الحد الأقصى 8MB)'**
  String get reportAttachmentTooLarge;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
