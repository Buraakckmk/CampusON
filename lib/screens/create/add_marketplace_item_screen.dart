import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AddMarketplaceItemScreen extends StatelessWidget {
  const AddMarketplaceItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. El İlan Oluştur'),
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
                  'İlan başlığı',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Örneğin: Lineer Cebir kitabı',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
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
                const SizedBox(height: 16),
                Text(
                  'Açıklama',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ürün durumu, kullanım süresi vb. detayları yaz...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
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
                const SizedBox(height: 16),
                Text(
                  'Fiyat',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Örneğin: 120',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.7),
                    ),
                    suffixText: 'TL',
                    suffixStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
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
                    onPressed: () {
                      // TODO: Firestore'a ilan kaydı yapılacak ve 'İlanlarım' listesine düşecek
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text('İlanı Yayınla',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
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
