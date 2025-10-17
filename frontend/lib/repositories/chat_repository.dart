import '../core/network/api_client.dart';
import '../core/endpoints.dart';

class ChatRepository {
  final ApiClient _api = ApiClient();

  /// Sends a question to the backend RAG/chat endpoint.
  /// Payload: { "question": "..." }
  Future<String> ask(String question) async {
    final data = await _api.postData(Endpoints.chatAsk, data: {'question': question});
    // Expect backend returns a text answer either as string or { data: '...' } or { answer: '...' }
    if (data is String) return data;
    if (data is Map) {
      if (data.containsKey('answer') && data['answer'] is String) return data['answer'] as String;
      if (data.containsKey('data') && data['data'] is String) return data['data'] as String;
    }
    return data?.toString() ?? '';
  }
}
