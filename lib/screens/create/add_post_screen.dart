import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/theme.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      // İçerik ve görsel tamamen boşsa gönderi oluşturma
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir metin veya görsel ekleyin.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum bulunamadı. Lütfen tekrar giriş yapın.')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      String? imageUrl;
      if (_selectedImage != null) {
        final fileName =
            '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(user.uid)
            .child(fileName);
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user.uid,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderi oluşturulurken bir hata oluştu.')), 
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
      });
    } catch (_) {
      // İsteğe bağlı: görsel seçme hatası durumunda snackbar/dialog gösterilebilir.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Oluştur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
              )
            : const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gönderi içeriği',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'CampusON üzerinde paylaşmak istediğin gönderiyi yaz...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.glassWhite
                        : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _pickImage,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : AppColors.primary,
                      ),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Görsel ekle'),
                    ),
                  ],
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        _selectedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitPost,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Paylaş',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
