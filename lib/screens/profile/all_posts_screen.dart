import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';

class AllPostsScreen extends StatelessWidget {
  const AllPostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Gönderiler'),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz gönderin yok.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                  );
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

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
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
                                height: 200,
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
          ),
        ),
      ),
    );
  }
}
