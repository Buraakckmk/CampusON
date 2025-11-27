import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../profile/security_settings_screen.dart';
import '../profile/profile_edit_screen.dart';
import '../sections/events_screen.dart';
import '../sections/communities_screen.dart';
import '../sections/marketplace_screen.dart';
import '../sections/cashback_screen.dart';
import '../create/add_post_screen.dart';
import '../create/add_marketplace_item_screen.dart';
import '../profile/all_posts_screen.dart';
import '../profile/user_search_screen.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  String? _profileName;
  String? _profileEmail;
  String? _profileUniversity;
  String? _profileDepartment;
  String? _profilePhotoUrl;
  int _postsCount = 0;
  int _followersCount = 0;
  int _followingCount = 0;
  int _listingsCount = 0;
  

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadProfileData();
  }

  Widget _buildPostNotifications() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 76,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('targetUid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final type = data['type'] as String? ?? '';
              final fromName = data['fromName'] as String? ?? 'Bir kullanıcı';
              final ts = data['createdAt'];
              DateTime? createdAt;
              if (ts is Timestamp) {
                createdAt = ts.toDate();
              }
              String timeLabel = '';
              if (createdAt != null) {
                final d = createdAt;
                final hour = d.hour.toString().padLeft(2, '0');
                final minute = d.minute.toString().padLeft(2, '0');
                timeLabel = '$hour:$minute';
              }

              String title;
              if (type == 'friend_added') {
                title = '$fromName seni ağına ekledi';
              } else {
                title = 'Yeni bildirim';
              }

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark
                      ? AppColors.glassWhite
                      : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : Colors.grey.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (timeLabel.isNotEmpty)
                          Text(
                            timeLabel,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                              fontSize: 10,
                            ),
                          ),
                      ],
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

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _profileName = data['name'] as String?;
          _profileEmail = data['email'] as String?;
          _profileUniversity =
              _universityNameFromDomain(data['university_domain'] as String?);
          _profileDepartment = data['department'] as String?;
          _profilePhotoUrl = data['photoUrl'] as String?;
        });
      }

      // Kullanıcının gönderi sayısını hesapla
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user.uid)
          .get();

      setState(() {
        _postsCount = postsSnapshot.size;
      });
    } catch (_) {
      // Profil veya post sayısı yüklenirken hata olursa sessiz geçiyoruz.
    }
  }

  Widget _buildExploreScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final users = [
      {
        'name': 'Elif Korkmaz',
        'university': 'Fırat Üniversitesi',
        'info': 'Bilgisayar Mühendisliği 2. sınıf | Mobil geliştirme ve tasarıma ilgi duyuyor.',
      },
      {
        'name': 'Mehmet Yıldız',
        'university': 'OSTİM Teknik Üniversitesi',
        'info': 'Yazılım Mühendisliği 1. sınıf | Start-up dünyası ve hackathonlar peşinde.',
      },
      {
        'name': 'Ayşe Demir',
        'university': 'Hacettepe Üniversitesi',
        'info': 'Psikoloji öğrencisi | Kampüs etkinlikleri ve sosyal sorumluluk projelerinde aktif.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Keşfet',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 26),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: isDark ? Colors.white70 : Colors.grey.shade800,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserSearchScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni öğrencilerle bağlantı kur, ağını genişlet.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color:
                          isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'] as String,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.grey.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user['university'] as String,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user['info'] as String,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.grey.shade800,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          onPressed: () {
                            // TODO: Ağ ekleme / istek gönderme işlemi
                          },
                          child: const Text(
                            'Ağına ekle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _universityNameFromDomain(String? domain) {
    if (domain == null) return null;
    final normalized = domain.toLowerCase().trim();

    const domainToName = {
      'firat.edu.tr': 'Fırat Üniversitesi',
      'ostimteknik.edu.tr': 'OSTİM Teknik Üniversitesi',
      'hacettepe.edu.tr': 'Hacettepe Üniversitesi',
      'ankara.edu.tr': 'Ankara Üniversitesi',
      'gazi.edu.tr': 'Gazi Üniversitesi',
      'metu.edu.tr': 'Orta Doğu Teknik Üniversitesi',
      'odtu.edu.tr': 'Orta Doğu Teknik Üniversitesi',
      'itu.edu.tr': 'İstanbul Teknik Üniversitesi',
      'istanbul.edu.tr': 'İstanbul Üniversitesi',
      'ibu.edu.tr': 'Bolu Abant İzzet Baysal Üniversitesi',
    };

    if (domainToName.containsKey(normalized)) {
      return domainToName[normalized];
    }

    if (normalized.endsWith('.edu.tr')) {
      final withoutSuffix = normalized.replaceFirst(RegExp(r'\.edu\.tr$'), '');
      final parts = withoutSuffix.split('.');
      final main = parts.isNotEmpty ? parts.last : withoutSuffix;
      final capitalized = main
          .split(RegExp(r'[-_]'))
          .where((p) => p.isNotEmpty)
          .map((p) => p[0].toUpperCase() + p.substring(1))
          .join(' ');
      return '$capitalized Üniversitesi';
    }

    return domain;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true, // Important for floating transparent navbar
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: isDark
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                      ],
                    ),
                  )
                : const BoxDecoration(
                    color: Colors.white,
                  ),
          ),
          SafeArea(
            bottom: false,
            child: _selectedIndex == 4
                ? _buildProfileDashboard()
                : _selectedIndex == 3
                    ? _buildChatDashboard()
                    : _selectedIndex == 1
                        ? _buildExploreScreen()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bildirimler bölümü
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 12),
                                  child: Text(
                                    'Bildirimler',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(fontSize: 18),
                                  ),
                                ),
                                _buildPostNotifications(),
                                const SizedBox(height: 20),
                                _buildFeedHeader(),
                                const SizedBox(height: 10),
                                _buildFeed(),
                              ],
                            ),
                          ),
          ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildChatDashboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text(
          'Mesajlar için giriş yapmalısın.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    final currentUid = user.uid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesajlar',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUid)
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz sohbet yok. Keşfet veya 2. El üzerinden mesaj göndererek başlat.',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final participants =
                        (data['participants'] as List<dynamic>?)
                                ?.cast<String>() ??
                            [];
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUid,
                      orElse: () => currentUid,
                    );

                    final nameKey =
                        'user_${currentUid}_otherName';
                    final otherName =
                        data[nameKey] as String? ?? 'Sohbet';
                    final lastMessage =
                        data['lastMessage'] as String? ?? '';
                    final updatedAt = data['updatedAt'];
                    String timeLabel = '';
                    if (updatedAt is Timestamp) {
                      final d = updatedAt.toDate();
                      final hour = d.hour.toString().padLeft(2, '0');
                      final minute =
                          d.minute.toString().padLeft(2, '0');
                      timeLabel = '$hour:$minute';
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              otherUserId: otherUserId,
                              otherUserName: otherName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? AppColors.glassWhite
                              : const Color(0xFFE2E8F0),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade300,
                              child: Text(
                                otherName.isNotEmpty
                                    ? otherName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otherName,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (lastMessage.isNotEmpty)
                                    Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (timeLabel.isNotEmpty)
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Stories",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  // In real app, use NetworkImage
                  child: Text(
                    "U${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "User $index",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Main Feed",
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 22),
          ),
          const Icon(Icons.filter_list, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildPostCard(
            title: "Etkinlikler",
            subtitle: "Kampüs etkinliklerini keşfet",
            color: Colors.purple.shade900,
            height: 200,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPostCard(
                  title: "Topluluklar",
                  subtitle: "Kulüp ve öğrenci toplulukları",
                  color: Colors.blue.shade900,
                  height: 150,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CommunitiesScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildPostCard(
                  title: "2. El Pazar",
                  subtitle: "Not, kitap ve araç gereçler",
                  color: Colors.orange.shade900,
                  height: 150,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketplaceScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPostCard(
            title: "Cashback & Fırsatlar",
            subtitle: "Harcamalarından geri kazan",
            color: Colors.pink.shade900,
            height: 180,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CashbackScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String title,
    required String subtitle,
    required Color color,
    required double height,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [color, color.withOpacity(0.5)]
                : [color.withOpacity(0.18), color.withOpacity(0.06)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glass Overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassCard(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              // Dark modda hafif cam efekti, light modda overlay yok
              opacity: isDark ? 0.1 : 0.0,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white70 : Colors.grey.shade800,
                      fontSize: 12,
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF020617) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.post_add, color: AppColors.primary),
                title: const Text('Gönderi ekle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (_) => const AddPostScreen(),
                    ),
                  ).then((_) {
                    _loadProfileData();
                  });
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.sell_outlined, color: AppColors.primary),
                title: const Text('İlan ekle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (_) => const AddMarketplaceItemScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: GlassCard(
        opacity: isDark ? 0.1 : 0.9,
        blur: 20,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, 0, isDark: isDark),
            _navItem(Icons.search, 1, isDark: isDark),
            _navItem(Icons.add_circle_outline, 2, isCenter: true, isDark: isDark),
            _navItem(Icons.chat_bubble_outline, 3, isDark: isDark),
            _navItem(Icons.person_outline, 4, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index,
      {bool isCenter = false, required bool isDark}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          _showCreateOptionsSheet();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isCenter ? const EdgeInsets.all(0) : const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isCenter ? 32 : 24,
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white54 : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildProfileDashboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profil',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 26),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.glassWhite
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F2937),
                  Color(0xFF0F172A),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.glassWhite,
                  backgroundImage: _profilePhotoUrl != null
                      ? NetworkImage(_profilePhotoUrl!)
                      : null,
                  child: _profilePhotoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.white70,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileName ?? 'Öğrenci',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_profileUniversity != null)
                        Text(
                          _profileUniversity!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      if (_profileDepartment != null &&
                          _profileDepartment!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _profileDepartment!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileEditScreen(),
                      ),
                    ).then((_) {
                      _loadProfileData();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              _buildProfileStat(
                label: 'Gönderi',
                value: _postsCount.toString(),
                icon: Icons.article_outlined,
              ),
              const SizedBox(width: 8),
              _buildProfileStat(
                label: 'Ağındaki kişi',
                value: _followersCount.toString(),
                icon: Icons.group_outlined,
              ),
              const SizedBox(width: 8),
              _buildProfileStat(
                label: 'Ağına eklediklerin',
                value: _followingCount.toString(),
                icon: Icons.person_add_alt_1_outlined,
              ),
              const SizedBox(width: 8),
              _buildProfileStat(
                label: 'İlanların',
                value: _listingsCount.toString(),
                icon: Icons.storefront_outlined,
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_postsCount == 0)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPostScreen(),
                  ),
                ).then((_) {
                  _loadProfileData();
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'İlk gönderini oluştur',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_postsCount > 0) ...[
            const SizedBox(height: 20),
            Text(
              'Gönderilerin',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid',
                      isEqualTo:
                          FirebaseAuth.instance.currentUser?.uid ?? '')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final docs = List<QueryDocumentSnapshot>.from(
                    snapshot.data!.docs as List<QueryDocumentSnapshot>);
                docs.sort((a, b) {
                  final ad = (a['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final bd = (b['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return bd.compareTo(ad);
                });
                final visibleCount = docs.length > 4 ? 4 : docs.length;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final content = (data['content'] as String?) ?? '';
                    final imageUrl = data['imageUrl'] as String?;
                    final ts = data['createdAt'];
                    DateTime? createdAt;
                    if (ts is Timestamp) {
                      createdAt = ts.toDate();
                    }
                    String formatted = '';
                    if (createdAt != null) {
                      final d = createdAt;
                      final day = d.day.toString().padLeft(2, '0');
                      final month = d.month.toString().padLeft(2, '0');
                      final year = d.year.toString();
                      final hour = d.hour.toString().padLeft(2, '0');
                      final minute = d.minute.toString().padLeft(2, '0');
                      formatted = '$day.$month.$year • $hour:$minute';
                    }
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark
                            ? AppColors.glassWhite
                            : const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                if (formatted.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    formatted,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey.shade700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.favorite_border,
                                            size: 20,
                                          ),
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey.shade800,
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 20,
                                          ),
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey.shade800,
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade800,
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: isDark
                                              ? const Color(0xFF020617)
                                              : Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          builder: (ctx) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.edit_outlined),
                                                  title:
                                                      const Text('Düzenle'),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  title: const Text('Sil'),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllPostsScreen(),
                    ),
                  );
                },
                child: const Text('Tüm gönderiler'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassWhite : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : AppColors.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isDark
                        ? Colors.white70
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
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
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}
