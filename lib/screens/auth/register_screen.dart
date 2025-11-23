import 'package:flutter/material.dart';
import 'dart:ui'; // For PathEffect if needed, but using simpler BorderSide here or CustomPainter
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _termsAccepted = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;
  PlatformFile? _studentDocument;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("KAYIT OL"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar Picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.glassWhite,
                    backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white54)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Name Field
            CustomTextField(
              hintText: "Ad Soyad",
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 20),

            // Upload ID Area (Dashed Border)
            GestureDetector(
              onTap: _pickStudentDocument,
              child: _buildDashedUploadContainer(),
            ),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: "Şifre",
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: "Şifre Tekrar",
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 20),
            
            // Terms Checkbox
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: Colors.white54),
                  onChanged: (val) {
                    setState(() {
                      _termsAccepted = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "Sözleşmeyi okudum, onaylıyorum.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "KAYDI TAMAMLA",
                onPressed: _onRegisterPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedUploadContainer() {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(Icons.upload_file, color: AppColors.primary, size: 30),
            const SizedBox(height: 10),
            Text(
              _studentDocument != null
                  ? _studentDocument!.name
                  : "Öğrenci Belgesi Yükle",
              style: TextStyle(color: AppColors.primary.withOpacity(0.8)),
            ),
            Text(
              "(Sadece .pdf, .jpg, .jpeg, .png)",
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Kamera ile çek',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text('Galeriden seç',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(source: source, imageQuality: 75);
      if (picked == null) return;

      setState(() {
        _profileImage = File(picked.path);
      });
    } catch (e) {
      _showSnackBar('Profil fotoğrafı seçilirken bir hata oluştu.');
    }
  }

  Future<void> _pickStudentDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _studentDocument = result.files.first;
      });
    } catch (e) {
      _showSnackBar('Öğrenci belgesi seçilirken bir hata oluştu.');
    }
  }

  void _onRegisterPressed() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Lütfen tüm alanları doldurun.');
      return;
    }

    // edu mail kontrolü
    if (!email.toLowerCase().endsWith('.edu') &&
        !email.toLowerCase().contains('.edu.')) {
      _showSnackBar('Sadece .edu uzantılı öğrenci mailleri ile kayıt olunabilir.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Şifre en az 6 karakter olmalıdır.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Şifreler eşleşmiyor.');
      return;
    }

    if (_profileImage == null) {
      _showSnackBar('Lütfen profil fotoğrafı ekleyin.');
      return;
    }

    if (_studentDocument == null) {
      _showSnackBar('Lütfen öğrenci belgenizi yükleyin.');
      return;
    }

    if (!_termsAccepted) {
      _showSnackBar('Lütfen sözleşmeyi onaylayın.');
      return;
    }

    // Burada ileride Firebase register + Storage upload işlemleri eklenecek.
    _showSnackBar('Validation başarılı, backend entegrasyonu eklenmeli.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double startX = 0;

    final path = Path();
    // Top
    while (startX < size.width) {
      path.moveTo(startX, 0);
      path.lineTo(startX + dashWidth, 0);
      startX += dashWidth + dashSpace;
    }
    // Right
    double startY = 0;
    while (startY < size.height) {
      path.moveTo(size.width, startY);
      path.lineTo(size.width, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }
    // Bottom
    startX = size.width;
    while (startX > 0) {
      path.moveTo(startX, size.height);
      path.lineTo(startX - dashWidth, size.height);
      startX -= dashWidth + dashSpace;
    }
    // Left
    startY = size.height;
    while (startY > 0) {
      path.moveTo(0, startY);
      path.lineTo(0, startY - dashWidth);
      startY -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
