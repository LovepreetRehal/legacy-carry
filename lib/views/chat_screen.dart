// lib/chat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String myId;
  final String myName;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myId,
    required this.myName,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chat = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<String> quickReplies = [
    "I am on my way.",
    "Reached",
    "On Break",
    "Can't make it"
  ];

  bool _sending = false;

  Future<void> _sendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await _chat.sendTextMessage(
      chatId: widget.chatId,
      text: text,
      senderId: widget.myId,
      senderName: widget.myName,
    );
    _messageController.clear();
    setState(() => _sending = false);
    _scrollToBottom();
  }

  Future<void> _sendAttachmentFromPicker() async {
    final XFile? pick = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (pick == null) return;
    final file = File(pick.path);
    setState(() => _sending = true);
    await _chat.sendImageMessage(
      chatId: widget.chatId,
      file: file,
      senderId: widget.myId,
      senderName: widget.myName,
    );
    setState(() => _sending = false);
    // _scrollToBottom();
  }

  /// Local test file helper (uses your uploaded file path)
  Future<void> _sendLocalUploadedFileExample() async {
    final path = '/mnt/data/f72c1558-0db9-4eea-bad6-db63bd4ccef2.png';
    final file = File(path);
    if (!file.existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Test file not found')));
      }
      return;
    }
    setState(() => _sending = true);
    await _chat.sendImageMessage(
      chatId: widget.chatId,
      file: file,
      senderId: widget.myId,
      senderName: widget.myName,
    );
    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _messageBubble(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final isMe = data['senderId'] == widget.myId;
    final type = (data['type'] ?? 'text') as String;
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;
    String timeStr = '';
    if (createdAt != null) {
      final dt = createdAt.toDate().toLocal();
      timeStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: EdgeInsets.only(top: 8, left: isMe ? 40 : 8, right: isMe ? 8 : 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[800] : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (type == 'text') ...[
              Text(data['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
            ] else if (type == 'image') ...[
              if ((data['attachmentUrl'] as String?) != null)
                GestureDetector(
                  onTap: () {
                    // implement preview if needed
                  },
                  child: Image.network(
                    data['attachmentUrl'] as String,
                    width: MediaQuery.of(context).size.width * 0.5,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      width: 120,
                      height: 80,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 4),
            Text(timeStr, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black45)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background gradient similar to your design
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                    Text(widget.otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      onPressed: _sendLocalUploadedFileExample, // test upload
                      icon: const Icon(Icons.call, color: Colors.green),
                    ),
                  ],
                ),
              ),

              // chat area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chat.messagesStream(widget.chatId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error loading messages"));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text("No messages yet"));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return _messageBubble(docs[index]);
                        },
                      );
                    },
                  ),
                ),
              ),

              // quick replies row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final t = quickReplies[i];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () {
                          _messageController.text = t;
                          _sendText();
                        },
                        child: Text(t, style: const TextStyle(fontSize: 12)),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: quickReplies.length,
                  ),
                ),
              ),

              // message composer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.link), onPressed: _sendAttachmentFromPicker),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a Message.....',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendText(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _sendText,
                      mini: true,
                      backgroundColor: Colors.green[900],
                      child: const Icon(Icons.send, color: Colors.white),
                    )
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
