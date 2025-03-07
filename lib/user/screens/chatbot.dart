import 'package:fitness_app/fit_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Update a progress bar or loader if required.
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Error loading resource: \${error.description}');
          },
        ),
      )
      ..loadHtmlString('''
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Chatbot</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                background-color: #f0f0f0;
              }
              iframe {
                width: 100%;
                max-width: 400px;
                height: 90vh;
                border: none;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                border-radius: 10px;
              }
            </style>
          </head>
          <body>
            <iframe
              src="https://www.chatbase.co/chatbot-iframe/l72KgLfoNuRt2x4prrsSm"
              allow="camera; microphone; autoplay; encrypted-media"
            ></iframe>
          </body>
          </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const Counterapp()),);
              },
              child: const Text("Click Me"),
            ),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
