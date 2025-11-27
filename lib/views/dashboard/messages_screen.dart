import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../chat_screen.dart';
import '../services/chat_service.dart';

class MessagesScreen extends StatelessWidget {
  final String myId = "4"; // your user id
  final ChatService chatService = ChatService();

  MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFB139), Color(0xFFB9AE3C), Color(0xFF3CA349)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Messages",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.search, color: Colors.white),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _addTestData(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: StreamBuilder(
                  stream: chatService.getUserChatRooms(myId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chats = snapshot.data!;

                    if (chats.isEmpty) {
                      return const Center(
                          child: Text("No messages",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, i) {
                        final chat = chats[i];
                        final name = chat['name'];
                        final img = chat['image'];
                        final lastMsg = chat['lastMessage'];
                        final time = chat['lastMessageTime'] == null
                            ? ""
                            : _formatTime(chat['lastMessageTime'].toDate());

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: img.isEmpty
                                ? null
                                : NetworkImage(img),
                            child: img.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(name,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(lastMsg),
                          trailing: Text(time),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat['chatId'],
                                  myId: myId,
                                  myName: "Lovepreet",
                                  otherName: name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    return "${t.hour}:${t.minute.toString().padLeft(2, '0')}";
  }

  void _addTestData(BuildContext context) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Adding Test Data...")),
    );

    try {
      /// ---------------- USERS ----------------
      await db.collection("users").doc("2").set({
        "name": "Rahul Sharma",
        "image": "",
      });

      await db.collection("users").doc("5").set({
        "name": "Amit Kumar",
        "image": "",
      });

      await db.collection("users").doc("7").set({
        "name": "Reet pagl ",
        "image": "",
      });

      /// ---------------- CHAT ROOMS ----------------
      List<Map<String, dynamic>> chatRooms = [
        {
          "chatId": "4_2",
          "otherId": "2",
          "lastMessage": "Hey Lovepreet, reached?",
          "lastMessageTime": FieldValue.serverTimestamp(),
        },
        {
          "chatId": "4_5",
          "otherId": "5",
          "lastMessage": "Typing...",
          "lastMessageTime": FieldValue.serverTimestamp(),
        },
        {
          "chatId": "4_7",
          "otherId": "7",
          "lastMessage": "Okay 👍",
          "lastMessageTime": FieldValue.serverTimestamp(),
        },
      ];

      for (var room in chatRooms) {
        await db.collection("chats").doc(room["chatId"]).set({
          "users": ["4", room["otherId"]],
          "lastMessage": room["lastMessage"],
          "lastMessageTime": room["lastMessageTime"],
        });

        /// Add sample messages inside chat
        await db
            .collection("chats")
            .doc(room["chatId"])
            .collection("messages")
            .add({
          "senderId": "4",
          "senderName": "Lovepreet",
          "text": "Hello ${room["otherId"]}",
          "type": "text",
          "createdAt": FieldValue.serverTimestamp(),
        });

        await db
            .collection("chats")
            .doc(room["chatId"])
            .collection("messages")
            .add({
          "senderId": room["otherId"],
          "senderName": "Test User",
          "text": room["lastMessage"],
          "type": "text",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test Data Added Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

}
