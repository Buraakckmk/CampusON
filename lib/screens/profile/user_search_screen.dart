import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../chat/chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<DocumentSnapshot> _results = [];
  String? _currentUserName;
  final Set<String> _addedUserIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _ensureCurrentUserNameLoaded() async {
    if (_currentUserName != null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentUserName = data['name'] as String? ?? '';
      }
    } catch (_) {
      // Sessiz geç
    }
  }

  Future<void> _addToNetwork(String targetUserId, String targetName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ağa eklemek için giriş yapmalısın.')),
      );
      return;
    }

    if (user.uid == targetUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kendini ağına ekleyemezsin.')),
      );
      return;
    }

    await _ensureCurrentUserNameLoaded();

    try {
      // Zaten ekli mi kontrol et
      final existing = await FirebaseFirestore.instance
          .collection('friends')
          .where('fromUid', isEqualTo: user.uid)
          .where('toUid', isEqualTo: targetUserId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu kullanıcı zaten ağında.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('friends').add({
        'fromUid': user.uid,
        'toUid': targetUserId,
        'createdAt': Timestamp.now(),
      });

      // Karşı tarafa bildirim oluştur
      await FirebaseFirestore.instance.collection('notifications').add({
        'targetUid': targetUserId,
        'fromUid': user.uid,
        'fromName': _currentUserName ?? user.email ?? 'Bir kullanıcı',
        'type': 'friend_added',
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _addedUserIds.add(targetUserId);
      });

      // Üst kısma yakın, küçük bir floating bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$targetName ağınıza eklendi.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 80, 16, 0),
          elevation: 4,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ağa eklerken bir hata oluştu.')),
      );
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final filtered = snap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] as String? ?? '').toLowerCase();
        final email = (data['email'] as String? ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();

      if (!mounted) return;
      setState(() {
        _results = filtered;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Ara'),
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
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'İsim veya email ile ara',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.grey.shade600,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.glassWhite
                        : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _performSearch,
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Ara',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _results.isEmpty
                      ? Center(
                          child: Text(
                            'Sonuç bulunamadı',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = _results[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name'] as String? ?? 'İsimsiz kullanıcı';
                            final email = data['email'] as String? ?? '';
                            final userId = doc.id;
                            return Container(
                              padding: const EdgeInsets.all(12),
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
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade300,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (email.isNotEmpty)
                                          Text(
                                            email,
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
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                otherUserId: userId,
                                                otherUserName: name,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Mesaj gönder',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppColors.primary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                        ),
                                        onPressed: _addedUserIds.contains(userId)
                                            ? null
                                            : () {
                                                _addToNetwork(userId, name);
                                              },
                                        child: Text(
                                          _addedUserIds.contains(userId)
                                              ? 'Eklendi'
                                              : 'Ağına ekle',
                                          style: TextStyle(
                                            color: _addedUserIds.contains(userId)
                                                ? (isDark
                                                    ? Colors.white54
                                                    : Colors.grey.shade500)
                                                : AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
