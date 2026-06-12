import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import 'chat_history_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AskMeState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? streamingText;
  final String? error;
  final String? currentSessionId;

  AskMeState({
    this.messages = const [],
    this.isLoading = false,
    this.streamingText,
    this.error,
    this.currentSessionId,
  });

  AskMeState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    Object? streamingText = _sentinel,
    String? error,
    Object? currentSessionId = _sentinel,
  }) {
    return AskMeState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      streamingText: identical(streamingText, _sentinel) ? this.streamingText : (streamingText as String?),
      error: error,
      currentSessionId: identical(currentSessionId, _sentinel) ? this.currentSessionId : (currentSessionId as String?),
    );
  }

  static const Object _sentinel = Object();
}

class AskMeNotifier extends StateNotifier<AskMeState> {
  StreamSubscription? _streamSub;
  HttpClient? _client;
  final ChatHistoryNotifier _history;

  AskMeNotifier(this._history) : super(AskMeState());

  static const String _apiKey = ApiConfig.openRouterKey;
  static const String _model = 'openrouter/owl-alpha';

  static const String _systemPrompt = '''
You are a helpful health, nutrition, and fitness assistant.
Provide accurate, science-based advice about diet, exercise, calories, macros, weight management, and healthy living.
Keep responses concise and practical.
Do NOT provide medical diagnoses or prescription advice.
If asked about serious medical conditions, recommend consulting a healthcare professional.
Respond in the same language the user writes in.
''';

  @override
  void dispose() {
    _streamSub?.cancel();
    _client?.close();
    super.dispose();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    _streamSub?.cancel();
    _client?.close();

    String sessionId = state.currentSessionId ?? '';
    if (sessionId.isEmpty) {
      sessionId = _history.createSession(text.trim());
    } else {
      _history.addMessage(sessionId, 'user', text.trim());
    }

    final userMessage = ChatMessage(text: text.trim(), isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      streamingText: null,
      error: null,
      currentSessionId: sessionId,
    );

    try {
      final prevMessages = state.messages
          .where((m) => m != userMessage)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      prevMessages.insert(0, {'role': 'system', 'content': _systemPrompt});
      prevMessages.add({'role': 'user', 'content': text.trim()});

      final body = jsonEncode({
        'model': _model,
        'messages': prevMessages,
        'stream': true,
        'max_tokens': 512,
      });

      _client = HttpClient();
      _client!.connectionTimeout = const Duration(seconds: 30);

      final request = await _client!.postUrl(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      );
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('HTTP-Referer', 'https://calorieflow.app');
      request.headers.set('X-Title', 'Calorie Flow');
      request.add(utf8.encode(body));

      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        String msg = 'Failed to get response.';
        try {
          final errJson = jsonDecode(errorBody);
          msg = errJson['error']?['message'] ?? errJson['message'] ?? msg;
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: msg, streamingText: null);
        return;
      }

      final lineStream = response
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      StringBuffer buffer = StringBuffer();
      bool finished = false;

      _streamSub = lineStream.listen(
        (line) {
          if (finished) return;
          if (!line.startsWith('data: ')) return;
          final data = line.substring(6).trim();
          if (data == '[DONE]') {
            finished = true;
            _finishStreaming(buffer.toString());
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) return;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              buffer.write(content);
              state = state.copyWith(streamingText: buffer.toString());
            }
          } catch (_) {}
        },
        onError: (err) {
          if (finished) return;
          finished = true;
          _finishStreaming(buffer.toString());
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to get complete response.',
            streamingText: null,
          );
        },
        onDone: () {
          if (!finished) {
            _finishStreaming(buffer.toString());
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      String msg = 'Failed to get response. Please try again.';
      state = state.copyWith(isLoading: false, error: msg, streamingText: null);
    }
  }

  void _finishStreaming(String text) {
    if (text.trim().isEmpty) {
      state = state.copyWith(isLoading: false, streamingText: null, error: 'Empty response');
      return;
    }
    final sessionId = state.currentSessionId;
    if (sessionId != null) {
      _history.addMessage(sessionId, 'assistant', text.trim());
    }
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: text.trim(), isUser: false)],
      isLoading: false,
      streamingText: null,
    );
  }

  void loadSession(String sessionId) {
    _streamSub?.cancel();
    _client?.close();

    final sessions = _history.state;
    final session = sessions.where((s) => s.id == sessionId).firstOrNull;
    if (session == null) return;

    state = AskMeState(
      messages: session.messages.map((m) => ChatMessage(
        text: m['content'] as String,
        isUser: m['role'] == 'user',
        timestamp: m['timestamp'] != null
            ? DateTime.tryParse(m['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      )).toList(),
      currentSessionId: sessionId,
    );
  }

  void newChat() {
    _streamSub?.cancel();
    _client?.close();
    state = AskMeState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final askMeProvider = StateNotifierProvider<AskMeNotifier, AskMeState>((ref) {
  final history = ref.read(chatHistoryProvider.notifier);
  return AskMeNotifier(history);
});
