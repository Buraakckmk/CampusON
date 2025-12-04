import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({Key? key, required this.otherUserId, required this.otherUserName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  String get _chatId {
    final ids = [_currentUserId, widget.otherUserId]..sort();
    return ids.join('_');
  }

  CollectionReference<Map<String, dynamic>> get _chatsCol =>
      FirebaseFirestore.instance.collection('chats');

  CollectionReference<Map<String, dynamic>> get _messagesCol =>
      _chatsCol.doc(_chatId).collection('messages');

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final now = Timestamp.now();

    await _chatsCol.doc(_chatId).set({
      'participants': [_currentUserId, widget.otherUserId],
      'lastMessage': text,
      'updatedAt': now,
      'lastSenderId': _currentUserId,
      // Her kullanıcı için, karşı tarafın adını kendi uid'sine özel bir alanda sakla
      'user_${_currentUserId}_otherName': widget.otherUserName,
    }, SetOptions(merge: true));

    await _messagesCol.add({
      'senderId': _currentUserId,
      'text': text,
      'createdAt': now,
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark
                        ? AppColors.glassWhite
                        : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _messagesCol
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Henüz mesaj yok. İlk mesajı sen gönder!',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final fromMe = data['senderId'] == _currentUserId;
                          return Align(
                            alignment: fromMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              constraints: const BoxConstraints(maxWidth: 260),
                              decoration: BoxDecoration(
                                color: fromMe
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white10
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                (data['text'] as String?) ?? '',
                                style: TextStyle(
                                  color: fromMe
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : Colors.grey.shade900),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.grey.shade900,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Mesaj yaz...',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, size: 18),
                        color: Colors.white,
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
