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
  String _selectedRecipient = 'admin'; // Default recipient (admin)

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userId = user?.uid;
    final userName = user?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('user_messages')
                  .where('receiverId', isEqualTo: 'admin_id') // Messages sent to admin
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageData = message.data() as Map<String, dynamic>;

                    bool isSentByUser = messageData['senderId'] == userId;
                    String senderName = messageData['senderName'];
                    String senderRole = messageData['senderRole'];

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSentByUser ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByUser ? "You" : "$senderName ($senderRole)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSentByUser ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageData['message'],
                              style: TextStyle(
                                color: isSentByUser ? Colors.white : Colors.black,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRecipient,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    DropdownMenuItem(value: 'trainer', child: Text("Trainer")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecipient = value!;
                    });
                  },
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

  void _sendMessage(String? userId, String userName) async {
    if (_messageController.text.isEmpty || userId == null) return;

    String receiverId = 'admin_id'; // Admin's user ID

    await _firestore.collection('user_messages').add({
      'senderId': userId,
      'senderName': userName,
      'senderRole': 'user',
      'receiverId': receiverId,
      'receiverName': 'Admin',
      'message': _messageController.text,
      'timestamp': Timestamp.now(),
    });

    _messageController.clear();
  }
}
