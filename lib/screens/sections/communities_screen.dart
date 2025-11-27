import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({Key? key}) : super(key: key);

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _communities = [
    {
      'name': 'Bilgisayar ve Bilişim Topluluğu',
      'about':
          'Yazılım geliştirme, hackathonlar, teknik seminerler ve workshoplar düzenleyen öğrenci topluluğu.',
    },
    {
      'name': 'Girişimcilik Kulübü',
      'about':
          'Start-up kültürü, iş fikri geliştirme, yatırımcı buluşmaları ve networking etkinlikleri.',
    },
    {
      'name': 'Tiyatro Topluluğu',
      'about':
          'Sene boyunca oyun hazırlıkları, doğaçlama atölyeleri ve kampüs içi gösteriler.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _communities[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluklar'),
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
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: ListView.separated(
                          itemCount: _communities.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final community = _communities[index];
                            final bool isSelected = index == _selectedIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.glassWhite
                                          : const Color(0xFFE2E8F0))
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.8)
                                        : (isDark
                                            ? Colors.white10
                                            : Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  community['name']!,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark
                                ? AppColors.glassWhite
                                : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color:
                                  isDark ? Colors.white12 : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selected['name']!,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.grey.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Hakkında',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                selected['about']!,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
