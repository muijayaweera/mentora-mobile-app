import 'package:cloud_functions/cloud_functions.dart';

class ChatService {
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<String> sendMessage(String message) async {
    try {
      final trimmedMessage = message.trim();
      if (trimmedMessage.isEmpty) {
        return "Please enter a message.";
      }

      print("📤 Sending: $trimmedMessage");

      final callable = _functions.httpsCallable('chatWithMentoraV2');

      final result = await callable.call({
        'message': trimmedMessage,
      });

      print("📥 Raw result: ${result.data}");

      final data = result.data;

      if (data is Map) {
        final reply = data['reply'];
        if (reply != null && reply.toString().trim().isNotEmpty) {
          return reply.toString();
        }
      }

      return "Mentora couldn’t process that response properly.";
    } on FirebaseFunctionsException catch (e) {
      print("🔥 Firebase error: ${e.code} - ${e.message}");
      print("🔥 Firebase details: ${e.details}");

      if (e.code == 'unauthenticated') {
        return "Server error: UNAUTHENTICATED";
      }

      return e.message != null && e.message!.trim().isNotEmpty
          ? "Server error: ${e.message}"
          : "Server error. Please try again.";
    } catch (e) {
      print("❌ General error: $e");
      return "Network error. Please try again.";
    }
  }
}