import 'package:flutter/material.dart';

class test1 extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserEmail;
  final String receiverUserProfileImage;
  final String receiverUserUsername;

  const test1({
    super.key,
    required this.receiverUserId,
    required this.receiverUserEmail,
    required this.receiverUserProfileImage,
    required this.receiverUserUsername,
  });

  @override
  State<test1> createState() => _test1State();
}

class _test1State extends State<test1> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  String? _selectedMessageId;

  // قائمة لتخزين الرسائل
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // إضافة بعض الرسائل الوهمية عند بدء التشغيل
    _messages = [
      {
        'message': 'Hello there!',
        'senderId': widget.receiverUserId,
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'senderProfileImage': widget.receiverUserProfileImage,
      },
      {
        'message': 'Hi! How are you?',
        'senderId': 'current-user-id',
        'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
      },
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // إنشاء رسالة جديدة
    final newMessage = {
      'message': _messageController.text.trim(),
      'senderId': 'current-user-id', // معرّف المستخدم الحالي
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(newMessage); // إضافة الرسالة إلى القائمة
    });

    _messageController.clear();

    // هنا يمكنك إضافة كود لإرسال الرسالة إلى الخادم/الخلفية
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
    return 
    Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              radius: 22,
              backgroundImage: AssetImage(widget.receiverUserProfileImage),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverUserUsername,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold , color: Color.fromARGB(255, 0, 143, 48)),
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final data = _messages[index];
        final isMe = data['senderId'] != widget.receiverUserId;
        final isSelected = _selectedMessageId == index.toString();

        return GestureDetector(
          onLongPress: () {
            setState(() {
              _selectedMessageId = isSelected ? null : index.toString();
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
                          color: isMe ? Color.fromARGB(255, 0, 143, 48) : Color.fromARGB(255, 0, 0, 0),
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
