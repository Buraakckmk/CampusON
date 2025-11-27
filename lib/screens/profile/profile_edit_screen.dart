import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _newProfileImage;
  String? _photoUrl;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _departments = [
    'Bilgisayar Mühendisliği',
    'Yazılım Mühendisliği',
    'Elektrik-Elektronik Mühendisliği',
    'Endüstri Mühendisliği',
    'Makine Mühendisliği',
    'İnşaat Mühendisliği',
    'Mimarlık',
    'İşletme',
    'İktisat',
    'Psikoloji',
    'Hukuk',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _selectDepartment() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _departments.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (context, index) {
              final dept = _departments[index];
              return ListTile(
                title: Text(
                  dept,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, dept),
              );
            },
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _departmentController.text = selected;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showInfoDialog('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      _nameController.text = (data['name'] ?? '') as String;
      _departmentController.text = (data['department'] ?? '') as String;
      _photoUrl = data['photoUrl'] as String?;
    } catch (e) {
      _showInfoDialog('Profil bilgileri yüklenirken bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final department = _departmentController.text.trim();

    if (name.isEmpty) {
      _showInfoDialog('İsim alanı boş bırakılamaz.');
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showInfoDialog('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
        return;
      }

      String? photoUrl = _photoUrl;

      // Eğer yeni bir profil fotoğrafı seçildiyse, Firebase Storage'a yükle
      if (_newProfileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');

        await storageRef.putFile(_newProfileImage!);
        photoUrl = await storageRef.getDownloadURL();
      }

      final updateData = <String, dynamic>{
        'name': name,
        'department': department,
      };

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      if (!mounted) return;
      _showInfoDialog('Profilin başarıyla güncellendi.');
    } catch (e) {
      _showInfoDialog('Profil güncellenirken bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(this.context).pop(); // close edit screen
                  },
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profili Düzenle'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.glassWhite,
                              backgroundImage: _newProfileImage != null
                                  ? FileImage(_newProfileImage!)
                                  : (_photoUrl != null
                                      ? NetworkImage(_photoUrl!)
                                          as ImageProvider
                                      : null),
                              child: _newProfileImage == null && _photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.white70,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Profil Bilgilerin',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hintText: 'Ad Soyad',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Bölüm / Program (isteğe bağlı)',
                      prefixIcon: Icons.school_outlined,
                      controller: _departmentController,
                      readOnly: true,
                      onTap: _selectDepartment,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Kaydet',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _newProfileImage = File(picked.path);
      });
    } catch (e) {
      _showInfoDialog('Profil fotoğrafı seçilirken bir hata oluştu: $e');
    }
  }
}
