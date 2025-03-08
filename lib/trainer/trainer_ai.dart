import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerAIPage extends StatefulWidget {
  const TrainerAIPage({super.key});

  @override
  _TrainerAIPageState createState() => _TrainerAIPageState();
}

class _TrainerAIPageState extends State<TrainerAIPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _editData(String docId, Map<String, dynamic> data) {
    TextEditingController controller = TextEditingController(text: data['content']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit AI Data'),
        content: TextField(controller: controller),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('ai_data').doc(docId).update({'content': controller.text});
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteData(String docId) async {
    await _firestore.collection('ai_data').doc(docId).delete();
  }

  void _verifyData(String docId) async {
    await _firestore.collection('ai_data').doc(docId).update({'verified': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Data Verification')),
      body: StreamBuilder(
        stream: _firestore.collection('ai_data').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No AI Data Available'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data?['content'] ?? 'No Content'),
                  subtitle: Text(data?['verified'] == true ? 'Verified' : 'Pending Verification'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editData(doc.id, data!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteData(doc.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.verified, color: Colors.green),
                        onPressed: () => _verifyData(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}