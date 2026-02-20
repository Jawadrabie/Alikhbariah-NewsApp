# الخطة التنفيذية الشاملة — تطبيق الإخبارية السورية

آخر تحديث: 18-02-2026  
حالة المستند: مسودة عمل قابلة للتعديل من جميع الـ Agents

---

## 1) الملخص التنفيذي

هذا المستند هو المرجع الرسمي لخطة بناء:

1. تطبيق جوال Flutter لقناة الإخبارية السورية.
2. لوحة تحكم Web Dashboard باستخدام Flutter Web.

الهدف هو محاكاة الهوية البصرية والميزات الأساسية للموقع الرسمي:
https://alikhbariah.com/

مع إضافة تحسينات UX احترافية متفق عليها، وأهمها:
- AppBar مخصص (يمين: الشعار + اسم التطبيق، يسار: بحث + Drawer).
- التاريخ والتوقيت الحالي يظهران داخل Drawer.
- الفيديوهات والبث المباشر من روابط YouTube (العنوان + الرابط فقط في الداشبورد).
- حفظ الأخبار محلياً فقط على الجهاز (بدون تسجيل دخول، وبدون تخزين حفظ الأخبار في Supabase).

---

## 2) النطاق العام (Scope)

### داخل النطاق
- تطبيق Flutter Mobile (Android/iOS).
- Flutter Web Dashboard للإدارة.
- Supabase كخلفية بيانات للأخبار/الفئات/الفيديو/البث/الإعدادات.
- Firebase Cloud Messaging (FCM) للإشعارات العاجلة.
- دعم RTL عربي أولاً.
- دعم Light / Dark theme.
- دعم AR/EN لاحقاً.

### خارج النطاق حالياً
- نظام تسجيل دخول للمستخدمين النهائيين داخل تطبيق الأخبار.
- مزامنة الأخبار المحفوظة عبر حساب مستخدم.

---

## 3) الأهداف الرئيسية

- بناء تجربة قراءة أخبار سريعة وواضحة ومتوافقة مع هوية القناة.
- تقديم إدارة محتوى مرنة بالكامل عبر Dashboard.
- دعم الأخبار العاجلة، البث المباشر، الفيديوهات، والأقسام.
- ترتيب الأخبار دائماً من الأحدث إلى الأقدم.
- توفير حفظ أخبار Offline محلي.
- تنفيذ المشروع ضمن إطار 20 يوم عمل (خطة مكثفة).

---

## 4) التقنيات المعتمدة

- Frontend Mobile: Flutter (Dart)
- Frontend Dashboard: Flutter Web
- Backend/Data: Supabase (PostgreSQL + Storage + Edge Functions)
- Notifications: Firebase Cloud Messaging (FCM)
- Video/Live: YouTube URLs (عرض داخل التطبيق)

---

## 5) متطلبات UI/UX النهائية المتفق عليها

## 5.1 الهوية البصرية
- الألوان الأساسية: Turquoise + White + Dark Gray.
- ألوان مساعدة: شريط العاجل (أحمر/برتقالي خفيف).
- خطوط عربية واضحة: Cairo أو Tajawal.

## 5.2 AppBar (الرئيسية)
- الزاوية اليمنى: شعار القناة + اسم "الإخبارية السورية".
- الزاوية اليسرى: أيقونة البحث + أيقونة Drawer.
- AppBar ثابت أعلى الشاشة.

## 5.3 Drawer
- يظهر من جهة RTL.
- يحتوي:
  - عناصر تنقل: البث المباشر، الإشعارات، الأخبار المحفوظة، الفيديوهات، **البرامج**، أحدث الأخبار.
  - قسم **شاركنا الخبر** (Citizen Journalism): نموذج لإرسال تقارير/صور/فيديو من المواطنين.
  - إعدادات: تغيير الثيم، تغيير اللغة.
  - روابط التواصل الاجتماعي (Facebook, Telegram, Instagram, X, YouTube).
  - **التاريخ والتوقيت الحاليان** (هجري/ميلادي + الوقت المباشر).

## 5.4 الشاشة الرئيسية
1. شريط أخبار عاجلة متحرك (Ticker).
2. شريط فئات أفقي قابل للتمرير (تصفية سريعة).
3. سلايدر الأخبار الرئيسية Featured — يعرض حتى 5 أخبار مميزة يتم تعيينها يدويًا عبر `is_featured=true` من الداشبورد. إذا لم يقم المشرف بتعيين أي خبر مميز، يعرض السلايدر أحدث 5 أخبار تلقائيًا.
  - السلايدر يدور تلقائيًا بفاصل زمني قابل للضبط من الإعدادات (الافتراضي: 3 ثوانٍ).
4. قسم فيديوهات أفقي مع زر "عرض الكل".
5. قسم **أحدث الأخبار** (قائمة عمودية لا نهائية) ليشمل كل شيء، مرتب زمنياً.

## 5.5 شاشة الفئات (مدمجة)
- عند الضغط على فئة، يتحول المحتوى إلى Grid عمودين لعرض أخبار الفئة.
- الترتيب: من الأحدث إلى الأقدم.

## 5.6 شاشة تفاصيل الخبر
- صورة كبيرة أعلى الصفحة.
- أزرار مشاركة.
- أزرار تكبير/تصغير الخط (A-, A, A+).
- عنوان الخبر + وسم الفئة + الموقع + تاريخ النشر.
- محتوى الخبر Rich Text.
- أخبار متعلقة من نفس الفئة.
- زر حفظ الخبر (Bookmark).

## 5.7 شاشة الفيديوهات
- قائمة عمودية لكل الفيديوهات (الأحدث للأقدم).
- بطاقة: صورة مصغرة + أيقونة تشغيل + عنوان + تاريخ.

## 5.8 شاشة البث المباشر
- مشغل YouTube داخل التطبيق.
- حالة البث (مفعل/غير مفعل) من الداشبورد.

## 5.9 لا يوجد Bottom Navigation
- التنقل الرئيسي عبر AppBar + Drawer + شريط الفئات.

---

## 6) ميزات UX محسنة (معتمدة)

- Shimmer Loading بدل التحميل التقليدي.
- Pull-to-Refresh.
- Pagination / Infinite Scroll للأخبار.
- عرض تاريخ نسبي (منذ ساعتين...) + دعم التاريخ الكامل.
- دعم Offline لعرض الأخبار المحفوظة محلياً.
- Banner لحالة الاتصال (اختياري).
- Search سريع في الأخبار.
- تمييز الفئة النشطة في شريط الفئات.

ميزات اختيارية لاحقة:
- TTS قراءة الخبر صوتياً.
- شريط تقدم القراءة في تفاصيل الخبر.
- Picture-in-Picture للبث (حسب دعم المنصة).

---

## 7) لوحة التحكم (Flutter Web Dashboard)

## 7.1 تسجيل الدخول
- دخول إداري عبر Supabase Auth.

## 7.2 Sidebar
- الأقسام:
  - الأخبار الرئيسية
  - الأخبار العاجلة
  - شريط الأخبار
  - البث المباشر
  - الفيديوهات
  - البرامج
  - الفئات
  - المواقع الجغرافية
  - الإعدادات

## 7.3 إدارة الأخبار الرئيسية
- جدول عرض: العنوان، الفئة، الموقع، التاريخ، حالة النشر، is_hidden، is_featured، view_count.
- عمليات CRUD + أرشفة + استعادة.
- نموذج خبر:
  - title
  - summary
  - content (Rich Text)
  - image upload
  - category
  - location
  - publish date
  - is_hidden
  - is_featured
  - pin_to_top (تثبيت أعلى القسم)
  - allow_comments (اختياري)
  - seo_slug
  - tags

### خصائص إضافية للأخبار الرئيسية (غير الإخفاء والحذف)
- نشر فوري أو جدولة النشر عبر publish date.
- تثبيت الخبر أعلى القسم عبر pin_to_top.
- تمييز الخبر كسلايدر رئيسي عبر is_featured.
- السلوك الافتراضي للسلايدر: يعرض حتى 5 عناصر حيث `is_featured=true`، ويمكن ضبط تبديل العرض الآلي عبر الإعدادات.
- أرشفة الخبر دون فقد البيانات (archive/unarchive).
- نسخ الخبر (Duplicate) لإنشاء نسخة تحريرية بسرعة.
- معاينة الخبر قبل النشر (Preview).
- عداد مشاهدات view_count مع إمكانية إعادة الضبط (للإدارة فقط).
- تتبع آخر تعديل (modified_at / modified_by).

## 7.4 إدارة الأخبار العاجلة
- CRUD + start_time + end_time + priority.
- خيار `send_notification` (checkbox):
  - مفعّل افتراضياً (True).
  - عند الحفظ: إذا كان True، يتم إرسال إشعار FCM فوراً.
  - إذا كان False، ينشر الخبر على الشريط فقط دون إزعاج المستخدمين.
- حالة لحظية: (نشط / منتهي / قادم) وفق الوقت الحالي.
- إعداد وقت النشر ووقت الإخفاء التلقائي.
- خيار تثبيت الخبر العاجل أعلى شريط العاجل.

### إعداد الوقت للخبر العاجل (مهم)
- start_time: لحظة بدء الظهور في التطبيق.
- end_time: لحظة انتهاء الظهور تلقائياً.
- إذا الوقت الحالي < start_time: الحالة "قادم".
- إذا start_time <= الوقت الحالي <= end_time: الحالة "نشط".
- إذا الوقت الحالي > end_time: الحالة "منتهي" (ويختفي تلقائياً من واجهة المستخدم).

## 7.5 إدارة شريط الأخبار
- نص الشريط + is_active + priority + linked_news_id (اختياري).
- إعادة ترتيب عناصر الشريط بالسحب والإفلات.

## 7.6 إدارة البث المباشر
- youtube_url + is_active + broadcast_title + fallback_message + حفظ.

## 7.7 إدارة الفيديوهات
- **يرفع فقط**: عنوان الفيديو + رابط YouTube (+ فئة اختيارية).
- التطبيق يستخرج العرض عبر الرابط داخل واجهة الفيديو.
- خصائص إضافية: صورة غلاف اختيارية، تاريخ نشر، ترتيب، إخفاء مؤقت.

## 7.8 إدارة البرامج
- قائمة البرامج (اسم البرنامج، عدد الحلقات، الترتيب، الحالة).
- إضافة/تعديل برنامج: name + description + image_url + order_index + is_active.
- داخل كل برنامج: إدارة حلقاته (فيديوهات البرنامج) عبر:
  - title
  - youtube_url
  - published_at
  - order_index
  - is_hidden
- كل حلقة تُعرض في شاشة البرنامج داخل التطبيق.

## 7.9 إدارة الفئات والمواقع
- فئات + ترشعارات اليدوية (جديد)
- قسم خاص لإرسال إشعارات عامة غير مرتبطة بخبر محدد.
- الحقول: عنوان الإشعار، نص الإشعار، صورة (اختياري).
- زر "إرسال للكل".
- تستخدم للتنويهات الإدارية، المعايدات، أو التنبيهات العامة.

## 7.11 الإعدادات
- key/value (روابط التواصل، ترتيب الأقسام، إعدادات عامة).
- تخصيص "أقسام الصفحة الرئيسية": اختيار الفئات التي تظهر في الـ Home.
- إعدادات السلايدر المميز:
  - `featured_slider_autoplay` (boolean, default: true)
  - `featured_slider_interval_seconds` (int, default: 3)

## 7.12 الإعدادات
- key/value (روابط التواصل، ترتيب الأقسام، إعدادات عامة).

## 7.11 أين يتم عرض الأخبار العادية والعاجلة (خريطة عرض المحتوى)
- الأخبار العادية:
  - الرئيسية: ضمن "أحدث الأخبار" + السلايدر (عند is_featured=true).
  - صفحة الفئة: حسب category.
  - صفحة الموقع: حسب location (عند تفعيلها في التطبيق).
  - صفحة التفاصيل: عند فتح خبر محدد.
- الأخبار العاجلة:
  - شريط العاجل في أعلى الصفحة الرئيسية.
  - صفحة الإشعارات (عند إرسال FCM).
  - داخل تبويب الأخبار العاجلة (اختياري في التطبيق).
- الفيديوهات:
  - صفحة الفيديوهات العامة.
  - صفحة تفاصيل الفيديو/المشغل.
- البرامج:
  - من Drawer > البرامج.
  - شاشة قائمة البرامج.
  - شاشة حلقات البرنامج.

## 7.13 إدارة تقارير المواطنين (شاركنا الخبر)
- عرض قائمة التقارير المرسلة من المستخدمين.
- بيانات التقرير: الاسم، رقم الهاتف (اختياري)، نص الخبر، صور/فيديو مرفق، الموقع (إن وجد).
- إجراءات: مقروء / غير مقروء / تحويل لخبر (مسودة) / حذف.

## 7.14 سيناريوهات استخدام المشرف داخل الداشبورد
1) إضافة خبر عادي:
- يدخل "الأخبار الرئيسية" > إضافة جديد > يعبئ البيانات > حفظ كمسودة أو نشر فوري.

2) جدولة خبر عادي:
- خيار "إرسال إشعار" مفعل تلقائياً عند إنشاء الخبر العاجل.
- يمكن إرسال إشعار يدوي منفصل من قسم "الإشعارات اليدوية".

3) تفعيل خبر رئيسي في السلايدر:
- يفعّل is_featured للخبر > يظهر في Carousel في التطبيق.

4) إضافة خبر عاجل بزمن محدد:
- يدخل "الأخبار العاجلة" > يكتب العنوان/النص > يحدد start_time و end_time > حفظ.
- النظام يغيّر الحالة تلقائياً (قادم/نشط/منتهي).

5) إرسال إشعار عاجل:
- بعد حفظ الخبر العاجل يضغط "إرسال إشعار" > يصل FCM للمستخدمين.

6) إدارة البرامج:
- يدخل "البرامج" > إضافة برنامج جديد > ثم إضافة حلقات (عنوان + رابط يوتيوب).

7) إدارة الفيديوهات العامة:
- يدخل "الفيديوهات" > إضافة فيديو > العنوان + رابط يوتيوب > حفظ.

8) إيقاف البث المباشر:
- يدخل "البث المباشر" > يعطّل is_active أو يغيّر الرابط > حفظ.

---

## 8) تصميم قاعدة البيانات (Supabase)

## 8.1 الجداول الأساسية

### categories
- id (PK)
- name (text)
- slug (text)
- order_index (int)
- parent_id (FK nullable)

### locations
- id (PK)
- name (text)
- slug (text)

### news
- id (PK)
- title (text)
- summary (text)
- content (text)
- image_url (text)
- category_id (FK)
- location_id (FK)
- created_at (timestamp)
- is_hidden (boolean)
- is_featured (boolean)
- sent_notification (boolean default true)

### manual_notifications_log
- id (PK)
- title (text)
- body (text)
- sent_at (timestamp)
- created_by (uuid)
- view_count (int default 0)

### breaking_news
- id (PK)
- title (text)
- content (text)
- created_at (timestamp)
- start_time (timestamp)
- end_time (timestamp)
- send_notification (boolean default true)
- is_active (boolean)

### ticker_news
- id (PK)
- text (text)
- priority (int default 0)
- linked_news_id (FK nullable)
- is_active (boolean)
- created_at (timestamp)

### live_stream
- id (PK)
- broadcast_title (text nullable)
- youtube_url (text)
- fallback_message (text nullable)
- is_active (boolean)

### videos
- id (PK)
- title (text)
- youtube_url (text)
- program_id (FK nullable)
- category_id (FK nullable)
- thumbnail_url (text nullable)
- order_index (int default 0)
- published_at (timestamp nullable)
- created_at (timestamp)
- is_hidden (boolean)

### programs
- id (PK)
- name (text)
- description (text nullable)
- image_url (text nullable)
- order_index (int default 0)
- is_active (boolean default true)
- created_at (timestamp)
# user_reports
- id (PK)
- name (text nullable)
- phone (text nullable)
- message (text)
- attachment_url (text nullable)
- created_at (timestamp)
- is_reviewed (boolean default false)

##
### app_settings
- key (PK text)
- value (text)

## 8.2 ملاحظة مهمة حول حفظ الأخبار
- **لا نستخدم جدول saved_news في Supabase حالياً**.
- سبب ذلك: لا يوجد تسجيل دخول للمستخدمين.
- حفظ الأخبار يتم محلياً فقط على الجهاز.

## 8.3 RLS
- Public Read للجداول المعروضة للمستخدم.
- صلاحيات كتابة للإدمن فقط عبر Dashboard/Auth.

---

## 9) آلية حفظ الأخبار محلياً (بدون تسجيل دخول)

المطلوب: المستخدم يحفظ الأخبار داخل جهازه فقط.

الآلية المقترحة:
- Local DB: Hive أو Isar.
- عند الضغط على حفظ:
  - نخزن نسخة خبر مبسطة محلياً (id/title/image/summary/content/date/category/location).
- شاشة "الأخبار المحفوظة" تقرأ من Local DB مباشرة.
- تعمل حتى بدون إنترنت.

### نموذج بيانات محلي مقترح
- local_id
- news_id
- title
- image_url
- summary
- content
- category_name
- location_name
- published_at
- saved_at

---

## 10) منطق الفيديو والبث (YouTube)

- الداشبورد يدخل: title + youtube_url.
- التطبيق يعرض Thumbnail + Title + مشغل YouTube داخل الشاشة.
- البث المباشر يعتمد على live_stream.youtube_url المفعّل.
- البرامج تعتمد على جدول programs، وكل برنامج يحتوي حلقات من جدول videos عبر program_id.

---

## 11) سيناريوهات المستخدم (Mobile)

1. فتح التطبيق → الرئيسية.
2. متابعة شريط العاجل.
3. اختيار فئة → Grid أخبار الفئة.
4. فتح خبر → قراءة + تغيير حجم خط + مشاركة.
5. حفظ خبر → يظهر في الأخبار المحفوظة.
6. فتح Drawer → رؤية التاريخ/الوقت الحالي + التنقل.
7. فتح الفيديوهات → تشغيل فيديو.
8. فتح البث المباشر → YouTube player.
9. فتح الإشعارات → سجل التنبيهات.
10. بدون إنترنت → قراءة المحفوظات المحلية.

---

## 12) سيناريوهات المشرف (Dashboard)

1. تسجيل الدخول.
2. إضافة خبر جديد (نص + صورة + فئة + موقع).
3. تمييز خبر كـ Featured.
4. إخفاء خبر مؤقتاً عبر is_hidden.
5. إضافة خبر عاجل مع مدة زمنية.
6. إرسال إشعار FCM للخبر العاجل.
7. تحديث رابط البث المباشر.
8. إضافة فيديو عام (عنوان + رابط YouTube).
9. إضافة برنامج جديد ثم إضافة حلقات البرنامج (عنوان + رابط YouTube).
10. جدولة نشر خبر عادي/عاجل وإدارة حالته الزمنية.
11. تعديل الفئات/المواقع.
12. ضبط إعدادات عامة.

---

## 13) خطة التنفيذ الزمنية (20 يوم)

### الأيام 1-3
- تهيئة المشروع والبنية والتنقل والثيم.
- إعداد Supabase وربط التطبيق.

### الأيام 4-7
- تنفيذ Home + AppBar + Drawer + Ticker + Categories + Carousel.

### الأيام 8-11
- تفاصيل الخبر + الفيديوهات + البث + البحث + الإشعارات + المحفوظات.

### الأيام 12-14
- تحسين الأداء + Offline + view_count + FCM.

### الأيام 15-18
- تنفيذ Dashboard كامل (CRUD لكل الأقسام).

### الأيام 19-20
- QA + اختبار RTL + تحسينات نهائية + تجهيز النشر.

---

## 14) الحزم المقترحة (Flutter)

- supabase_flutter
- firebase_messaging
- go_router
- flutter_bloc أو riverpod
- cached_network_image
- hive_flutter أو isar
- youtube_player_flutter
- flutter_html
- marquee
- shimmer
- share_plus
- connectivity_plus
- intl
- google_fonts

---

## 15) متطلبات الجودة (Definition of Done)

- تطابق بصري واضح مع هوية القناة.
- AppBar و Drawer مطابقان للتوجيهات المعتمدة.
- التاريخ والوقت يظهران داخل Drawer.
- الفيديو والبث يعتمدان على YouTube URL من الداشبورد.
- حفظ الأخبار يعمل محلياً بدون تسجيل دخول.
- ترتيب الأخبار: الأحدث أولاً.
- لوحة التحكم تمكّن إدارة كاملة للمحتوى.

---

## 16) برومت تصميم مختصر جاهز للاستخدام في Stitch

Use this as a base prompt in Stitch:

"Design a professional RTL Arabic Flutter mobile news app for 'Alikhbariah Syria' with turquoise, white, and dark gray branding. Home AppBar: right side channel logo + app name 'الإخبارية السورية'; left side search icon + drawer icon. Drawer must show current date/time at top, then menu items: Live Stream, Notifications, Saved News, Videos, Latest News; include theme and language controls and social icons at bottom. Home includes sticky breaking news ticker, horizontal categories chips, featured news carousel, videos horizontal section, latest news cards. News details screen includes large image, share row, font-size controls, title, category tag, location, date, rich article content, and related news. Include Videos screen and Live Stream screen based on YouTube links. No bottom navigation. Clean, modern, high readability Arabic UI (Cairo/Tajawal)."

---

## 17) قرارات نهائية مثبتة

- لا يوجد Bottom Navigation.
- التاريخ/الوقت داخل Drawer.
- الفيديوهات والبث من YouTube URLs عبر الداشبورد.
- إضافة قسم البرامج في Drawer وأسفله عرض قائمة البرامج وحلقاتها.
- حفظ الأخبار محلي فقط (ليس في Supabase حالياً).

---

## 18) ملاحظات للـ Agents

- هذا الملف هو المصدر الأساسي للحالة الحالية للمنتج.
- أي تعديل يجب أن يتم هنا أولاً قبل التنفيذ.
- عند تغيير المتطلبات، حدّث قسم "قرارات نهائية" + "النطاق" + "قاعدة البيانات".
