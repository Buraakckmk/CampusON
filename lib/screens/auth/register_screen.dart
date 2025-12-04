import 'package:flutter/material.dart';
import 'dart:ui'; // For PathEffect if needed, but using simpler BorderSide here or CustomPainter
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_model.dart';
import '../home/home_screen.dart';
import 'email_verification_screen.dart';
import '../../data/universities.dart';
import '../../data/departments.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  bool _termsAccepted = false;
  bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedUniversity;
  String? _selectedDepartment;
  String? _selectedGender;
  
  // Search controllers for bottom sheets
  final _universitySearchController = TextEditingController();
  final _departmentSearchController = TextEditingController();

  File? _profileImage;
  PlatformFile? _studentDocument;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universitySearchController.dispose();
    _departmentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(strings.registerTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(strings),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: const Text('Geri'),
                    )
                  else
                    const SizedBox(width: 64),
                  SizedBox(
                    width: 160,
                    child: CustomButton(
                      text: _currentStep == 4
                          ? strings.registerCompleteButton
                          : 'İleri',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_currentStep == 4) {
                          _onRegisterPressed();
                        } else {
                          _goToNextStep(strings);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(AppStrings strings) {
    switch (_currentStep) {
      case 0:
        return _buildUniversityStep(strings);
      case 1:
        return _buildDepartmentStep(strings);
      case 2:
        return _buildNameStep(strings);
      case 3:
        return _buildGenderStep(strings);
      case 4:
      default:
        return _buildAccountStep(strings);
    }
  }

  Widget _buildUniversityStep(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Üniversiteni Seç',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showUniversityBottomSheet(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_outlined, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedUniversity ?? 'Üniversite seçiniz',
                    style: TextStyle(
                      color: _selectedUniversity != null 
                          ? Colors.white 
                          : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUniversityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _universitySearchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Üniversite ara',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // University list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: universities.length,
                        itemBuilder: (context, index) {
                          final university = universities[index];
                          final isSelected = university == _selectedUniversity;
                          final searchQuery = _universitySearchController.text.toLowerCase();
                          
                          // Filter based on search
                          if (searchQuery.isNotEmpty && 
                              !university.toLowerCase().contains(searchQuery)) {
                            return const SizedBox.shrink();
                          }
                          
                          return ListTile(
                            title: Text(
                              university,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected 
                                ? const Icon(Icons.check, color: AppColors.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedUniversity = university;
                              });
                              _universitySearchController.clear();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDepartmentStep(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bölümünü Seç',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showDepartmentBottomSheet(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDepartment ?? 'Bölüm seçiniz',
                    style: TextStyle(
                      color: _selectedDepartment != null 
                          ? Colors.white 
                          : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDepartmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _departmentSearchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Bölüm ara',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Department list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: departments.length,
                        itemBuilder: (context, index) {
                          final department = departments[index];
                          final isSelected = department == _selectedDepartment;
                          final searchQuery = _departmentSearchController.text.toLowerCase();
                          
                          // Filter based on search
                          if (searchQuery.isNotEmpty && 
                              !department.toLowerCase().contains(searchQuery)) {
                            return const SizedBox.shrink();
                          }
                          
                          return ListTile(
                            title: Text(
                              department,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected 
                                ? const Icon(Icons.check, color: AppColors.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedDepartment = department;
                              });
                              _departmentSearchController.clear();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNameStep(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ad ve Soyad',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Adınız',
          prefixIcon: Icons.person_outline,
          controller: _firstNameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Soyadınız',
          prefixIcon: Icons.badge_outlined,
          controller: _lastNameController,
        ),
      ],
    );
  }

  Widget _buildGenderStep(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cinsiyetiniz',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedGender = 'male';
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _selectedGender == 'male'
                        ? AppColors.primary
                        : Colors.white30,
                  ),
                ),
                child: const Text('Erkek'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedGender = 'female';
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _selectedGender == 'female'
                        ? AppColors.primary
                        : Colors.white30,
                  ),
                ),
                child: const Text('Kadın'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountStep(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Bilgileri',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Kullanıcı adı',
          prefixIcon: Icons.alternate_email,
          controller: _usernameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: strings.registerEmailHint,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: strings.registerPasswordHint,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: strings.registerPasswordConfirmHint,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 20),
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
                strings.registerTermsText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goToNextStep(AppStrings strings) {
    if (_currentStep == 0 && _selectedUniversity == null) {
      _showErrorDialog('Lütfen üniversitenizi seçin.');
      return;
    }
    if (_currentStep == 1 && _selectedDepartment == null) {
      _showErrorDialog('Lütfen bölümünüzü seçin.');
      return;
    }
    if (_currentStep == 2 && (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty)) {
      _showErrorDialog('Lütfen ad ve soyadınızı doldurun.');
      return;
    }
    if (_currentStep == 3 && _selectedGender == null) {
      _showErrorDialog('Lütfen cinsiyetinizi seçin.');
      return;
    }

    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, 4);
    });
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
      _showErrorDialog('Profil fotoğrafı seçilirken bir hata oluştu.');
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
      _showErrorDialog('Öğrenci belgesi seçilirken bir hata oluştu.');
    }
  }

  Future<void> _onRegisterPressed() async {
    final strings = AppStringsProvider.of(context);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final name = '$firstName $lastName'.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (_selectedUniversity == null || _selectedDepartment == null) {
      _showErrorDialog('Lütfen üniversite ve bölüm bilgilerinizi doldurun.');
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog(strings.registerErrorFillAll);
      return;
    }

    // edu mail kontrolü
    if (!email.toLowerCase().endsWith('.edu') &&
        !email.toLowerCase().contains('.edu.')) {
      _showErrorDialog(strings.registerErrorEduOnly);
      return;
    }

    if (password.length < 6) {
      _showErrorDialog(strings.registerErrorPasswordShort);
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog(strings.registerErrorPasswordsNotMatch);
      return;
    }

    if (!_termsAccepted) {
      _showErrorDialog(strings.registerErrorAcceptTerms);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Create user in Firebase Auth
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _showErrorDialog(strings.registerErrorGeneric);
        return;
      }

      // Send email verification
      await user.sendEmailVerification();

      // Prepare user data for Firestore
      final universityDomain = UserModel.parseDomain(email);

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'university_domain': universityDomain,
        'university': _selectedUniversity,
        'department': _selectedDepartment,
        'gender': _selectedGender,
        'username': username,
        'is_verified': false,
        'level': 1,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            name: name,
            email: email,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = strings.registerErrorFailed;
      if (e.code == 'email-already-in-use') {
        message = strings.registerErrorEmailInUse;
      } else if (e.code == 'weak-password') {
        message = strings.registerErrorWeakPassword;
      } else if (e.code == 'invalid-email') {
        message = strings.registerErrorInvalidEmail;
      }
      _showErrorDialog(message);
    } on TimeoutException {
      _showErrorDialog(strings.registerErrorTimeout);
    } catch (e) {
      _showErrorDialog('${strings.registerErrorFailed}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  strings.registerDialogTitleError,
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
