import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMessageScreen extends StatefulWidget {
  const AdminMessageScreen({super.key});

  @override
  _AdminMessageScreenState createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  String _selectedRecipient = 'all'; // Default recipient (All users)

  @override
  Widget build(BuildContext context) {
    final admin = _auth.currentUser;
    final adminId = admin?.uid;
    final adminName = admin?.displayName ?? "Admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Message list display
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('user_messages')
                  .where('receiverId', isEqualTo: 'admin_id') // Messages from users to admin
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

                    bool isSentByAdmin = messageData['senderId'] == 'admin_id';
                    String senderName = messageData['senderName'];
                    String senderRole = messageData['senderRole'];
                    Timestamp timestamp = messageData['timestamp'];
                    DateTime messageTime = timestamp.toDate();
                    String formattedTime =
                        "${messageTime.hour}:${messageTime.minute}";

                    return Align(
                      alignment: isSentByAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSentByAdmin
                              ? Colors.deepPurple
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByAdmin
                                  ? "You"
                                  : "$senderName ($senderRole)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSentByAdmin
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageData['message'],
                              style: TextStyle(
                                color: isSentByAdmin
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSentByAdmin
                                    ? Colors.white70
                                    : Colors.black45,
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

          // Message input area
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Recipient Dropdown
                DropdownButton<String>(
                  value: _selectedRecipient,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text("All Users")),
                    DropdownMenuItem(value: 'user_id', child: Text("Specific User")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecipient = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage(adminId, adminName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to send a message
  void _sendMessage(String? adminId, String adminName) async {
    if (_messageController.text.isEmpty || adminId == null) return;

    String receiverId = _selectedRecipient == 'all'
        ? 'all_users' // Broadcast to all users
        : _selectedRecipient; // Send to a specific user

    String receiverName = _selectedRecipient == 'all' ? "All Users" : "User";

    // Add message to Firestore
    await _firestore.collection('admin_messages').add({
      'senderId': adminId,
      'senderName': adminName,
      'senderRole': 'admin',
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': _messageController.text,
      'timestamp': Timestamp.now(),
    });

    // Add a separate collection for broadcasting to all users
    if (_selectedRecipient == 'all') {
      await _firestore.collection('user_messages').add({
        'senderId': adminId,
        'senderName': adminName,
        'senderRole': 'admin',
        'receiverId': 'all_users', // This is for all users
        'receiverName': 'All Users',
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      });
    }

    // Clear the message input after sending
    _messageController.clear();
  }
}
