// lib/services/chat_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Stream messages with proper generic typing
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': 'text',
      'attachmentUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendImageMessage({
    required String chatId,
    required File file,
    required String senderId,
    required String senderName,
  }) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('chatAttachments/$chatId/$fileName');

    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    final String url = await snapshot.ref.getDownloadURL();

    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'text': '',
      'senderId': senderId,
      'senderName': senderName,
      'type': 'image',
      'attachmentUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
