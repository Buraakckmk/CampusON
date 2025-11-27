import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CashbackScreen extends StatelessWidget {
  const CashbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final coupons = [
      {
        'brand': 'Yemeksepeti',
        'title': 'Öğrencilere %20 indirim',
        'code': 'CAMPUS20',
        'description':
            'Min. 80 TL siparişlerde geçerli. Sadece .edu maili ile kayıtlı kullanıcılar kullanabilir.',
      },
      {
        'brand': 'Trendyol',
        'title': 'Kitap kategorisinde 50 TL indirim',
        'code': 'KITAP50',
        'description':
            '150 TL ve üzeri kitap alışverişlerinde geçerli. Diğer kampanyalarla birleştirilemez.',
      },
      {
        'brand': 'Spotify',
        'title': '3 Ay Premium deneme',
        'code': 'SPOTIFYSTUDENT',
        'description':
            'Sadece yeni öğrenci üyelikleri için geçerlidir. Üniversite maili ile doğrulama gerektirir.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashback & Fırsatlar'),
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
          child: ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = coupons[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color:
                      isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['brand'] as String,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['title'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['description'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark
                                ? Colors.black.withOpacity(0.4)
                                : const Color(0xFFE2E8F0),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade400,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            c['code'] as String,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.grey.shade900,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.content_copy,
                          color:
                              isDark ? Colors.white70 : Colors.grey.shade800,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
