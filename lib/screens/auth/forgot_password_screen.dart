import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    final strings = AppStringsProvider.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showInfoDialog(strings.forgotPasswordErrorEmpty);
      return;
    }

    if (!email.toLowerCase().contains('.edu')) {
      _showInfoDialog(strings.forgotPasswordErrorEduOnly);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      _showInfoDialog(strings.forgotPasswordLinkSent(email));
    } on FirebaseAuthException catch (e) {
      String message = strings.forgotPasswordErrorGeneric;
      if (e.code == 'user-not-found') {
        message = strings.forgotPasswordErrorUserNotFound;
      } else if (e.code == 'invalid-email') {
        message = strings.forgotPasswordErrorInvalidEmail;
      }
      _showInfoDialog(message);
    } catch (e) {
      _showInfoDialog(strings.forgotPasswordUnexpectedError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showInfoDialog(String message) {
    final strings = AppStringsProvider.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.white : AppColors.primary,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.infoDialogTitle,
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
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(strings.forgotPasswordTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                strings.forgotPasswordHeading,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                strings.forgotPasswordInfo,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                hintText: strings.forgotPasswordEmailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: strings.forgotPasswordSendLink,
                  isLoading: _isLoading,
                  onPressed: _onSendPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
