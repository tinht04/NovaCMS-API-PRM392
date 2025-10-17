import 'package:flutter/material.dart';
import '../../viewmodels/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatViewModel _vm = ChatViewModel();
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(() {
      setState(() {});
      // scroll to bottom after a short delay so new message is visible
      Future.delayed(const Duration(milliseconds: 50), () { if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut); });
    });
  }

  @override
  void dispose() {
    _vm.removeListener(() {});
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await _vm.send(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(children: [
        Expanded(
          child: _vm.messages.isEmpty
              ? const Center(child: Text('Ask me anything'))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: _vm.messages.length,
                  itemBuilder: (context, i) {
                    final m = _vm.messages[i];
                    return Align(
                      alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: m.fromUser ? Colors.blue.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: Text(m.text),
                      ),
                    );
                  },
                ),
        ),
        if (_vm.loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, enabled: !_vm.loading, onSubmitted: (_) => _vm.loading ? null : _send(), decoration: const InputDecoration(hintText: 'Ask a question'))),
            _vm.loading
                ? const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(onPressed: _send, icon: const Icon(Icons.send))
          ]),
        )
      ]),
    );
  }
}
