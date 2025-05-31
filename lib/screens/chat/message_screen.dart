import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/services/chat_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  //final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final chatService = ChatService();
  String? _selectedMessageId; // سيخزن معرف الرسالة المحددة فقط
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    // لا ترسل إذا كانت الرسالة فارغة
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        receiverUserId: widget.receiverUserId,
        message: _messageController.text.trim(),
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while sending the message: ${e.toString()}',
          ),
        ),
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
              onTap: () async {
                Navigator.pop(context); // إغلاق القائمة أولاً

                // استدعاء دالة الحذف المشتركة
                await ChatService().deleteChat(
                  context: context,
                  chatRoomId: _generateChatRoomId(
                    widget.receiverUserId,
                    _firebaseAuth.currentUser!.uid,
                  ),
                  partnerName: widget.receivername,
                );
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
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

    if (currentUserId == null || widget.receiverUserId.isEmpty) {
      return const Center(child: Text("Erreur : utilisateur non connecté."));
    }

    final chatRoomId = _generateChatRoomId(
      widget.receiverUserId,
      currentUserId,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // منع حدوث أخطاء عند التمرير
        return true;
      },
      child: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('chatRooms')
                .doc(chatRoomId)
                .collection('messages')
                .orderBy('timestamp', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          // 1. التحقق من حالة الاتصال أولاً
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. معالجة الأخطاء
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. حالة عدم وجود بيانات
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('no messages yet'));
          }

          // 4. التمرير التلقائي بشكل آمن
          Future.delayed(Duration.zero, () {
            if (_scrollController.hasClients && mounted) {
              try {
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent,
                );
              } catch (e) {
                debugPrint('Scroll error: $e');
              }
            }
          });

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final data = document.data() as Map<String, dynamic>;
              final isMe = data['senderId'] == currentUserId;

              // 5. التحقق من mounted قبل أي عملية تستخدم context
              if (!mounted) return const SizedBox();

              return _buildMessageItem(context, document, data, isMe);
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    QueryDocumentSnapshot document,
    Map<String, dynamic> data,
    bool isMe,
  ) {
    final isSelected = _selectedMessageId == document.id;
    final isImage = data['contentType'] == 'image' && data['imageUrl'] != null;
    final isDeleted = data['isDeleted'] == true;

    if (isDeleted) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        GestureDetector(
          onLongPress: () async {
            if (!mounted) return;

            // 1. تأثير اهتزاز أكثر نعومة
            await Future.wait([
              HapticFeedback.lightImpact(),
              // تأثير حركي صغير
              SystemSound.play(SystemSoundType.click),
            ]);

            // 2. تأثير حركي عند التحديد/إلغاء التحديد
            await Future.delayed(const Duration(milliseconds: 50));

            if (mounted) {
              setState(() {
                _selectedMessageId = isSelected ? null : document.id;
              });
            }

            // 3. تحسين توقيت الإغلاق التلقائي مع تأثير التلاشي
            if (_selectedMessageId == document.id && mounted) {
              await Future.delayed(const Duration(seconds: 2));

              if (mounted && _selectedMessageId == document.id) {
                // إضافة تأثير حركي عند الإغلاق
                await HapticFeedback.selectionClick();
                if (mounted) {
                  setState(() => _selectedMessageId = null);
                }
              }
            }
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
                if (!isMe)
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
                      Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Material(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 15 : 0),
                            bottomRight: Radius.circular(isMe ? 15 : 15),
                          ),
                          elevation: 0,
                          color:
                              isImage
                                  ? Colors.transparent
                                  : (isMe
                                      ? Color.fromARGB(255, 0, 143, 48)
                                      : Color.fromARGB(255, 0, 0, 0)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child:
                                isImage
                                    ? GestureDetector(
                                      onTap:
                                          () =>
                                              _showFullImage(data['imageUrl']),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data['imageUrl'],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    : Text(
                                      data['message'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        if (isSelected && isMe)
          Positioned(
            top: 8,
            right: isMe ? null : 45,
            left: isMe ? 45 : null,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, size: 18),
                      color: Colors.blueGrey[700],
                      splashRadius: 20,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data['message']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('The message has been copied'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        setState(() => _selectedMessageId = null);
                      },
                    ),
                    Container(height: 20, width: 1, color: Colors.grey[300]),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20),
                      color: Colors.blueGrey[700],
                      splashRadius: 20,
                      onPressed: () {
                        _showDeleteDialog(
                          context,
                          document.id,
                          _generateChatRoomId(
                            widget.receiverUserId,
                            _firebaseAuth.currentUser!.uid,
                          ),
                        );
                        setState(() => _selectedMessageId = null);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    String messageId,
    String chatRoomId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text('Do you really want to delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId)
            .update({'isDeleted': true});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'An error occurred while deleting the message: ${e.toString()}',
              ),
            ),
          );
        }
      }
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) =>
              Dialog(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate,
              color: Colors.grey.shade700,
              size: 31,
            ),
            onPressed: _pickAndSendImage,
          ),
          const SizedBox(width: 8),
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

  Future<void> _pickAndSendImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      // عرض مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final imageFile = File(pickedFile.path);
      await _chatService.sendMessage(
        receiverUserId: widget.receiverUserId,
        imageFile: imageFile,
      );

      // إغلاق مؤشر التحميل بعد الإرسال
      Navigator.of(context).pop();
      _scrollToBottom();
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل في حالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while sending the image: ${e.toString()}',
          ),
        ),
      );
    }
  }
}
