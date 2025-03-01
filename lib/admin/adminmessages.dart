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
  final bool _isSendingMessage = false;

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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('user_messages')
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

                    String senderId = messageData['senderId'];
                    String senderName = messageData['senderName'] ?? "Unknown";
                    String messageText = messageData['message'];
                    Timestamp timestamp = messageData['timestamp'];
                    DateTime messageTime = timestamp.toDate();
                    String formattedTime = "${messageTime.hour}:${messageTime.minute}";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(senderName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(messageText),
                      trailing: Text(formattedTime, style: const TextStyle(fontSize: 12)),
                      onTap: () => _showReplyDialog(senderId, senderName),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Opens a dialog box to reply to the selected user's message
  void _showReplyDialog(String userId, String userName) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to $userName"),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: "Type your reply..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _sendReply(userId, userName, replyController.text);
                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  /// Sends a reply and stores it in Firebase for users to fetch
  Future<void> _sendReply(String userId, String userName, String message) async {
    if (message.isEmpty) return;

    final admin = _auth.currentUser;
    final adminId = admin?.uid;
    final adminName = admin?.displayName ?? "Admin";

    try {
      await _firestore.collection('admin_messages').add({
        'senderId': adminId,
        'senderName': adminName,
        'senderRole': 'admin',
        'receiverId': userId,
        'receiverName': userName,
        'message': message,
        'timestamp': Timestamp.now(),
      });

      // Also store in user_messages for the user to fetch
      await _firestore.collection('user_messages').add({
        'senderId': adminId,
        'senderName': adminName,
        'senderRole': 'admin',
        'receiverId': userId,
        'receiverName': userName,
        'message': message,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reply: $e')),
      );
    }
  }
}
