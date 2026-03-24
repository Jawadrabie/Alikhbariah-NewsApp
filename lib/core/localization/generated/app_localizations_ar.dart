// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الإخبارية السورية';

  @override
  String get search => 'بحث';

  @override
  String get savedNews => 'الأخبار المحفوظة';

  @override
  String get refresh => 'تحديث';

  @override
  String get quickSearchInProgress => 'البحث السريع قيد التنفيذ';

  @override
  String get categories => 'التصنيفات';

  @override
  String get featuredNews => 'الأخبار المميزة';

  @override
  String get latestNews => 'أحدث الأخبار';

  @override
  String get relatedNews => 'أخبار متعلقة';

  @override
  String failedLoadCategories(Object error) {
    return 'تعذر تحميل التصنيفات: $error';
  }

  @override
  String failedLoadFeaturedNews(Object error) {
    return 'تعذر تحميل الأخبار المميزة: $error';
  }

  @override
  String get noNewsNow => 'لا توجد أخبار حالياً';

  @override
  String get allNewsShown => 'تم عرض كل الأخبار';

  @override
  String get liveStream => 'البث المباشر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsComingSoon => 'ميزة الإشعارات قيد التنفيذ';

  @override
  String get videos => 'الفيديوهات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get readMore => 'قراءة المزيد';

  @override
  String get programs => 'البرامج';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String dateLabel(Object date) {
    return 'التاريخ: $date';
  }

  @override
  String timeLabel(Object time) {
    return 'الوقت: $time';
  }

  @override
  String get openLiveStream => 'فتح البث المباشر';

  @override
  String get failedOpenLiveLink => 'تعذر فتح رابط البث المباشر';

  @override
  String failedLoadLiveStream(Object error) {
    return 'تعذر تحميل البث المباشر: $error';
  }

  @override
  String get noLiveNow => 'لا يوجد بث مباشر مفعّل حالياً';

  @override
  String get defaultLiveTitle => 'البث المباشر - الإخبارية السورية';

  @override
  String get defaultLiveMessage => 'يتم بث القناة الإخبارية السورية على مدار 24 ساعة.';

  @override
  String failedLoadVideos(Object error) {
    return 'تعذر تحميل الفيديوهات: $error';
  }

  @override
  String get noVideosNow => 'لا توجد فيديوهات حالياً';

  @override
  String programEpisodes(Object programName) {
    return 'حلقات برنامج $programName';
  }

  @override
  String get failedOpenVideoLink => 'تعذر فتح رابط الفيديو';

  @override
  String failedLoadPrograms(Object error) {
    return 'تعذر تحميل البرامج: $error';
  }

  @override
  String get noProgramsNow => 'لا توجد برامج حالياً';

  @override
  String failedLoadSavedNews(Object error) {
    return 'تعذر تحميل الأخبار المحفوظة: $error';
  }

  @override
  String get noSavedNewsYet => 'لا توجد أخبار محفوظة حتى الآن';

  @override
  String get savedNewsDeleted => 'تم حذف الخبر من المحفوظات';

  @override
  String get articleDetails => 'التفاصيل';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتين',
      one: 'دقيقة واحدة',
      zero: 'أقل من دقيقة',
    );
    return 'منذ $_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة',
      many: '$count ساعة',
      few: '$count ساعات',
      two: 'ساعتين',
      one: 'ساعة واحدة',
      zero: 'أقل من ساعة',
    );
    return 'منذ $_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يوماً',
      few: '$count أيام',
      two: 'يومين',
      one: 'يوم واحد',
      zero: 'اليوم',
    );
    return 'منذ $_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسبوع',
      many: '$count أسبوعاً',
      few: '$count أسابيع',
      two: 'أسبوعين',
      one: 'أسبوع واحد',
      zero: 'هذا الأسبوع',
    );
    return 'منذ $_temp0';
  }

  @override
  String get increaseFontSize => 'تكبير الخط';

  @override
  String get decreaseFontSize => 'تصغير الخط';

  @override
  String get share => 'مشاركة';

  @override
  String get removeFromSaved => 'إزالة من المحفوظات';

  @override
  String get saveNews => 'حفظ الخبر';

  @override
  String get newsSavedLocally => 'تم حفظ الخبر محلياً';

  @override
  String get newsRemovedFromSaved => 'تمت إزالة الخبر من المحفوظات';

  @override
  String get categoryNews => 'خبر';

  @override
  String get allCategories => 'الرئيسية';

  @override
  String get noCategoriesAvailable => 'لا توجد تصنيفات';

  @override
  String get breakingNow => 'عاجل';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get openLinkFailed => 'تعذر فتح الرابط';

  @override
  String get userReports => 'تقارير المستخدمين';

  @override
  String get userReportsDrawerSubtitle => 'إرسال بلاغ أو معلومة تصل مباشرة إلى الداشبورد';

  @override
  String get reportName => 'الاسم (اختياري)';

  @override
  String get reportPhone => 'رقم الهاتف (اختياري)';

  @override
  String get reportMessage => 'نص التقرير';

  @override
  String get reportMessageHint => 'اكتب تفاصيل البلاغ هنا...';

  @override
  String get sendReport => 'إرسال التقرير';

  @override
  String get reportMessageRequired => 'يرجى كتابة نص التقرير';

  @override
  String get reportSentSuccessfully => 'تم إرسال التقرير بنجاح';

  @override
  String get reportSendFailed => 'تعذر إرسال التقرير';

  @override
  String get reportAttachImage => 'إرفاق صورة';

  @override
  String get reportAttachmentUploaded => 'تم رفع المرفق بنجاح';

  @override
  String get reportAttachmentReady => 'تم إرفاق صورة وسيتم إرسالها مع التقرير';

  @override
  String get reportAttachmentUploadFailed => 'تعذر رفع المرفق';

  @override
  String get reportAttachmentTooLarge => 'حجم المرفق كبير جداً (الحد الأقصى 8MB)';
}
