import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMessageScreen extends StatefulWidget {
  const UserMessageScreen({super.key});

  @override
  _UserMessageScreenState createState() => _UserMessageScreenState();
}

class _UserMessageScreenState extends State<UserMessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final String adminId = 'admin'; // Admin user identifier

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userId = user?.uid;
    final userName = user?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Admin"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('user_messages')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;
                debugPrint("Fetched Messages Count: ${messages.length}");

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    debugPrint("Message Data: $message");

                    bool isSentByUser = message['senderId'] == userId;
                    String senderName = message['senderName'];
                    String messageText = message['message'];
                    Timestamp timestamp = message['timestamp'];
                    DateTime messageTime = timestamp.toDate();
                    String formattedTime =
                        "${messageTime.hour}:${messageTime.minute}";

                    return Align(
                      alignment:
                          isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSentByUser ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isSentByUser
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isSentByUser
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByUser ? "You" : senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSentByUser ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageText,
                              style: TextStyle(
                                color: isSentByUser ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSentByUser ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input box for sending messages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage(userId, userName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to send a message
  Future<void> _sendMessage(String? userId, String userName) async {
    if (_messageController.text.isEmpty || userId == null) return;

    try {
      await _firestore.collection('user_messages').add({
        'senderId': userId,
        'senderName': userName,
        'receiverId': adminId,
        'receiverName': 'Admin',
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }
}
