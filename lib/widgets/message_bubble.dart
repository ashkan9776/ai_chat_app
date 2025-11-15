import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Color(0xFF0099CC) : Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: isUser ? Radius.circular(16) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.content.contains('```'))
                        _buildCodeBlock(message.content)
                      else
                        SelectableText(
                          message.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          textDirection: _detectTextDirection(message.content),
                        ),
                      if (message.isError)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'خطا در دریافت پاسخ',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    if (!isUser) ...[
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyToClipboard(context, message.content),
                        child: Icon(
                          Icons.copy,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0099CC)])
            : LinearGradient(colors: [Color(0xFF5E5E5E), Color(0xFF3D3D3D)]),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildCodeBlock(String content) {
    final regex = RegExp(r'```(\w+)?\n(.*?)```', dotAll: true);
    final matches = regex.allMatches(content);
    
    if (matches.isEmpty) {
      return SelectableText(
        content,
        style: TextStyle(color: Colors.white, fontSize: 15),
      );
    }

    List<Widget> widgets = [];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before code block
      if (match.start > lastEnd) {
        widgets.add(
          SelectableText(
            content.substring(lastEnd, match.start),
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        );
      }
      
      final language = match.group(1) ?? 'dart';
      final code = match.group(2) ?? '';
      
      widgets.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFF3D3D3D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => _copyToClipboard(null, code),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: HighlightView(
                  code,
                  language: language,
                  theme: monokaiSublimeTheme,
                  padding: EdgeInsets.all(12),
                  textStyle: TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      lastEnd = match.end;
    }
    
    // Add remaining text after last code block
    if (lastEnd < content.length) {
      widgets.add(
        SelectableText(
          content.substring(lastEnd),
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  TextDirection _detectTextDirection(String text) {
    final persian = RegExp(r'[\u0600-\u06FF]');
    return persian.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(BuildContext? context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('کپی شد!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}