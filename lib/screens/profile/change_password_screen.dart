import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showInfoDialog('Lütfen tüm alanları doldurun.');
      return;
    }

    if (newPassword.length < 6) {
      _showInfoDialog('Yeni şifre en az 6 karakter olmalıdır.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showInfoDialog('Yeni şifre ve tekrar şifresi eşleşmiyor.');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showInfoDialog('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
        return;
      }

      // Kullanıcıyı yeniden doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(newPassword);

      if (!mounted) return;
      _showInfoDialog('Şifren başarıyla güncellendi.');
    } on FirebaseAuthException catch (e) {
      String message = 'Şifre güncellenemedi.';
      if (e.code == 'wrong-password') {
        message = 'Mevcut şifreyi yanlış girdiniz.';
      } else if (e.code == 'weak-password') {
        message = 'Yeni şifre çok zayıf.';
      }
      _showInfoDialog(message);
    } catch (e) {
      _showInfoDialog('Beklenmeyen bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showInfoDialog(String message) {
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
                const Text(
                  'Bilgi',
                  style: TextStyle(
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      'Tamam',
                      style: TextStyle(color: Colors.white),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifreyi Değiştir'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesap şifreni güncelle',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                hintText: 'Mevcut şifre',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                controller: _currentPasswordController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Yeni şifre',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                controller: _newPasswordController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Yeni şifre (tekrar)',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Kaydet',
                  isLoading: _isLoading,
                  onPressed: _changePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
