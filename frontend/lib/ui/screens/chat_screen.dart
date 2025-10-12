import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(children: [
        const Expanded(child: Center(child: Text('Chat messages appear here'))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Ask a question'))),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send))
          ]),
        )
      ]),
    );
  }
}
