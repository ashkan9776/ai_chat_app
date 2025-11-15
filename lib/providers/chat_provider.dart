import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/deepseek_service.dart';

class ChatProvider extends ChangeNotifier {
  final DeepSeekService _deepSeekService;
  final List<Message> _messages = [];
  bool _isLoading = false;
  String _currentStreamText = '';

  ChatProvider({required DeepSeekService deepSeekService})
      : _deepSeekService = deepSeekService;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String get currentStreamText => _currentStreamText;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    // اضافه کردن پیام کاربر
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    
    addMessage(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // دریافت پاسخ از DeepSeek
      final response = await _deepSeekService.sendMessage(_messages);
      
      final assistantMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
      
      addMessage(assistantMessage);
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'خطا: $e',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );
      
      addMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamMessage(String content) {
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    
    addMessage(userMessage);
    _isLoading = true;
    _currentStreamText = '';
    notifyListeners();

    _deepSeekService.streamMessage(_messages).listen(
      (chunk) {
        _currentStreamText += chunk;
        notifyListeners();
      },
      onDone: () {
        final assistantMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: _currentStreamText,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );
        
        addMessage(assistantMessage);
        _currentStreamText = '';
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        final errorMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'خطا در استریم: $error',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          isError: true,
        );
        
        addMessage(errorMessage);
        _currentStreamText = '';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}