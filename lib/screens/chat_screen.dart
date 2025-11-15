import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.streamMessage(_messageController.text.trim());
    _messageController.clear();
    
    // اسکرول به پایین - با بررسی اینکه ScrollController متصل باشه
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // صبر می‌کنیم تا ListView آپدیت بشه و بعد اسکرول می‌کنیم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // بررسی می‌کنیم که ScrollController به ListView متصل باشه
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_awesome, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DeepSeek AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'آماده پاسخگویی',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Color(0xFF2D2D2D),
                  title: Text(
                    'پاک کردن چت',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'آیا مطمئن هستید؟',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('خیر'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false).clearChat();
                        Navigator.pop(context);
                      },
                      child: Text('بله', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // اگر چت خالی بود
                if (chatProvider.messages.isEmpty && !chatProvider.isLoading) {
                  return _buildEmptyState();
                }
                
                // لیست پیام‌ها
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatProvider.messages.length + 
                           (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // نمایش Typing Indicator یا پیام در حال استریم
                    if (index == chatProvider.messages.length && 
                        chatProvider.isLoading) {
                      if (chatProvider.currentStreamText.isNotEmpty) {
                        // نمایش پیام در حال استریم
                        return MessageBubble(
                          message: Message(
                            id: 'stream',
                            content: chatProvider.currentStreamText,
                            role: MessageRole.assistant,
                            timestamp: DateTime.now(),
                          ),
                        );
                      }
                      // نمایش Typing Indicator
                      return TypingIndicator();
                    }
                    
                    // نمایش پیام عادی
                    return MessageBubble(
                      message: chatProvider.messages[index],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون بزرگ
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00D4FF).withOpacity(0.2),
                    Color(0xFF0099CC).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Color(0xFF00D4FF),
              ),
            ),
            SizedBox(height: 24),
            
            // پیام خوشامدگویی
            Text(
              'سلام اشکان! 👋',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'چطور می‌تونم کمکت کنم؟',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 32),
            
            // پیشنهادات
            _buildSuggestionChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'کمک در کدنویسی Flutter',
      'ایده برای اپلیکیشن جدید',
      'بهینه‌سازی کد React Native',
      'آموزش Kotlin',
      'حل مشکل برنامه‌نویسی',
      'طراحی UI/UX',
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return InkWell(
          onTap: () {
            _messageController.text = suggestion;
            _sendMessage();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3D3D3D),
                  Color(0xFF2D2D2D),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF00D4FF).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForSuggestion(suggestion),
                  size: 16,
                  color: Color(0xFF00D4FF),
                ),
                SizedBox(width: 8),
                Text(
                  suggestion,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForSuggestion(String suggestion) {
    if (suggestion.contains('Flutter')) return Icons.flutter_dash;
    if (suggestion.contains('اپلیکیشن')) return Icons.app_shortcut;
    if (suggestion.contains('React')) return Icons.code;
    if (suggestion.contains('Kotlin')) return Icons.android;
    if (suggestion.contains('مشکل')) return Icons.bug_report;
    if (suggestion.contains('UI')) return Icons.design_services;
    return Icons.auto_awesome;
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            // فیلد ورودی
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        style: TextStyle(color: Colors.white),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'پیام خود را بنویسید...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    // دکمه پیوست
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[400]),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('این قابلیت به زودی اضافه می‌شود'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            
            // دکمه ارسال
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: provider.isLoading
                        ? LinearGradient(
                            colors: [Colors.grey[600]!, Colors.grey[700]!],
                          )
                        : LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      provider.isLoading ? Icons.stop : Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: provider.isLoading 
                        ? null 
                        : _sendMessage,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}