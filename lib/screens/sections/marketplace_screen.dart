import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../profile/public_profile_screen.dart';
import '../chat/chat_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _activeFilter = 'Hepsi';

  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Java Notları - 2. Sınıf',
      'price': '80 TL',
      'category': 'Notlar',
      'description':
          'Ders sırasında tutulmuş el yazısı Java notları. Sınav öncesi tekrar için ideal.',
      'ownerName': 'Burak Çakmak',
      'ownerDepartment': 'Yazılım Mühendisliği',
      // Gerçek uygulamada buraya ilan sahibinin Firebase uid değeri gelecek.
      'ownerId': 'demoOwnerJava',
    },
    {
      'title': 'Lineer Cebir Ders Kitabı',
      'price': '120 TL',
      'category': 'Kitaplar',
      'description':
          'Az kullanılmış, temiz durumda. Bazı sayfalarda kurşun kalemle ufak notlar var.',
      'ownerName': 'Caner Yılmaz',
      'ownerDepartment': 'Bilgisayar Mühendisliği',
      'ownerId': 'demoOwnerLinear',
    },
    {
      'title': 'Bilgisayar Müh. Çizim Seti',
      'price': '200 TL',
      'category': 'Araç-Gereç',
      'description':
          'Cetvel, iletki, pergel ve proje çizimi için gerekli diğer ekipmanlar.',
      'ownerName': 'Ayşe Demir',
      'ownerDepartment': 'Mimarlık',
      'ownerId': 'demoOwnerSet',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_activeFilter == 'Hepsi') return _items;
    return _items
        .where((item) => item['category'] == _activeFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. El Pazar'),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            isDark ? const Color(0xFF020617) : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (ctx) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Hepsi'),
                                onTap: () {
                                  setState(() => _activeFilter = 'Hepsi');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Notlar'),
                                onTap: () {
                                  setState(() => _activeFilter = 'Notlar');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Kitaplar'),
                                onTap: () {
                                  setState(() => _activeFilter = 'Kitaplar');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Araç-Gereç'),
                                onTap: () {
                                  setState(() => _activeFilter = 'Araç-Gereç');
                                  Navigator.pop(ctx);
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    label: const Text(
                      'Filtrele',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarketplaceDetailScreen(
                                item: item,
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
                                : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.grey.shade300,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['category'] as String,
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
                              Text(
                                item['price'] as String,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class MarketplaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const MarketplaceDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ownerName =
        item['ownerName'] as String? ?? 'Bilinmeyen kullanıcı';
    final ownerDepartment = item['ownerDepartment'] as String?;
    final ownerId = item['ownerId'] as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
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
                  item['title'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['price'] as String,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kategori: ${item['category']}',
                  style: TextStyle(
                    color:
                        isDark ? Colors.white70 : Colors.grey.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(
                          name: ownerName,
                          department: ownerDepartment,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey.shade300,
                        child: Text(
                          ownerName.isNotEmpty
                              ? ownerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.grey.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ownerName,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (ownerDepartment != null &&
                              ownerDepartment.isNotEmpty)
                            Text(
                              ownerDepartment,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      item['description'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onPressed: () {
                          if (ownerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bu ilan için mesajlaşma henüz aktif değil.'),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: ownerId,
                                otherUserName:
                                    (item['ownerName'] as String?) ?? 'Satıcı',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Mesaj gönder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onPressed: () {
                          // TODO: Satın alma isteği akışı buraya bağlanacak.
                        },
                        child: const Text(
                          'Satın almak istiyorum',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
