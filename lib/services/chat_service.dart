import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تحسين إرسال الرسائل
  Future<void> sendMessage(String receiverUserId, String message) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return;

      final newMessage = Message(
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        sendername: currentUser.displayName ?? 'مستخدم',
        senderphotoUrl: currentUser.photoURL ?? '',
        receiverId: receiverUserId,
        message: message,
        timestamp: Timestamp.now(),
      );

      final ids = [currentUser.uid, receiverUserId]..sort();
      final chatRoomId = ids.join('_');

      // إضافة رسالة جديدة
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

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


      // تحديث آخر رسالة في الغرفة مع حالة الرسالة غير المقروءة
      await _firestore.collection('chatRooms').doc(chatRoomId).set({
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
        'participants': ids,
        'unreadBy': [receiverUserId], // إضافة المستخدم الذي لم يقرأ الرسالة
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error sending message: $e");
      rethrow;
    }
  }

  // تحسين جلب الرسائل
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final ids = [userId, otherUserId]..sort();
    final chatRoomId = ids.join('_');

    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // جلب قائمة المحادثات الحديثة
  Stream<QuerySnapshot> getRecentChats(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // جلب معلومات المستخدمين الذين تم التواصل معهم
  static Future<List<Map<String, dynamic>>> getChatPartners() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final snapshot =
          await FirebaseFirestore.instance
              .collection('chatRooms')
              .where('participants', arrayContains: currentUser.uid)
              .get();

      final partnerIds =
          snapshot.docs
              .expand((doc) => doc['participants'] as List<dynamic>)
              .where((id) => id != currentUser.uid)
              .toSet();

      final usersData = <Map<String, dynamic>>[];

      for (final id in partnerIds) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();

        if (userDoc.exists) {
          usersData.add({'id': id, ...?userDoc.data()});
        }
      }

      return usersData;
    } catch (e) {
      debugPrint("Error getting chat partners: $e");
      return [];
    }
  }

  Future<void> markMessagesAsRead(
    String receiverUserId,
    String senderUserId,
  ) async {
    final ids = [receiverUserId, senderUserId]..sort();
    final chatRoomId = ids.join('_');

    try {
      final chatRoomSnapshot =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();
      final unreadBy = List<String>.from(chatRoomSnapshot['unreadBy'] ?? []);

      if (unreadBy.contains(receiverUserId)) {
        unreadBy.remove(receiverUserId);
        // تحديث حالة الرسائل إلى مقروءة
        await _firestore.collection('chatRooms').doc(chatRoomId).update({
          'unreadBy': unreadBy,
          'unreadCount': 0,
        });
      }
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
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
  bool isRead;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.sendername,
    required this.senderphotoUrl,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
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
      isRead: map['isRead'] ?? false,
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
      'isRead': isRead,
    };
  }
}
