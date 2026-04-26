import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _chatsRef {
    return _firestore.collection("users").doc(_uid).collection("chats");
  }

  Future<String> createChat(String firstMessage) async {
    final title = firstMessage.length > 35
        ? "${firstMessage.substring(0, 35)}..."
        : firstMessage;

    final doc = await _chatsRef.add({
      "title": title,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> saveMessage({
    required String chatId,
    required String text,
    required bool isUser,
  }) async {
    await _chatsRef.doc(chatId).collection("messages").add({
      "text": text,
      "isUser": isUser,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _chatsRef.doc(chatId).update({
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats() {
    return _chatsRef.orderBy("updatedAt", descending: true).snapshots();
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final snap = await _chatsRef
        .doc(chatId)
        .collection("messages")
        .orderBy("createdAt", descending: false)
        .get();

    return snap.docs.map((doc) => doc.data()).toList();
  }

  Future<void> deleteChat(String chatId) async {
    final messages = await _chatsRef.doc(chatId).collection("messages").get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    await _chatsRef.doc(chatId).delete();
  }
}