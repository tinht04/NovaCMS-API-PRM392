import 'package:flutter/foundation.dart';
import '../repositories/chat_repository.dart';

class ChatMessage {
  final String text;
  final bool fromUser;
  ChatMessage(this.text, {this.fromUser = false});
}

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  final List<ChatMessage> messages = [];
  bool loading = false;

  Future<void> send(String question) async {
    if (question.trim().isEmpty) return;
    if (loading) return; // guard: don't send while already waiting for response
    messages.add(ChatMessage(question, fromUser: true));
    loading = true;
    notifyListeners();
    try {
      final resp = await _repo.ask(question);
      messages.add(ChatMessage(resp, fromUser: false));
    } catch (e) {
      messages.add(ChatMessage('Error: ${e.toString()}', fromUser: false));
    }
    loading = false;
    notifyListeners();
  }
}
