import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_session.dart';

class ChatHistoryNotifier extends StateNotifier<List<ChatSession>> {
  ChatHistoryNotifier() : super([]) {
    _load();
  }

  static const String _key = 'chat_sessions';
  final _uuid = const Uuid();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      state = list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((s) => s.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  String createSession(String firstMessage) {
    final now = DateTime.now();
    final title = firstMessage.length > 40
        ? '${firstMessage.substring(0, 40)}...'
        : firstMessage;
    final session = ChatSession(
      id: _uuid.v4(),
      title: title,
      createdAt: now,
      updatedAt: now,
      messages: [
        {'role': 'user', 'content': firstMessage, 'timestamp': now.toIso8601String()},
      ],
    );
    state = [session, ...state];
    _save();
    return session.id;
  }

  void addMessage(String sessionId, String role, String content) {
    final index = state.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    final session = state[index];
    final messages = [
      ...session.messages,
      {'role': role, 'content': content, 'timestamp': DateTime.now().toIso8601String()},
    ];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          ChatSession(
            id: session.id,
            title: session.title,
            createdAt: session.createdAt,
            updatedAt: DateTime.now(),
            messages: messages,
          )
        else
          state[i],
    ];
    _save();
  }

  void deleteSession(String sessionId) {
    state = state.where((s) => s.id != sessionId).toList();
    _save();
  }

  void updateSessionTitle(String sessionId, String title) {
    final index = state.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    final session = state[index];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          ChatSession(
            id: session.id,
            title: title,
            createdAt: session.createdAt,
            updatedAt: session.updatedAt,
            messages: session.messages,
          )
        else
          state[i],
    ];
    _save();
  }
}

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<ChatSession>>((ref) {
  return ChatHistoryNotifier();
});
