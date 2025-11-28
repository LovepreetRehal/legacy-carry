// lib/services/chat_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream messages
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // 🔥 Update last message + chat room info
  // ---------------------------------------------------------------------------
  Future<void> _updateChatRoom({
    required String chatId,
    required String lastMessage,
    required String senderId,
    required String receiverId,
    required String senderName,
    required String receiverName,
  }) async {
    await _firestore.collection('chats').doc(chatId).set({
      'users': [senderId, receiverId],
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'userNames': {
        senderId: senderName,
        receiverId: receiverName,
      },
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // 🔥 Send Text Message + Update Last Message
  // ---------------------------------------------------------------------------
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String receiverName,
    required String text,
    required String senderName,
  }) async {
    final msgRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await msgRef.set({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': 'text',
      'attachmentUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update chat room
    await _updateChatRoom(
      chatId: chatId,
      lastMessage: text,
      senderId: senderId,
      receiverId: receiverId,
      senderName: senderName,
      receiverName: receiverName,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔥 Send Image + Update Last Message
  // ---------------------------------------------------------------------------
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String receiverName,
    required File file,
    required String senderName,
  }) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('chatAttachments/$chatId/$fileName');

    final TaskSnapshot snapshot = await ref.putFile(file);
    final String url = await snapshot.ref.getDownloadURL();

    final msgRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await msgRef.set({
      'text': '',
      'senderId': senderId,
      'senderName': senderName,
      'type': 'image',
      'attachmentUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update chat room
    await _updateChatRoom(
      chatId: chatId,
      lastMessage: "📷 Image",
      senderId: senderId,
      receiverId: receiverId,
      senderName: senderName,
      receiverName: receiverName,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔥 Chat List (Loads user name, image, lastMessage, time)
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> getUserChatRooms(String myId) {
    return _db
        .collection('chats')
        .where('users', arrayContains: myId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> list = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final chatId = doc.id;

        // Get other user
        final List users = data['users'];
        final otherId = users.firstWhere((u) => u != myId);

        // Fetch user details
        final docId = otherId.toString();
        final userDoc = await _db.collection('users').doc(docId).get();

        String otherName = 'Unknown';
        String otherImg = '';

        if (userDoc.exists) {
          final userData = userDoc.data() ?? <String, dynamic>{};
          otherName = userData['name']?.toString() ?? otherName;
          otherImg = userData['image']?.toString() ?? otherImg;
        }

        if (otherName == 'Unknown') {
          final storedNames =
              (data['userNames'] as Map<String, dynamic>?) ?? {};
          final fallbackName = storedNames[docId]?.toString();
          if (fallbackName != null && fallbackName.isNotEmpty) {
            otherName = fallbackName;
          } else {
            otherName = 'User $docId';
          }
        }

        list.add({
          'chatId': chatId,
          'otherId': docId,
          'name': otherName,
          'image': otherImg,
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'],
        });
      }

      return list;
    });
  }

  Future<void> upsertUserProfile({
    required String userId,
    required String name,
    String imageUrl = '',
  }) async {
    if (userId.isEmpty) return;
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'image': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
