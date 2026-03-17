// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Syrian Digital Identity';

  @override
  String get welcomeTitle => 'Syrian Digital\nIdentity';

  @override
  String get welcomeSubtitle =>
      'Your verified digital identity card from your ePassport';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get continueBtn => 'Continue';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get scanPassport => 'Scan Passport';

  @override
  String get scanPassportDesc =>
      'Place the passport page with the photo within the frame';

  @override
  String get scanMRZ => 'Scan the code in your passport';

  @override
  String get mrzHint =>
      'P<SURNAMES>>FORENAMES<<<<<<<<<<<<<<<<<<\n<<<<<<S6753335464<<<<68997646<2467<<<<24';

  @override
  String get scan => 'Scan';

  @override
  String get enterManually => 'Enter passport information';

  @override
  String get readNFC => 'Read Passport Chip';

  @override
  String get readNFCDesc => 'Place your phone on top of the passport';

  @override
  String get nfcReading => 'Reading passport data...';

  @override
  String get nfcSuccess => 'Passport data read successfully!';

  @override
  String get nfcFailed => 'Failed to read passport. Please try again.';

  @override
  String get keepSteady => 'Keep your phone steady';

  @override
  String get digitalId => 'Digital ID';

  @override
  String get verifiedId => 'Verified Identity';

  @override
  String get addToWallet => 'Add to Wallet';

  @override
  String get addToAppleWallet => 'Add to Apple Wallet';

  @override
  String get addToGoogleWallet => 'Add to Google Wallet';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get documentNumber => 'Document Number';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get dateOfExpiry => 'Date of Expiry';

  @override
  String get nationality => 'Nationality';

  @override
  String get sex => 'Sex';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get name => 'Name';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get idCardNumber => 'ID Card Number';

  @override
  String get status => 'Status';

  @override
  String get verified => 'Verified';

  @override
  String get pending => 'Pending';

  @override
  String get home => 'Home';

  @override
  String get myId => 'My ID';

  @override
  String get camera => 'Camera';

  @override
  String get cameraPermission =>
      'Camera permission is required to scan your passport';

  @override
  String get nfcNotAvailable => 'NFC is not available on this device';

  @override
  String get renewedPassportNote =>
      'If your passport was renewed by hand, use the original printed data from the MRZ lines at the bottom of the passport info page.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';
}
