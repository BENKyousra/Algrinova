import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'cloudinary_service.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة مساعدة لتحديد نوع المحتوى
  String _determineContentType(String message, File? imageFile) {
    if (imageFile != null) return 'image';
    return 'text';
  }

  // إرسال رسالة نصية أو صورة
  Future<void> sendMessage({
    required String receiverUserId,
    String? message,
    File? imageFile,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return;

      String? imageUrl;
      String? finalMessage;

      if (imageFile != null) {
        // رفع الصورة إلى Cloudinary
        imageUrl = await CloudinaryService.uploadImageToCloudinary(imageFile);
        if (imageUrl == null) throw Exception('Failed to upload image');
        finalMessage = 'image 📷 '; // نص بديل للصورة
      } else if (message != null && message.isNotEmpty) {
        finalMessage = message;
      } else {
        throw Exception('Either message or image must be provided');
      }

      final contentType = _determineContentType(finalMessage, imageFile);

      final newMessage = Message(
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        sendername: currentUser.displayName ?? 'مستخدم',
        senderphotoUrl: currentUser.photoURL ?? '',
        receiverId: receiverUserId,
        message: finalMessage,
        timestamp: Timestamp.now(),
        contentType: contentType,
        imageUrl: imageUrl,
      );

      final ids = [currentUser.uid, receiverUserId]..sort();
      final chatRoomId = ids.join('_');

      // إضافة الرسالة الجديدة
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      // تحديث حالة القراءة للرسائل السابقة
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: receiverUserId)
          .where('isRead', isEqualTo: false)
          .get()
          .then((querySnapshot) async {
            for (var doc in querySnapshot.docs) {
              await doc.reference.update({'isRead': true});
            }
          });

      // تحديث آخر رسالة في الغرفة
      await _firestore.collection('chatRooms').doc(chatRoomId).set({
        'lastMessage': contentType == 'image' ? 'image 📷 ' : finalMessage,
        'lastMessageTime': Timestamp.now(),
        'participants': ids,
        'unreadBy': [receiverUserId],
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error sending message: $e");
      rethrow;
    }
  }

  Future<bool> deleteChat({
    required BuildContext context,
    required String chatRoomId,
    required String partnerName,
  }) async {
    // تأكيد الحذف (بنفس التصميم)
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Chat'),
                content: const Text('do you really want to delete this chat?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return false;

    try {
      // حذف الرسائل أولاً
      final messages =
          await _firestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .collection('messages')
              .get();

      final batch = _firestore.batch();
      for (var msg in messages.docs) {
        batch.delete(msg.reference);
      }

      // حذف غرفة الدردشة
      batch.delete(_firestore.collection('chatRooms').doc(chatRoomId));
      await batch.commit();

      // إظهار الإشعار
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your conversation with $partnerName has been deleted.',
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the message'),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> deleteMessage({
    required BuildContext context,
    required String chatRoomId,
    required String messageId,
    required bool isSender,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return false;

      final messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      // يمكننا إما حذف الرسالة تماماً أو وضع علامة أنها محذوفة
      // هنا سنستخدم طريقة وضع علامة للحفاظ على سجل المحادثة
      await messageRef.update({
        'isDeleted': true,
        'deletedBy': currentUser.uid,
        'deletedAt': Timestamp.now(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('the message has been deleted')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the message.'),
          ),
        );
      }
      debugPrint("Error deleting message: $e");
      return false;
    }
  }
}

class Message {
  final String senderId;
  final String senderEmail;
  final String sendername;
  final String senderphotoUrl;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String contentType; // 'text' أو 'image'
  final String? imageUrl; // رابط الصورة إذا كانت موجودة
  bool isRead;
  final bool isDeleted;
  final String? deletedBy;
  final Timestamp? deletedAt;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.sendername,
    required this.senderphotoUrl,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.contentType = 'text',
    this.imageUrl,
    this.isRead = false,
    this.isDeleted = false,
    this.deletedBy,
    this.deletedAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      sendername: map['sendername'] ?? 'Unknown',
      senderphotoUrl: map['senderphotoUrl'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      contentType: map['contentType'] ?? 'text',
      imageUrl: map['imageUrl'],
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      deletedBy: map['deletedBy'],
      deletedAt: map['deletedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'sendername': sendername,
      'senderphotoUrl': senderphotoUrl,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'contentType': contentType,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'isDeleted': isDeleted,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,
    };
  }
}
