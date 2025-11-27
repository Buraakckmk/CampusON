import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_strings.dart';
import '../post_register_welcome_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;

  const EmailVerificationScreen({
    Key? key,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    final strings = AppStringsProvider.of(context);
    setState(() {
      _isChecking = true;
    });

    try {
      final auth = FirebaseAuth.instance;
      await auth.currentUser?.reload();
      final user = auth.currentUser;

      if (user != null && user.emailVerified) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PostRegisterWelcomeScreen(name: widget.name),
          ),
          (route) => false,
        );
      } else {
        _showInfoDialog(strings.emailVerificationStillUnverified);
      }
    } catch (e) {
      _showInfoDialog(strings.emailVerificationCheckError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    final strings = AppStringsProvider.of(context);
    setState(() {
      _isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showInfoDialog(strings.emailVerificationResendSuccess);
      } else {
        _showInfoDialog(strings.emailVerificationAlreadyVerified);
      }
    } catch (e) {
      _showInfoDialog(strings.emailVerificationResendError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.emailVerificationInfoTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
        centerTitle: true,
        title: Text(strings.emailVerificationTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              strings.helloName(widget.name),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              strings.verificationSentTo(widget.email),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              strings.emailVerificationStepsTitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(strings.emailVerificationStep1),
            Text(strings.emailVerificationStep2),
            Text(strings.emailVerificationStep3),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    _isChecking
                        ? strings.emailVerificationChecking
                        : strings.emailVerificationCheckButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isResending ? null : _resendVerification,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    _isResending
                        ? strings.emailVerificationResending
                        : strings.emailVerificationResendButton,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
