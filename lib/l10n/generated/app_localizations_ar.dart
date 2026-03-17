// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الهوية الرقمية السورية';

  @override
  String get welcomeTitle => 'الهوية الرقمية\nالسورية';

  @override
  String get welcomeSubtitle =>
      'بطاقة هويتك الرقمية الموثقة من جواز سفرك الإلكتروني';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get scanPassport => 'مسح الجواز';

  @override
  String get scanPassportDesc =>
      'ضع صفحة الجواز التي تحتوي على الصورة ضمن الإطار';

  @override
  String get scanMRZ => 'امسح الرمز في جوازك';

  @override
  String get mrzHint =>
      'P<SURNAMES>>FORENAMES<<<<<<<<<<<<<<<<<<\n<<<<<<S6753335464<<<<68997646<2467<<<<24';

  @override
  String get scan => 'مسح';

  @override
  String get enterManually => 'أدخل معلومات الجواز يدوياً';

  @override
  String get readNFC => 'قراءة شريحة الجواز';

  @override
  String get readNFCDesc => 'ضع هاتفك فوق الجواز';

  @override
  String get nfcReading => 'جاري قراءة بيانات الجواز...';

  @override
  String get nfcSuccess => 'تمت قراءة بيانات الجواز بنجاح!';

  @override
  String get nfcFailed => 'فشلت قراءة الجواز. حاول مرة أخرى.';

  @override
  String get keepSteady => 'حافظ على ثبات هاتفك';

  @override
  String get digitalId => 'الهوية الرقمية';

  @override
  String get verifiedId => 'هوية موثقة';

  @override
  String get addToWallet => 'إضافة للمحفظة';

  @override
  String get addToAppleWallet => 'إضافة لمحفظة أبل';

  @override
  String get addToGoogleWallet => 'إضافة لمحفظة جوجل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get documentNumber => 'رقم الوثيقة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get dateOfExpiry => 'تاريخ الانتهاء';

  @override
  String get nationality => 'الجنسية';

  @override
  String get sex => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get name => 'الاسم';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get idCardNumber => 'رقم البطاقة';

  @override
  String get status => 'الحالة';

  @override
  String get verified => 'موثّق';

  @override
  String get pending => 'قيد المراجعة';

  @override
  String get home => 'الرئيسية';

  @override
  String get myId => 'هويتي';

  @override
  String get camera => 'الكاميرا';

  @override
  String get cameraPermission => 'يجب السماح بالوصول للكاميرا لمسح جوازك';

  @override
  String get nfcNotAvailable => 'خاصية NFC غير متوفرة على هذا الجهاز';

  @override
  String get renewedPassportNote =>
      'إذا تم تجديد جوازك يدوياً، استخدم البيانات المطبوعة الأصلية من سطور MRZ في أسفل صفحة معلومات الجواز.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get loading => 'جاري التحميل...';
}
