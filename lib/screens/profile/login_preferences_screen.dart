import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LoginPreferencesScreen extends StatelessWidget {
  const LoginPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Not: Gerçek cihaz/geçmiş oturum takibi için backend veya Firebase ek log gerekir.
    // Şimdilik taslak bir cihaz listesi gösteriyoruz.
    final devices = [
      {
        'name': 'Bu cihaz',
        'platform': 'Android • Pixel emulator',
        'location': 'Türkiye',
        'lastActive': 'Şu an aktif',
      },
      {
        'name': 'Dizüstü bilgisayar',
        'platform': 'Web • Chrome',
        'location': 'Türkiye',
        'lastActive': '2 gün önce',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Tercihleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesabına giriş yaptığın cihazlar',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'Şimdilik örnek bir liste gösteriyoruz. Gerçek cihaz geçmişi için ek backend geliştirmesi yapılabilir.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.devices_other,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${d['platform']} • ${d['location']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d['lastActive'] as String,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, color: Colors.white38, size: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
