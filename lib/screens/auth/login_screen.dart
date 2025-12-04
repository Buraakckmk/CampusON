import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              const Icon(Icons.school, size: 60, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                strings.appName,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 30),
              CustomTextField(
                hintText: strings.loginEmailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: strings.loginPasswordHint,
                isPassword: !_isPasswordVisible,
                prefixIcon: Icons.lock_outline,
                controller: _passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    strings.loginForgotPassword,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: strings.loginButton,
                  onPressed: _onLoginPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final strings = AppStringsProvider.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(strings.loginErrorFillEmailPassword);
      return;
    }

    if (!email.toLowerCase().contains('.edu')) {
      _showErrorDialog(strings.loginErrorEduOnly);
      return;
    }

    try {
      final auth = FirebaseAuth.instance;

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _showErrorDialog(
            'Giriş yapılamadı, lütfen bilgilerinizi kontrol edin.');
        return;
      }

      if (!user.emailVerified) {
        _showUnverifiedDialog(user);
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = strings.loginErrorGeneric;
      if (e.code == 'user-not-found') {
        message = strings.loginErrorUserNotFound;
      } else if (e.code == 'wrong-password') {
        message = strings.loginErrorWrongPassword;
      } else if (e.code == 'invalid-email') {
        message = strings.loginErrorInvalidEmail;
      }
      _showErrorDialog(message);
    } catch (_) {
      _showErrorDialog(strings.loginErrorUnexpected);
    }
  }

  void _showUnverifiedDialog(User user) {
    final strings = AppStringsProvider.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.highlight_off,
                  color: isDark ? Colors.redAccent : Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.loginDialogTitleError,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.emailVerificationStillUnverified,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        strings.dialogButtonClose,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await user.sendEmailVerification();
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          _showErrorDialog(
                              strings.loginDialogResendSuccess);
                        } catch (_) {
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          _showErrorDialog(
                              strings.loginDialogResendError);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          strings.loginDialogResendTitle,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final strings = AppStringsProvider.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding
            (
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.highlight_off,
                  color: isDark ? Colors.redAccent : Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hatalı Giriş',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      strings.dialogButtonOk,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
