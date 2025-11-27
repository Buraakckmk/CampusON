import 'package:flutter/material.dart';

/// Supported application languages
enum AppLanguage { tr, en }

/// Global language notifier so the whole app can rebuild when language changes.
class AppLanguageController {
  static final ValueNotifier<AppLanguage> languageNotifier =
      ValueNotifier<AppLanguage>(AppLanguage.tr);
}

/// Simple localization class holding all user-facing strings.
///
/// For now we implement a minimal set; screens will be gradually
/// migrated to use this instead of hardcoded text.
class AppStrings {
  final AppLanguage lang;

  const AppStrings(this.lang);

  // General
  String get appName => 'CampusON';

  // Welcome / Auth
  String get welcomeLoginButton =>
      lang == AppLanguage.tr ? 'Giriş Yap' : 'Login';
  String get welcomeRegisterButton =>
      lang == AppLanguage.tr ? 'Kayıt Ol' : 'Sign Up';

  // Login
  String get loginEmailHint => lang == AppLanguage.tr
      ? 'Email (@universite.edu.tr)'
      : 'Email (@university.edu)';
  String get loginPasswordHint =>
      lang == AppLanguage.tr ? 'Şifre' : 'Password';
  String get loginForgotPassword =>
      lang == AppLanguage.tr ? 'Şifremi Unuttum?' : 'Forgot Password?';
  String get loginButton =>
      lang == AppLanguage.tr ? 'Giriş Yap' : 'Login';

  String get loginErrorFillEmailPassword => lang == AppLanguage.tr
      ? 'Lütfen email ve şifreyi girin.'
      : 'Please enter email and password.';
  String get loginErrorEduOnly => lang == AppLanguage.tr
      ? 'Sadece .edu uzantılı öğrenci mailleri ile giriş yapılabilir.'
      : 'Only .edu student emails can be used to sign in.';
  String get loginErrorGeneric => lang == AppLanguage.tr
      ? 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.'
      : 'Login failed. Please check your credentials.';
  String get loginErrorUserNotFound => lang == AppLanguage.tr
      ? 'Bu email ile kayıtlı bir hesap bulunamadı.'
      : 'No account found with this email.';
  String get loginErrorWrongPassword => lang == AppLanguage.tr
      ? 'Şifre hatalı.'
      : 'Incorrect password.';
  String get loginErrorInvalidEmail => lang == AppLanguage.tr
      ? 'Geçersiz email adresi.'
      : 'Invalid email address.';
  String get loginErrorUnexpected => lang == AppLanguage.tr
      ? 'Beklenmeyen bir hata oluştu. Daha sonra tekrar deneyin.'
      : 'An unexpected error occurred. Please try again later.';

  String get loginDialogTitleError =>
      lang == AppLanguage.tr ? 'Hatalı Giriş' : 'Login Error';
  String get dialogButtonClose =>
      lang == AppLanguage.tr ? 'Kapat' : 'Close';
  String get dialogButtonOk =>
      lang == AppLanguage.tr ? 'Tamam' : 'OK';
  String get loginDialogResendTitle =>
      lang == AppLanguage.tr ? 'Tekrar gönder' : 'Resend';
  String get loginDialogResendSuccess => lang == AppLanguage.tr
      ? 'Doğrulama maili tekrar gönderildi. Lütfen mail kutunuzu kontrol edin.'
      : 'Verification email sent again. Please check your inbox.';
  String get loginDialogResendError => lang == AppLanguage.tr
      ? 'Doğrulama maili gönderilirken bir hata oluştu. Daha sonra tekrar deneyin.'
      : 'Error while sending verification email. Please try again later.';

  // Register
  String get registerTitle =>
      lang == AppLanguage.tr ? 'KAYIT OL' : 'SIGN UP';
  String get registerNameHint =>
      lang == AppLanguage.tr ? 'Ad Soyad' : 'Full Name';
  String get registerEmailHint =>
      lang == AppLanguage.tr ? 'Email' : 'Email';
  String get registerPasswordHint =>
      lang == AppLanguage.tr ? 'Şifre' : 'Password';
  String get registerPasswordConfirmHint =>
      lang == AppLanguage.tr ? 'Şifre Tekrar' : 'Confirm Password';
  String get registerTermsText => lang == AppLanguage.tr
      ? 'Sözleşmeyi okudum, onaylıyorum.'
      : 'I have read and accept the terms.';
  String get registerCompleteButton =>
      lang == AppLanguage.tr ? 'KAYDI TAMAMLA' : 'COMPLETE SIGN UP';

  String get registerErrorFillAll => lang == AppLanguage.tr
      ? 'Lütfen tüm alanları doldurun.'
      : 'Please fill in all fields.';
  String get registerErrorEduOnly => lang == AppLanguage.tr
      ? 'Sadece .edu uzantılı öğrenci mailleri ile kayıt olunabilir.'
      : 'Only .edu student emails can be used to register.';
  String get registerErrorPasswordShort => lang == AppLanguage.tr
      ? 'Şifre en az 6 karakter olmalıdır.'
      : 'Password must be at least 6 characters.';
  String get registerErrorPasswordsNotMatch => lang == AppLanguage.tr
      ? 'Şifreler eşleşmiyor.'
      : 'Passwords do not match.';
  String get registerErrorAcceptTerms => lang == AppLanguage.tr
      ? 'Lütfen sözleşmeyi onaylayın.'
      : 'Please accept the terms.';
  String get registerErrorGeneric => lang == AppLanguage.tr
      ? 'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.'
      : 'An error occurred during registration. Please try again.';
  String get registerErrorFailed => lang == AppLanguage.tr
      ? 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.'
      : 'Registration failed. Please check your information.';
  String get registerErrorEmailInUse => lang == AppLanguage.tr
      ? 'Bu email ile zaten bir hesap var.'
      : 'An account already exists with this email.';
  String get registerErrorWeakPassword => lang == AppLanguage.tr
      ? 'Şifre çok zayıf, lütfen daha güçlü bir şifre girin.'
      : 'Password is too weak, please choose a stronger one.';
  String get registerErrorInvalidEmail => lang == AppLanguage.tr
      ? 'Geçersiz email adresi.'
      : 'Invalid email address.';
  String get registerErrorTimeout => lang == AppLanguage.tr
      ? 'Sunucuya bağlanırken zaman aşımı oluştu. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.'
      : 'Request timed out. Please check your internet connection and try again.';

  String get registerDialogTitleError =>
      lang == AppLanguage.tr ? 'Hata' : 'Error';

  // Email verification
  String get emailVerificationTitle =>
      lang == AppLanguage.tr ? 'Email Doğrulama' : 'Email Verification';
  String helloName(String name) =>
      lang == AppLanguage.tr ? 'Merhaba, $name' : 'Hi, $name';
  String verificationSentTo(String email) => lang == AppLanguage.tr
      ? '"$email" adresine bir doğrulama maili gönderdik. Lütfen mail kutunu kontrol edip linke tıkla.'
      : 'We sent a verification email to "$email". Please check your inbox and click the link.';
  String get emailVerificationStepsTitle =>
      lang == AppLanguage.tr ? 'Adımlar:' : 'Steps:';
  String get emailVerificationStep1 => lang == AppLanguage.tr
      ? '- Mail kutunu ve spam klasörünü kontrol et.'
      : '- Check your inbox and spam folder.';
  String get emailVerificationStep2 => lang == AppLanguage.tr
      ? '- "Email doğrula" linkine tıkla.'
      : '- Tap the "Verify email" link.';
  String get emailVerificationStep3 => lang == AppLanguage.tr
      ? '- Sonra bu ekrana dönüp aşağıdaki butona bas.'
      : '- Then come back to this screen and tap the button below.';
  String get emailVerificationChecking =>
      lang == AppLanguage.tr ? 'Kontrol ediliyor...' : 'Checking...';
  String get emailVerificationCheckButton => lang == AppLanguage.tr
      ? 'Doğruladım, tekrar kontrol et'
      : 'I verified, check again';
  String get emailVerificationResending =>
      lang == AppLanguage.tr ? 'Tekrar gönderiliyor...' : 'Resending...';
  String get emailVerificationResendButton =>
      lang == AppLanguage.tr ? 'Maili yeniden gönder' : 'Resend email';
  String get emailVerificationInfoTitle =>
      lang == AppLanguage.tr ? 'Bilgi' : 'Info';
  String get emailVerificationStillUnverified => lang == AppLanguage.tr
      ? 'Email adresiniz hâlâ doğrulanmamış. Lütfen mail kutunuzu kontrol edip doğrulama linkine tıklayın.'
      : 'Your email is still not verified. Please check your inbox and click the verification link.';
  String emailVerificationCheckError(Object e) => lang == AppLanguage.tr
      ? 'Doğrulama durumu kontrol edilirken bir hata oluştu: $e'
      : 'An error occurred while checking verification status: $e';
  String get emailVerificationResendSuccess => lang == AppLanguage.tr
      ? 'Doğrulama maili tekrar gönderildi. Lütfen mail kutunuzu kontrol edin.'
      : 'Verification email sent again. Please check your inbox.';
  String get emailVerificationAlreadyVerified => lang == AppLanguage.tr
      ? 'Email adresiniz zaten doğrulanmış olabilir.'
      : 'Your email might already be verified.';
  String emailVerificationResendError(Object e) => lang == AppLanguage.tr
      ? 'Doğrulama maili gönderilirken bir hata oluştu: $e'
      : 'An error occurred while resending verification email: $e';

  // Forgot password
  String get forgotPasswordTitle =>
      lang == AppLanguage.tr ? 'Şifremi Unuttum' : 'Forgot Password';
  String get forgotPasswordHeading => lang == AppLanguage.tr
      ? 'Email adresini gir'
      : 'Enter your email address';
  String get forgotPasswordInfo => lang == AppLanguage.tr
      ? 'Şifre sıfırlama bağlantısı sadece üniversite (.edu) maillerine gönderilecektir.'
      : 'Password reset link will only be sent to university (.edu) emails.';
  String get forgotPasswordEmailHint => lang == AppLanguage.tr
      ? 'Email (@universite.edu.tr)'
      : 'Email (@university.edu)';
  String get forgotPasswordSendLink => lang == AppLanguage.tr
      ? 'Bağlantıyı Gönder'
      : 'Send Link';

  String get forgotPasswordErrorEmpty => lang == AppLanguage.tr
      ? 'Lütfen email adresinizi girin.'
      : 'Please enter your email address.';
  String get forgotPasswordErrorEduOnly => lang == AppLanguage.tr
      ? 'Sadece .edu uzantılı öğrenci mailleri için şifre sıfırlama yapılabilir.'
      : 'Only .edu student emails can request password reset.';
  String get forgotPasswordErrorGeneric => lang == AppLanguage.tr
      ? 'Şifre sıfırlama isteği gönderilemedi.'
      : 'Password reset request could not be sent.';
  String get forgotPasswordErrorUserNotFound => lang == AppLanguage.tr
      ? 'Bu email ile kayıtlı bir kullanıcı bulunamadı.'
      : 'No user found with this email.';
  String get forgotPasswordErrorInvalidEmail => lang == AppLanguage.tr
      ? 'Geçersiz email adresi.'
      : 'Invalid email address.';
  String forgotPasswordUnexpectedError(Object e) => lang == AppLanguage.tr
      ? 'Beklenmeyen bir hata oluştu: $e'
      : 'An unexpected error occurred: $e';
  String forgotPasswordLinkSent(String email) => lang == AppLanguage.tr
      ? 'Şifre sıfırlama bağlantısını "$email" adresine gönderdik. Lütfen mail kutunuzu (ve spam klasörünü) kontrol edin.'
      : 'We sent a password reset link to "$email". Please check your inbox and spam folder.';

  String get infoDialogTitle =>
      lang == AppLanguage.tr ? 'Bilgi' : 'Info';

  // Home bottom nav
  String get navHome => lang == AppLanguage.tr ? 'Ana Akış' : 'Home';
  String get navExplore => lang == AppLanguage.tr ? 'Keşfet' : 'Explore';
  String get navChat => lang == AppLanguage.tr ? 'Mesajlar' : 'Chats';
  String get navProfile => lang == AppLanguage.tr ? 'Profil' : 'Profile';

  // Settings
  String get settingsTitle =>
      lang == AppLanguage.tr ? 'Ayarlar' : 'Settings';
  String get settingsSecuritySection =>
      lang == AppLanguage.tr ? 'Güvenlik' : 'Security';
  String get settingsGeneralSection =>
      lang == AppLanguage.tr ? 'Genel' : 'General';
  String get settingsSupportSection =>
      lang == AppLanguage.tr ? 'Destek' : 'Support';

  String get settingsLanguage => lang == AppLanguage.tr ? 'Dil' : 'Language';
  String get settingsLanguageTurkish =>
      lang == AppLanguage.tr ? 'Türkçe' : 'Turkish';
  String get settingsLanguageEnglish =>
      lang == AppLanguage.tr ? 'İngilizce' : 'English';

  String get settingsTheme => lang == AppLanguage.tr ? 'Tema' : 'Theme';
  String get settingsThemeDark =>
      lang == AppLanguage.tr ? 'Karanlık mod' : 'Dark mode';
  String get settingsThemeLight =>
      lang == AppLanguage.tr ? 'Aydınlık mod' : 'Light mode';
}

/// InheritedWidget to access [AppStrings] from widget tree.
class AppStringsProvider extends InheritedWidget {
  final AppStrings strings;

  const AppStringsProvider({
    Key? key,
    required this.strings,
    required Widget child,
  }) : super(key: key, child: child);

  static AppStrings of(BuildContext context) {
    final AppStringsProvider? provider =
        context.dependOnInheritedWidgetOfExactType<AppStringsProvider>();
    assert(provider != null, 'AppStringsProvider not found in context');
    return provider!.strings;
  }

  @override
  bool updateShouldNotify(covariant AppStringsProvider oldWidget) {
    return oldWidget.strings.lang != strings.lang;
  }
}
