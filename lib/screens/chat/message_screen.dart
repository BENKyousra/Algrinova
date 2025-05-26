import 'package:algrinova/screens/experts/experts_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/services/chat_service.dart';
import 'package:algrinova/screens/chat/chat_screen.dart';

class MessageScreen extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserEmail;
  final String receiverUserphotoUrl;
  final String receivername;

  const MessageScreen({
    super.key,
    required this.receiverUserId,
    required this.receiverUserEmail,
    required this.receiverUserphotoUrl,
    required this.receivername,
  });

  @override
  State<MessageScreen> createState() => _ChatPageState();
}

class _ChatPageState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  String? _selectedMessageId; // سيخزن معرف الرسالة المحددة فقط

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        widget.receiverUserId,
        _messageController.text.trim(),
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = _firebaseAuth.currentUser?.uid;

    if (currentUserId == null) return;

    try {
      final chatRoomId = _generateChatRoomId(
        widget.receiverUserId,
        currentUserId,
      );
      final chatRoomSnapshot =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      if (chatRoomSnapshot.exists) {
        final chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
        final unreadBy = List<String>.from(chatRoomData['unreadBy'] ?? []);

        if (unreadBy.contains(currentUserId)) {
          unreadBy.remove(currentUserId);

          // تحديث قاعدة البيانات لإزالة المستخدم من قائمة "غير مقروء"
          await _firestore.collection('chatRooms').doc(chatRoomId).update({
            'unreadBy': unreadBy,
          });
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  String _generateChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text('Delete the conversation'),
              onTap: () {
                Navigator.pop(context);
                // يمكنك إضافة وظيفة حذف المحادثة هنا
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.black),
              title: Text('Block'),
              onTap: () {
                Navigator.pop(context);
                // يمكنك إضافة وظيفة الحظر هنا
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem, color: Colors.black),
              title: Text('Signaler a problem'),
              onTap: () {
                Navigator.pop(context);
                // يمكنك إضافة وظيفة الإبلاغ هنا
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ChatScreen(
                      expertId: widget.receiverUserId,
                      expertEmail: widget.receiverUserEmail,
                    ),
              ),
            );
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ExpertProfileScreen(
                          expertId: widget.receiverUserId,
                        ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(widget.receiverUserphotoUrl),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receivername,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.receiverUserId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    bool isOnline = false;
                    if (snapshot.data != null) {
                      final data = snapshot.data;
                      if (data == null) {
                        return Text(
                          'Offline',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      }
                      final userData = data.data() as Map<String, dynamic>?;
                      if (userData != null &&
                          userData.containsKey('isOnline')) {
                        isOnline = userData['isOnline'] ?? false;
                      }
                    }
                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // إخفاء وقت الإرسال عند الضغط في أي مكان بالشاشة
          setState(() {
            _selectedMessageId = null;
          });
        },
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    final chatRoomId = _generateChatRoomId(
      widget.receiverUserId,
      currentUserId ?? '',
    );

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('timestamp', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

        final messages = snapshot.data!.docs;

        // Scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animate: false),
        );

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == _firebaseAuth.currentUser!.uid;
            final isSelected = _selectedMessageId == document.id;
            final bool showAvatar =
                true; // Define showAvatar based on your logic

            return GestureDetector(
              onLongPress: () {
                setState(() {
                  _selectedMessageId = isSelected ? null : document.id;
                });
              },
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(
                  begin: Offset(isMe ? 1 : -1, 0),
                  end: Offset(0, 0),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, Offset offset, child) {
                  return Transform.translate(offset: offset * 20, child: child);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 4,
                    left: isMe ? 64 : 1,
                    right: isMe ? 1 : 64,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (data['isUnread'] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Unread',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),

                      if (!isMe && showAvatar)
                        Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 0),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              widget.receiverUserphotoUrl,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Material(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isMe ? 12 : 12),
                                topRight: Radius.circular(isMe ? 12 : 12),
                                bottomLeft: const Radius.circular(15),
                                bottomRight: const Radius.circular(15),
                              ),
                              elevation: 0,
                              color:
                                  isMe
                                      ? Color.fromARGB(255, 0, 143, 48)
                                      : Color.fromARGB(255, 0, 0, 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Text(
                                  data['message'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isMe ? Colors.white : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected && data['timestamp'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatTimestamp(data['timestamp']),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
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
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: InputDecoration(
                hintText: 'Message',
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.send, color: Colors.grey.shade700, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
