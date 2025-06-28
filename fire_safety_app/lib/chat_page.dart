// ✅ UNCHANGED IMPORTS & CLASS
// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// ✅ START OF ChatPage
class ChatPage extends StatefulWidget {
  final String userId;
  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  Uint8List? profileImageBytes;
  bool isLoading = true;
  bool isTyping = false;

  late GenerativeModel _model;
  late ChatSession _chat;

  Uint8List? _pendingImage;
  String? _pendingMimeType;

  final String _systemInstruction = '''
You are Flamo — an AI assistant trained to guide hotel staff in fire safety, emergency response, fire drills, extinguisher use, and evacuation procedures.
Respond only to questions related to fire safety. Politely reject unrelated topics.
If a user gives greetings, then you have to give the greetings. Also store the previous message for better output.
Never say that you are a chatbot. Instead, say that you are Flamo.
Never use fire safety word directly. 
use voice modulation human like voice. and also use simple words so that the normal people can understand very easily.
''';

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _loadMessagesFromFirestore();
    fetchUserData();
  }

  Future<void> _initializeGemini() async {
    const apiKey = 'AIzaSyAs6Pe5WPeUY327xCtUkvkiWMTCedLBdUk';
    _model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    _chat = _model.startChat();
  }

  Future<void> fetchUserData() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId);
    try {
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});
      }

      final data = (await userDoc.get()).data();
      final base64Image = data?['profile'] as String?;
      if (base64Image != null && base64Image.isNotEmpty) {
        final cleanedBase64 =
            base64Image.contains(',') ? base64Image.split(',').last : base64Image;
        final decoded = base64Decode(cleanedBase64);
        setState(() {
          profileImageBytes = decoded;
          isLoading = false;
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].isUser && _messages[i].userImageBytes == null) {
              _messages[i] = _messages[i].copyWith(userImageBytes: decoded);
            }
          }
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMessagesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('chats')
          .orderBy('timestamp')
          .get();

      final fetchedMessages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          text: data['text'] ?? '',
          isUser: data['isUser'] ?? false,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          image: data['image'] != null ? base64Decode(data['image']) : null,
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(fetchedMessages);
      });
    } catch (e) {
      print('⚠️ Failed to load messages from Firestore: $e');
    }
  }

  Future<void> _saveMessageToCloud(
    String text,
    bool isUser,
    DateTime timestamp,
    Uint8List? imageBytes,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('chats')
        .add({
          'text': text,
          'isUser': isUser,
          'timestamp': Timestamp.fromDate(timestamp),
          'image': imageBytes != null ? base64Encode(imageBytes) : null,
        });
  }

  String? _getMimeTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 12) return null;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final mime = _getMimeTypeFromBytes(bytes);

      if (mime == null) {
        _showError("Unsupported file type");
        return;
      }

      setState(() {
        _pendingImage = bytes;
        _pendingMimeType = mime;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: "❌ $message",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty && _pendingImage == null) return;

    final now = DateTime.now();
    final imageToSend = _pendingImage;

    setState(() {
      _messages.add(ChatMessage(
        text: message.isNotEmpty ? message : "[Image]",
        isUser: true,
        timestamp: now,
        image: imageToSend,
        userImageBytes: profileImageBytes,
      ));
      isTyping = true;
    });

    final parts = <Part>[TextPart(_systemInstruction)];
    if (message.isNotEmpty) parts.add(TextPart(message));
    if (_pendingImage != null && _pendingMimeType != null) {
      parts.add(DataPart(_pendingMimeType!, _pendingImage!));
    }

    _textController.clear();
    _pendingImage = null;
    _pendingMimeType = null;

    await _saveMessageToCloud(
      message.isNotEmpty ? message : "[Image]",
      true,
      now,
      imageToSend,
    );

    try {
      final response = await _chat.sendMessage(Content.multi(parts));
      final reply = response.text ?? 'No response from Flamo.';
      final botTime = DateTime.now();
      setState(() {
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          timestamp: botTime,
        ));
        isTyping = false;
      });
      await _saveMessageToCloud(reply, false, botTime, null);
    } catch (e) {
      _showError("Failed to send: $e");
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _getDateLabel(String dateKey) {
    final now = DateTime.now();
    final date = DateTime.parse(dateKey);
    if (DateUtils.isSameDay(now, date)) return "Today";
    if (DateUtils.isSameDay(now.subtract(const Duration(days: 1)), date)) {
      return "Yesterday";
    }
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dateGroups = <String, List<ChatMessage>>{};
    for (var msg in _messages) {
      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      dateGroups.putIfAbsent(dateKey, () => []).add(msg);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("🔥 Flamo - Chat Bot", style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: dateGroups.entries.expand((entry) => [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getDateLabel(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      ...entry.value,
                    ]).toList(),
                  ),
                ),
                if (isTyping)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 4, bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundImage: AssetImage('lib/assets/flamoBot.png')),
                        SizedBox(width: 10),
                        TypingIndicator(),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      if (_pendingImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_pendingImage!, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickImage),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => _sendMessage(_textController.text.trim()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ✅ The ChatMessage + TypingIndicator widgets are unchanged (already working)



class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? userImageBytes;
  final Uint8List? image;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.userImageBytes,
    this.image,
  });

  ChatMessage copyWith({Uint8List? userImageBytes}) {
    return ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      image: image,
      userImageBytes: userImageBytes ?? this.userImageBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? Colors.white : Colors.orange.shade100;
    final formattedTime = DateFormat('hh:mm a').format(timestamp);
    final avatar = Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
              isUser
                  ? (userImageBytes != null
                      ? MemoryImage(userImageBytes!)
                      : const AssetImage('lib/assets/user_avatar.png')
                          as ImageProvider)
                  : const AssetImage('lib/assets/flamoBot.png'),
        ),
        const SizedBox(height: 4),
        Text(isUser ? 'You' : 'Flamo', style: const TextStyle(fontSize: 12)),
      ],
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) avatar,
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (image != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Image.memory(
                              image!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 180),
                          padding: const EdgeInsets.only(top: 8),
                          alignment: Alignment.centerLeft,
                          child: MarkdownBody(data: text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isUser) avatar,
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> anim) {
    return AnimatedBuilder(
      animation: anim,
      builder:
          (_, child) =>
              Transform.translate(offset: Offset(0, anim.value), child: child),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: CircleAvatar(radius: 4, backgroundColor: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: _animations.map(_buildDot).toList());
  }
}
