import 'package:flutter/material.dart';
import '../../core/theme.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = [
      {
        'title': 'Mobil Geliştirme Atölyesi',
        'date': '28 Kasım, 18:00',
        'place': 'Mühendislik Fakültesi D-203',
        'description':
            'Flutter ile mobil uygulama geliştirmeye giriş. Temel widget yapısı, state yönetimi ve Firebase entegrasyonu konuşulacak.',
      },
      {
        'title': 'Kariyer Zirvesi 2025',
        'date': '30 Kasım, 10:00',
        'place': 'Kongre Merkezi',
        'description':
            'Farklı firmalardan konuşmacılar, staj ve iş fırsatları, CV değerlendirme seansları.',
      },
      {
        'title': 'E-Spor Turnuvası',
        'date': '3 Aralık, 20:00',
        'place': 'Online',
        'description':
            'LOL ve Valorant branşlarında ödüllü turnuva. Takımını kur, kayıt ol ve mücadeleye katıl.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampüs Etkinlikleri'),
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
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color:
                        isDark ? AppColors.glassWhite : const Color(0xFFE2E8F0),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event['date'] as String,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white70 : Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['place'] as String,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white60 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title'] as String),
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
                  event['title'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16,
                        color:
                            isDark ? Colors.white70 : Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      event['date'] as String,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : Colors.grey.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16,
                        color:
                            isDark ? Colors.white70 : Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      event['place'] as String,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : Colors.grey.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  event['description'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    height: 1.4,
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
