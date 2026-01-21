import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'accountSettings': 'إعدادات الحساب',
      'addSuggestion': 'أضف اقتراحاً',
      'alternativeDetails': 'تفاصيل البديل',
      'alternativeLoadFailed': 'تعذر تحميل تفاصيل البديل.',
      'alternatives': 'البدائل',
      'alternativesFound': 'بدائل تم العثور عليها',
      'alternativesLoadFailed': 'تعذر تحميل البدائل.',
      'anonymousUser': 'مستخدم مجهول',
      'apiDebug': 'فحص API',
      'appName': 'المقاطعة',
      'appTagline': 'اعرف المنتج واستبدله ببديل',
      'approved': 'معتمد',
      'avoid': 'مقاطعة',
      'back': 'رجوع',
      'badges': 'الشارات',
      'baseUrl': 'عنوان الأساس',
      'brands': 'العلامات التجارية',
      'browseByCategory': 'تصفح حسب الفئة',
      'category': 'الفئة',
      'categoryOptional': 'الفئة (اختياري)',
      'caution': 'تحذير',
      'city': 'المدينة',
      'claims': 'الادعاءات والأدلة',
      'community': 'المجتمع',
      'communityLoadFailed': 'تعذر تحميل الاقتراحات.',
      'communitySubtitle': 'ساهم في إثراء المجتمع',
      'communitySuggestions': 'اقتراحات المجتمع',
      'companies': 'الشركات',
      'companiesLoadFailed': 'تعذر تحميل الشركات.',
      'companyDetails': 'تفاصيل الشركة',
      'companyLoadFailed': 'تعذر تحميل تفاصيل الشركة.',
      'companyOptional': 'الشركة (اختياري)',
      'confidence': 'الثقة',
      'confirmPassword': 'تأكيد كلمة المرور',
      'createAccount': 'أنشئ حساباً جديداً',
      'createdOn': 'تم الإنشاء',
      'debugUnavailable': 'معلومات الفحص غير متاحة',
      'description': 'الوصف',
      'didYouKnow': 'هل تعلم؟',
      'discover': 'استكشاف',
      'email': 'البريد الإلكتروني',
      'error': 'حدث خطأ',
      'exactMatch': 'مطابقة تامة',
      'haveAccount': 'لديك حساب بالفعل؟',
      'health': 'الحالة',
      'home': 'الرئيسية',
      'homeTagline': 'تطبيق عربي يساعدك على معرفة المنتجات والبدائل الموثوقة.',
      'itemCount': 'عدد العناصر',
      'itemDetails': 'تفاصيل العنصر',
      'itemId': 'معرّف العنصر',
      'itemIdOptional': 'معرّف العنصر (اختياري)',
      'itemLoadFailed': 'تعذر تحميل العنصر.',
      'itemNameOptional': 'اسم المنتج (اختياري)',
      'itemStatusUnknown': 'غير معروف',
      'items': 'العناصر',
      'itemsLoadFailed': 'تعذر تحميل العناصر.',
      'language': 'اللغة',
      'lastConfirmed': 'آخر تأكيد',
      'lastReview': 'آخر مراجعة',
      'leaderboard': 'لوحة الصدارة',
      'level': 'المستوى',
      'likesGiven': 'الإعجابات',
      'linkedProducts': 'المنتجات المرتبطة',
      'liveData': 'بيانات مباشرة',
      'liveStatus': 'حالة النظام',
      'loading': 'جاري التحميل...',
      'login': 'تسجيل الدخول',
      'loginRequired': 'الرجاء تسجيل الدخول',
      'loginToContinue': 'سجّل الدخول للمتابعة',
      'logout': 'تسجيل الخروج',
      'mainSections': 'الأقسام الرئيسية',
      'markets': 'الأسواق',
      'marketsLoadFailed': 'تعذر تحميل الأسواق.',
      'moreFields': 'حقول إضافية',
      'name': 'الاسم',
      'noAccount': 'ليس لديك حساب؟',
      'noAlternativesSubtitle': 'سنعرض البدائل عند توفرها.',
      'noAlternativesTitle': 'لا توجد بدائل',
      'noCompaniesSubtitle': 'جرّب البحث بكلمة أخرى.',
      'noCompaniesTitle': 'لا توجد شركات',
      'noCompanyProductsSubtitle': 'ستظهر المنتجات هنا عند توفرها.',
      'noCompanyProductsTitle': 'لا توجد منتجات لهذه الشركة',
      'noDescription': 'لا يوجد وصف',
      'noItemsSubtitle': 'أضف عناصر في الخلفية لتظهر هنا.',
      'noItemsTitle': 'لا توجد عناصر بعد',
      'noLinkedProductsSubtitle': 'سنعرض المنتجات المرتبطة عند توفرها.',
      'noLinkedProductsTitle': 'لا توجد منتجات مرتبطة',
      'noMarketsSubtitle': 'جرّب البحث بكلمة أخرى.',
      'noMarketsTitle': 'لا توجد أسواق',
      'noMatchingItemsSubtitle': 'جرّب كلمة بحث أو فئة مختلفة.',
      'noMatchingItemsTitle': 'لا توجد عناصر مطابقة',
      'noProductsSubtitle': 'جرّب البحث بكلمة أخرى أو حدّث البيانات.',
      'noProductsTitle': 'لا توجد منتجات',
      'noReportsSubtitle': 'أرسل بلاغاً ليظهر هنا.',
      'noReportsTitle': 'لا توجد بلاغات بعد',
      'noResults': 'لا توجد نتائج',
      'noSuggestionsSubtitle': 'كن أول من يضيف اقتراحاً.',
      'noSuggestionsTitle': 'لا توجد اقتراحات',
      'openMap': 'فتح الخريطة',
      'ownershipChain': 'سلسلة الملكية',
      'password': 'كلمة المرور',
      'pending': 'قيد المراجعة',
      'pointCameraAtBarcode': 'وجّه الكاميرا إلى الباركود',
      'points': 'نقاط',
      'popularSwaps': 'البدائل الأكثر شيوعاً',
      'preferred': 'مفضل',
      'productCount': 'عدد المنتجات',
      'productDetails': 'تفاصيل المنتج',
      'productLoadFailed': 'تعذر تحميل تفاصيل المنتج.',
      'productNotFound': 'المنتج غير موجود',
      'products': 'المنتجات',
      'productsAvoided': 'منتجات تم تجنّبها',
      'productsLoadFailed': 'تعذر تحميل المنتجات.',
      'profile': 'ملفي',
      'profileComplete': 'اكتمال الملف',
      'profileLoadFailed': 'تعذر تحميل الملف الشخصي.',
      'profileLoginHint': 'ادخل لحسابك لمتابعة النشاط.',
      'recentReports': 'البلاغات الأخيرة',
      'recentScans': 'عمليات المسح الأخيرة',
      'refresh': 'تحديث',
      'register': 'إنشاء حساب',
      'rejected': 'مرفوض',
      'reportFormHint': 'أدخل تفاصيل البلاغ',
      'reportReason': 'سبب البلاغ',
      'reportReasonRequired': 'يرجى إدخال سبب البلاغ',
      'reportSubmitted': 'تم إرسال البلاغ بنجاح',
      'reports': 'البلاغات',
      'reportsLoadFailed': 'تعذر تحميل البلاغات.',
      'retry': 'إعادة المحاولة',
      'scan': 'مسح',
      'scanProduct': 'امسح المنتج',
      'scans': 'عمليات مسح',
      'search': 'بحث',
      'searchAlternativesHint': 'ابحث عن بديل',
      'searchCommunityHint': 'ابحث في الاقتراحات',
      'searchCompaniesHint': 'ابحث عن شركة',
      'searchHint': 'ابحث بالاسم أو الباركود...',
      'searchItemsHint': 'ابحث في العناصر',
      'searchMarketsHint': 'ابحث عن سوق',
      'searchPlaceholder': 'ابحث عن منتج أو شركة',
      'searchProductsHint': 'ابحث عن منتج',
      'searchPrompt': 'ابحث عن منتج أو علامة',
      'selectCity': 'اختر المدينة',
      'settings': 'الإعدادات',
      'shareInfo': 'شارك هذه المعلومات',
      'signInToParticipate': 'سجّل الدخول للمشاركة في المجتمع',
      'sortNew': 'الأحدث',
      'sortTop': 'الأعلى',
      'sourceOptional': 'رابط المصدر (اختياري)',
      'sources': 'المصادر',
      'status': 'الحالة',
      'stores': 'المتاجر',
      'submissions': 'المساهمات',
      'submit': 'إرسال',
      'submitDescriptionRequired': 'يرجى إدخال الوصف',
      'submitFailed': 'تعذر إرسال الطلب',
      'submitReport': 'إرسال بلاغ',
      'submitSuccess': 'تم الإرسال بنجاح',
      'submitTitleRequired': 'يرجى إدخال العنوان',
      'suggestProduct': 'اقترح هذا المنتج',
      'suggestionText': 'نص الاقتراح',
      'suggestionTextRequired': 'يرجى كتابة الاقتراح',
      'summary': 'ملخص',
      'thisWeek': 'هذا الأسبوع',
      'title': 'العنوان',
      'tools': 'أدوات سريعة',
      'totalScans': 'إجمالي المسح',
      'trending': 'الأكثر شيوعاً',
      'tryAgain': 'حاول مجدداً',
      'uncategorized': 'غير مصنف',
      'unknown': 'غير معروف',
      'validationConfirmPasswordRequired': 'يرجى تأكيد كلمة المرور',
      'validationEmailRequired': 'يرجى إدخال البريد الإلكتروني',
      'validationNameRequired': 'يرجى إدخال الاسم',
      'validationPasswordMismatch': 'كلمتا المرور غير متطابقتين',
      'validationPasswordRequired': 'يرجى إدخال كلمة المرور',
      'verified': 'موثّق',
      'viewAll': 'عرض الكل',
      'welcome': 'مرحباً بك في المقاطعة',
      'welcomeBack': 'مرحباً بعودتك',
      'whereToBuy': 'أين تجد البدائل؟',
      'why': 'لماذا؟',
      'yourActivity': 'نشاطك',
      'yourStats': 'إحصاءاتك',
    },
    'en': {
      'accountSettings': 'Account Settings',
      'addSuggestion': 'Add suggestion',
      'alternativeDetails': 'Alternative details',
      'alternativeLoadFailed': 'Failed to load alternative details.',
      'alternatives': 'البدائل',
      'alternativesFound': 'Alternatives Found',
      'alternativesLoadFailed': 'Failed to load alternatives.',
      'anonymousUser': 'Anonymous',
      'apiDebug': 'فحص API',
      'appName': 'المقاطعة',
      'appTagline': 'Know the product... and swap it for an alternative',
      'approved': 'Approved',
      'avoid': 'مقاطعة',
      'back': 'Back',
      'badges': 'Badges',
      'baseUrl': 'عنوان الأساس',
      'brands': 'العلامات التجارية',
      'browseByCategory': 'تصفح حسب الفئة',
      'category': 'الفئة',
      'categoryOptional': 'Category (optional)',
      'caution': 'تحذير',
      'city': 'City',
      'claims': 'Claims & Evidence',
      'community': 'المجتمع',
      'communityLoadFailed': 'Failed to load suggestions.',
      'communitySubtitle': 'Join the community',
      'communitySuggestions': 'Community suggestions',
      'companies': 'Companies',
      'companiesLoadFailed': 'Failed to load companies.',
      'companyDetails': 'تفاصيل الشركة',
      'companyLoadFailed': 'Failed to load company details.',
      'companyOptional': 'Company (optional)',
      'confidence': 'الثقة',
      'confirmPassword': 'تأكيد كلمة المرور',
      'createAccount': 'أنشئ حساباً جديداً',
      'createdOn': 'Created',
      'debugUnavailable': 'معلومات الفحص غير متاحة',
      'description': 'الوصف',
      'didYouKnow': 'هل تعلم؟',
      'discover': 'استكشاف',
      'email': 'البريد الإلكتروني',
      'error': 'حدث خطأ',
      'exactMatch': 'مطابقة تامة',
      'haveAccount': 'لديك حساب بالفعل؟',
      'health': 'الحالة',
      'home': 'الرئيسية',
      'homeTagline': 'Arabic-first app for trusted products and alternatives.',
      'itemCount': 'Item count',
      'itemDetails': 'تفاصيل العنصر',
      'itemId': 'معرّف العنصر',
      'itemIdOptional': 'معرّف العنصر (اختياري)',
      'itemLoadFailed': 'تعذر تحميل العنصر.',
      'itemNameOptional': 'Item name (optional)',
      'itemStatusUnknown': 'غير معروف',
      'items': 'العناصر',
      'itemsLoadFailed': 'تعذر تحميل العناصر.',
      'language': 'Language',
      'lastConfirmed': 'Last confirmed',
      'lastReview': 'Last review',
      'leaderboard': 'Leaderboard',
      'level': 'Level',
      'likesGiven': 'Likes given',
      'linkedProducts': 'Linked products',
      'liveData': 'Live data',
      'liveStatus': 'System status',
      'loading': 'Loading...',
      'login': 'تسجيل الدخول',
      'loginRequired': 'Please sign in',
      'loginToContinue': 'Sign in to continue',
      'logout': 'تسجيل الخروج',
      'mainSections': 'Main sections',
      'markets': 'Markets',
      'marketsLoadFailed': 'Failed to load markets.',
      'moreFields': 'حقول إضافية',
      'name': 'الاسم',
      'noAccount': 'noAccount',
      'noAlternativesSubtitle': 'Alternatives will appear here when available.',
      'noAlternativesTitle': 'No alternatives',
      'noCompaniesSubtitle': 'Try a different search.',
      'noCompaniesTitle': 'No companies',
      'noCompanyProductsSubtitle': 'Products will appear here when available.',
      'noCompanyProductsTitle': 'No products for this company',
      'noDescription': 'لا يوجد وصف',
      'noItemsSubtitle': 'أضف عناصر في الخلفية لتظهر هنا.',
      'noItemsTitle': 'لا توجد عناصر بعد',
      'noLinkedProductsSubtitle': 'Linked products will appear here when available.',
      'noLinkedProductsTitle': 'No linked products',
      'noMarketsSubtitle': 'Try a different search.',
      'noMarketsTitle': 'No markets',
      'noMatchingItemsSubtitle': 'جرّب كلمة بحث أو فئة مختلفة.',
      'noMatchingItemsTitle': 'لا توجد عناصر مطابقة',
      'noProductsSubtitle': 'Try a different search or refresh.',
      'noProductsTitle': 'No products yet',
      'noReportsSubtitle': 'Submit a report to see it here.',
      'noReportsTitle': 'No reports yet',
      'noResults': 'No results found',
      'noSuggestionsSubtitle': 'Be the first to add a suggestion.',
      'noSuggestionsTitle': 'No suggestions yet',
      'openMap': 'Open map',
      'ownershipChain': 'سلسلة الملكية',
      'password': 'كلمة المرور',
      'pending': 'Pending',
      'pointCameraAtBarcode': 'وجّه الكاميرا إلى الباركود',
      'points': 'Points',
      'popularSwaps': 'البدائل الأكثر شيوعاً',
      'preferred': 'مفضل',
      'productCount': 'Product count',
      'productDetails': 'Product details',
      'productLoadFailed': 'Failed to load product details.',
      'productNotFound': 'Product Not Found',
      'products': 'المنتجات',
      'productsAvoided': 'Products Avoided',
      'productsLoadFailed': 'Failed to load products.',
      'profile': 'ملفي',
      'profileComplete': 'Profile complete',
      'profileLoadFailed': 'Failed to load profile.',
      'profileLoginHint': 'Access your account to follow activity.',
      'recentReports': 'Recent reports',
      'recentScans': 'Recent Scans',
      'refresh': 'تحديث',
      'register': 'إنشاء حساب',
      'rejected': 'Rejected',
      'reportFormHint': 'Enter report details',
      'reportReason': 'Report reason',
      'reportReasonRequired': 'Please enter a reason',
      'reportSubmitted': 'تم إرسال البلاغ بنجاح',
      'reports': 'البلاغات',
      'reportsLoadFailed': 'Failed to load reports.',
      'retry': 'إعادة المحاولة',
      'scan': 'مسح',
      'scanProduct': 'Scan Product',
      'scans': 'scans',
      'search': 'Search',
      'searchAlternativesHint': 'Search alternatives',
      'searchCommunityHint': 'Search suggestions',
      'searchCompaniesHint': 'Search companies',
      'searchHint': 'ابحث بالاسم أو الباركود...',
      'searchItemsHint': 'ابحث في العناصر',
      'searchMarketsHint': 'Search markets',
      'searchPlaceholder': 'ابحث عن منتج أو شركة',
      'searchProductsHint': 'Search products',
      'searchPrompt': 'Search for a product or brand',
      'selectCity': 'Select City',
      'settings': 'Settings',
      'shareInfo': 'شارك هذه المعلومات',
      'signInToParticipate': 'سجّل الدخول للمشاركة في المجتمع',
      'sortNew': 'New',
      'sortTop': 'Top',
      'sourceOptional': 'Source URL (optional)',
      'sources': 'Sources',
      'status': 'الحالة',
      'stores': 'Stores',
      'submissions': 'Submissions',
      'submit': 'إرسال',
      'submitDescriptionRequired': 'Please enter a description',
      'submitFailed': 'Submission failed',
      'submitReport': 'إرسال بلاغ',
      'submitSuccess': 'تم الإرسال بنجاح',
      'submitTitleRequired': 'Please enter a title',
      'suggestProduct': 'Suggest this product',
      'suggestionText': 'Suggestion text',
      'suggestionTextRequired': 'Please enter a suggestion',
      'summary': 'ملخص',
      'thisWeek': 'This Week',
      'title': 'Title',
      'tools': 'Quick tools',
      'totalScans': 'Total Scans',
      'trending': 'Trending',
      'tryAgain': 'Try again',
      'uncategorized': 'غير مصنف',
      'unknown': 'غير معروف',
      'validationConfirmPasswordRequired': 'يرجى تأكيد كلمة المرور',
      'validationEmailRequired': 'يرجى إدخال البريد الإلكتروني',
      'validationNameRequired': 'يرجى إدخال الاسم',
      'validationPasswordMismatch': 'كلمتا المرور غير متطابقتين',
      'validationPasswordRequired': 'يرجى إدخال كلمة المرور',
      'verified': 'Verified',
      'viewAll': 'View all',
      'welcome': 'Welcome to Boycott',
      'welcomeBack': 'مرحباً بعودتك',
      'whereToBuy': 'أين تجد البدائل؟',
      'why': 'لماذا؟',
      'yourActivity': 'Your activity',
      'yourStats': 'Your Stats',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get discover => _localizedValues[locale.languageCode]!['discover']!;
  String get community => _localizedValues[locale.languageCode]!['community']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get scan => _localizedValues[locale.languageCode]!['scan']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get searchHint => _localizedValues[locale.languageCode]!['searchHint']!;
  String get scanProduct => _localizedValues[locale.languageCode]!['scanProduct']!;
  String get pointCameraAtBarcode => _localizedValues[locale.languageCode]!['pointCameraAtBarcode']!;
  String get recentScans => _localizedValues[locale.languageCode]!['recentScans']!;
  String get trending => _localizedValues[locale.languageCode]!['trending']!;
  String get alternatives => _localizedValues[locale.languageCode]!['alternatives']!;
  String get why => _localizedValues[locale.languageCode]!['why']!;
  String get ownershipChain => _localizedValues[locale.languageCode]!['ownershipChain']!;
  String get whereToBuy => _localizedValues[locale.languageCode]!['whereToBuy']!;
  String get shareInfo => _localizedValues[locale.languageCode]!['shareInfo']!;
  String get avoid => _localizedValues[locale.languageCode]!['avoid']!;
  String get caution => _localizedValues[locale.languageCode]!['caution']!;
  String get preferred => _localizedValues[locale.languageCode]!['preferred']!;
  String get unknown => _localizedValues[locale.languageCode]!['unknown']!;
  String get confidence => _localizedValues[locale.languageCode]!['confidence']!;
  String get status => _localizedValues[locale.languageCode]!['status']!;
  String get lastReview => _localizedValues[locale.languageCode]!['lastReview']!;
  String get exactMatch => _localizedValues[locale.languageCode]!['exactMatch']!;
  String get claims => _localizedValues[locale.languageCode]!['claims']!;
  String get sources => _localizedValues[locale.languageCode]!['sources']!;
  String get brands => _localizedValues[locale.languageCode]!['brands']!;
  String get products => _localizedValues[locale.languageCode]!['products']!;
  String get stores => _localizedValues[locale.languageCode]!['stores']!;
  String get lastConfirmed => _localizedValues[locale.languageCode]!['lastConfirmed']!;
  String get openMap => _localizedValues[locale.languageCode]!['openMap']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword => _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get city => _localizedValues[locale.languageCode]!['city']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get yourStats => _localizedValues[locale.languageCode]!['yourStats']!;
  String get totalScans => _localizedValues[locale.languageCode]!['totalScans']!;
  String get thisWeek => _localizedValues[locale.languageCode]!['thisWeek']!;
  String get productsAvoided => _localizedValues[locale.languageCode]!['productsAvoided']!;
  String get alternativesFound => _localizedValues[locale.languageCode]!['alternativesFound']!;
  String get badges => _localizedValues[locale.languageCode]!['badges']!;
  String get submissions => _localizedValues[locale.languageCode]!['submissions']!;
  String get leaderboard => _localizedValues[locale.languageCode]!['leaderboard']!;
  String get level => _localizedValues[locale.languageCode]!['level']!;
  String get points => _localizedValues[locale.languageCode]!['points']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get viewAll => _localizedValues[locale.languageCode]!['viewAll']!;
  String get noResults => _localizedValues[locale.languageCode]!['noResults']!;
  String get productNotFound => _localizedValues[locale.languageCode]!['productNotFound']!;
  String get suggestProduct => _localizedValues[locale.languageCode]!['suggestProduct']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get selectCity => _localizedValues[locale.languageCode]!['selectCity']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get appTagline => _localizedValues[locale.languageCode]!['appTagline']!;
  String get noAccount => _localizedValues[locale.languageCode]!['noAccount']!;
  String get haveAccount => _localizedValues[locale.languageCode]!['haveAccount']!;
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack']!;
  String get createAccount => _localizedValues[locale.languageCode]!['createAccount']!;
  String get browseByCategory => _localizedValues[locale.languageCode]!['browseByCategory']!;
  String get didYouKnow => _localizedValues[locale.languageCode]!['didYouKnow']!;
  String get signInToParticipate => _localizedValues[locale.languageCode]!['signInToParticipate']!;
  String get submit => _localizedValues[locale.languageCode]!['submit']!;
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  String get approved => _localizedValues[locale.languageCode]!['approved']!;
  String get rejected => _localizedValues[locale.languageCode]!['rejected']!;
  String get popularSwaps => _localizedValues[locale.languageCode]!['popularSwaps']!;
  String get accountSettings => _localizedValues[locale.languageCode]!['accountSettings']!;
  String get scans => _localizedValues[locale.languageCode]!['scans']!;
  String get items => _localizedValues[locale.languageCode]!['items']!;
  String get itemDetails => _localizedValues[locale.languageCode]!['itemDetails']!;
  String get searchItemsHint => _localizedValues[locale.languageCode]!['searchItemsHint']!;
  String get noItemsTitle => _localizedValues[locale.languageCode]!['noItemsTitle']!;
  String get noItemsSubtitle => _localizedValues[locale.languageCode]!['noItemsSubtitle']!;
  String get noMatchingItemsTitle => _localizedValues[locale.languageCode]!['noMatchingItemsTitle']!;
  String get noMatchingItemsSubtitle => _localizedValues[locale.languageCode]!['noMatchingItemsSubtitle']!;
  String get noDescription => _localizedValues[locale.languageCode]!['noDescription']!;
  String get uncategorized => _localizedValues[locale.languageCode]!['uncategorized']!;
  String get summary => _localizedValues[locale.languageCode]!['summary']!;
  String get itemId => _localizedValues[locale.languageCode]!['itemId']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get moreFields => _localizedValues[locale.languageCode]!['moreFields']!;
  String get reports => _localizedValues[locale.languageCode]!['reports']!;
  String get submitReport => _localizedValues[locale.languageCode]!['submitReport']!;
  String get reportSubmitted => _localizedValues[locale.languageCode]!['reportSubmitted']!;
  String get recentReports => _localizedValues[locale.languageCode]!['recentReports']!;
  String get noReportsTitle => _localizedValues[locale.languageCode]!['noReportsTitle']!;
  String get noReportsSubtitle => _localizedValues[locale.languageCode]!['noReportsSubtitle']!;
  String get createdOn => _localizedValues[locale.languageCode]!['createdOn']!;
  String get apiDebug => _localizedValues[locale.languageCode]!['apiDebug']!;
  String get health => _localizedValues[locale.languageCode]!['health']!;
  String get itemCount => _localizedValues[locale.languageCode]!['itemCount']!;
  String get baseUrl => _localizedValues[locale.languageCode]!['baseUrl']!;
  String get debugUnavailable => _localizedValues[locale.languageCode]!['debugUnavailable']!;
  String get itemsLoadFailed => _localizedValues[locale.languageCode]!['itemsLoadFailed']!;
  String get itemLoadFailed => _localizedValues[locale.languageCode]!['itemLoadFailed']!;
  String get reportsLoadFailed => _localizedValues[locale.languageCode]!['reportsLoadFailed']!;
  String get submitTitleRequired => _localizedValues[locale.languageCode]!['submitTitleRequired']!;
  String get submitDescriptionRequired => _localizedValues[locale.languageCode]!['submitDescriptionRequired']!;
  String get searchPrompt => _localizedValues[locale.languageCode]!['searchPrompt']!;
  String get communitySubtitle => _localizedValues[locale.languageCode]!['communitySubtitle']!;
  String get liveData => _localizedValues[locale.languageCode]!['liveData']!;
  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get categoryOptional => _localizedValues[locale.languageCode]!['categoryOptional']!;
  String get itemIdOptional => _localizedValues[locale.languageCode]!['itemIdOptional']!;
  String get companyDetails => _localizedValues[locale.languageCode]!['companyDetails']!;
  String get submitSuccess => _localizedValues[locale.languageCode]!['submitSuccess']!;
  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;
  String get validationEmailRequired => _localizedValues[locale.languageCode]!['validationEmailRequired']!;
  String get validationPasswordRequired => _localizedValues[locale.languageCode]!['validationPasswordRequired']!;
  String get validationNameRequired => _localizedValues[locale.languageCode]!['validationNameRequired']!;
  String get validationConfirmPasswordRequired =>
      _localizedValues[locale.languageCode]!['validationConfirmPasswordRequired']!;
  String get validationPasswordMismatch => _localizedValues[locale.languageCode]!['validationPasswordMismatch']!;
  String get searchPlaceholder => _localizedValues[locale.languageCode]!['searchPlaceholder']!;
  String get itemStatusUnknown => _localizedValues[locale.languageCode]!['itemStatusUnknown']!;
  String get reportFormHint => _localizedValues[locale.languageCode]!['reportFormHint']!;
  String get liveStatus => _localizedValues[locale.languageCode]!['liveStatus']!;
  String get addSuggestion => _localizedValues[locale.languageCode]!['addSuggestion']!;
  String get alternativeDetails => _localizedValues[locale.languageCode]!['alternativeDetails']!;
  String get alternativeLoadFailed => _localizedValues[locale.languageCode]!['alternativeLoadFailed']!;
  String get alternativesLoadFailed => _localizedValues[locale.languageCode]!['alternativesLoadFailed']!;
  String get anonymousUser => _localizedValues[locale.languageCode]!['anonymousUser']!;
  String get communityLoadFailed => _localizedValues[locale.languageCode]!['communityLoadFailed']!;
  String get communitySuggestions => _localizedValues[locale.languageCode]!['communitySuggestions']!;
  String get companies => _localizedValues[locale.languageCode]!['companies']!;
  String get companiesLoadFailed => _localizedValues[locale.languageCode]!['companiesLoadFailed']!;
  String get companyLoadFailed => _localizedValues[locale.languageCode]!['companyLoadFailed']!;
  String get companyOptional => _localizedValues[locale.languageCode]!['companyOptional']!;
  String get homeTagline => _localizedValues[locale.languageCode]!['homeTagline']!;
  String get itemNameOptional => _localizedValues[locale.languageCode]!['itemNameOptional']!;
  String get likesGiven => _localizedValues[locale.languageCode]!['likesGiven']!;
  String get linkedProducts => _localizedValues[locale.languageCode]!['linkedProducts']!;
  String get loginRequired => _localizedValues[locale.languageCode]!['loginRequired']!;
  String get loginToContinue => _localizedValues[locale.languageCode]!['loginToContinue']!;
  String get mainSections => _localizedValues[locale.languageCode]!['mainSections']!;
  String get markets => _localizedValues[locale.languageCode]!['markets']!;
  String get marketsLoadFailed => _localizedValues[locale.languageCode]!['marketsLoadFailed']!;
  String get noAlternativesSubtitle => _localizedValues[locale.languageCode]!['noAlternativesSubtitle']!;
  String get noAlternativesTitle => _localizedValues[locale.languageCode]!['noAlternativesTitle']!;
  String get noCompaniesSubtitle => _localizedValues[locale.languageCode]!['noCompaniesSubtitle']!;
  String get noCompaniesTitle => _localizedValues[locale.languageCode]!['noCompaniesTitle']!;
  String get noCompanyProductsSubtitle => _localizedValues[locale.languageCode]!['noCompanyProductsSubtitle']!;
  String get noCompanyProductsTitle => _localizedValues[locale.languageCode]!['noCompanyProductsTitle']!;
  String get noLinkedProductsSubtitle => _localizedValues[locale.languageCode]!['noLinkedProductsSubtitle']!;
  String get noLinkedProductsTitle => _localizedValues[locale.languageCode]!['noLinkedProductsTitle']!;
  String get noMarketsSubtitle => _localizedValues[locale.languageCode]!['noMarketsSubtitle']!;
  String get noMarketsTitle => _localizedValues[locale.languageCode]!['noMarketsTitle']!;
  String get noProductsSubtitle => _localizedValues[locale.languageCode]!['noProductsSubtitle']!;
  String get noProductsTitle => _localizedValues[locale.languageCode]!['noProductsTitle']!;
  String get noSuggestionsSubtitle => _localizedValues[locale.languageCode]!['noSuggestionsSubtitle']!;
  String get noSuggestionsTitle => _localizedValues[locale.languageCode]!['noSuggestionsTitle']!;
  String get productCount => _localizedValues[locale.languageCode]!['productCount']!;
  String get productDetails => _localizedValues[locale.languageCode]!['productDetails']!;
  String get productLoadFailed => _localizedValues[locale.languageCode]!['productLoadFailed']!;
  String get productsLoadFailed => _localizedValues[locale.languageCode]!['productsLoadFailed']!;
  String get profileComplete => _localizedValues[locale.languageCode]!['profileComplete']!;
  String get profileLoadFailed => _localizedValues[locale.languageCode]!['profileLoadFailed']!;
  String get profileLoginHint => _localizedValues[locale.languageCode]!['profileLoginHint']!;
  String get reportReason => _localizedValues[locale.languageCode]!['reportReason']!;
  String get reportReasonRequired => _localizedValues[locale.languageCode]!['reportReasonRequired']!;
  String get searchAlternativesHint => _localizedValues[locale.languageCode]!['searchAlternativesHint']!;
  String get searchCommunityHint => _localizedValues[locale.languageCode]!['searchCommunityHint']!;
  String get searchCompaniesHint => _localizedValues[locale.languageCode]!['searchCompaniesHint']!;
  String get searchMarketsHint => _localizedValues[locale.languageCode]!['searchMarketsHint']!;
  String get searchProductsHint => _localizedValues[locale.languageCode]!['searchProductsHint']!;
  String get sortNew => _localizedValues[locale.languageCode]!['sortNew']!;
  String get sortTop => _localizedValues[locale.languageCode]!['sortTop']!;
  String get sourceOptional => _localizedValues[locale.languageCode]!['sourceOptional']!;
  String get submitFailed => _localizedValues[locale.languageCode]!['submitFailed']!;
  String get suggestionText => _localizedValues[locale.languageCode]!['suggestionText']!;
  String get suggestionTextRequired => _localizedValues[locale.languageCode]!['suggestionTextRequired']!;
  String get tools => _localizedValues[locale.languageCode]!['tools']!;
  String get verified => _localizedValues[locale.languageCode]!['verified']!;
  String get yourActivity => _localizedValues[locale.languageCode]!['yourActivity']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

