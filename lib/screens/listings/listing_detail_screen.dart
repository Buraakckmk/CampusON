import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_on/core/theme.dart' as core_theme;

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<DocumentSnapshot> _listingStream;
  late String _userId;
  late String _title;

  @override
  void initState() {
    super.initState();
    _listingStream = _firestore.collection('listings').doc(widget.listingId).snapshots();
    _loadListingData();
  }

  Future<void> _loadListingData() async {
    try {
      final doc = await _firestore.collection('listings').doc(widget.listingId).get();
      if (doc.exists) {
        setState(() {
          _userId = doc['userId'] as String? ?? '';
          _title = doc['title'] as String? ?? 'İlan';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan bilgileri yüklenirken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> _contactSeller(String sellerId, String title) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Check if chat already exists
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .where('participants', arrayContains: sellerId)
        .limit(1)
        .get();

    String chatId;
    if (chatQuery.docs.isNotEmpty) {
      chatId = chatQuery.docs.first.id;
    } else {
      // Create new chat
      final chatRef = await _firestore.collection('chats').add({
        'participants': [currentUser.uid, sellerId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '${currentUser.displayName} bu ilanla ilgileniyor: $title',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'listingId': widget.listingId,
      });
      chatId = chatRef.id;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': chatId,
        'otherUserId': sellerId,
        'listingId': widget.listingId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _listingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('İlan bulunamadı'));
          }

          final listing = snapshot.data!.data() as Map<String, dynamic>;
          final images = List<String>.from(listing['images'] ?? []);
          final title = listing['title'] as String? ?? 'Başlıksız İlan';
          final description = listing['description'] as String? ?? '';
          final price = listing['price'] as num? ?? 0;
          final category = listing['category'] as String? ?? 'Diğer';
          final condition = listing['condition'] as String? ?? 'Belirtilmemiş';
          final createdAt = (listing['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final userId = listing['userId'] as String?;
          final userName = listing['userName'] as String? ?? 'Kullanıcı';
          final userPhoto = listing['userPhoto'] as String?;
          final userUniversity = listing['userUniversity'] as String?;
          final userDepartment = listing['userDepartment'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Slider
                if (images.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (ctx, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.photo_camera, size: 50)),
                  ),

                // Listing Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(description),
                      const SizedBox(height: 16),
                      const Text(
                        'Detaylar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Kategori', category),
                      _buildDetailRow('Durum', condition),
                      _buildDetailRow(
                        'Yayınlanma Tarihi',
                        timeago.format(createdAt, locale: 'tr'),
                      ),
                    ],
                  ),
                ),

                // Seller Info
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: userPhoto != null
                            ? NetworkImage(userPhoto) as ImageProvider
                            : const AssetImage('assets/default_avatar.png'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (userUniversity != null) Text(userUniversity),
                            if (userDepartment != null) Text(userDepartment),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? core_theme.AppColors.background : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_userId.isNotEmpty) {
                    _contactSeller(_userId, _title);
                  }
                },
                icon: const Icon(Icons.message),
                label: const Text('Mesaj Gönder'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                // TODO: Implement favorite functionality
              },
              icon: const Icon(Icons.favorite_border),
              style: IconButton.styleFrom(
                backgroundColor: core_theme.AppColors.glassWhite,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
