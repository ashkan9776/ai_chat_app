import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

class CodeViewer extends StatefulWidget {
  final String code;
  final String language;
  final String? title;
  final bool showLineNumbers;
  final bool enableCopy;
  final String theme;

  const CodeViewer({
    Key? key,
    required this.code,
    this.language = 'dart',
    this.title,
    this.showLineNumbers = true,
    this.enableCopy = true,
    this.theme = 'monokai',
  }) : super(key: key);

  @override
  _CodeViewerState createState() => _CodeViewerState();
}

class _CodeViewerState extends State<CodeViewer> {
  bool _isExpanded = true;
  bool _copied = false;
  late Map<String, TextStyle> _currentTheme;
  
  @override
  void initState() {
    super.initState();
    _setTheme();
  }
  
  void _setTheme() {
    switch (widget.theme) {
      case 'atom':
        _currentTheme = atomOneDarkTheme;
        break;
      case 'github':
        _currentTheme = githubTheme;
        break;
      case 'monokai':
      default:
        _currentTheme = monokaiSublimeTheme;
        break;
    }
  }
  
  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _copied = true;
    });
    
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('کد کپی شد!'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF2D2D2D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  String _getLanguageDisplay(String lang) {
    final Map<String, String> languageNames = {
      'dart': 'Dart',
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'python': 'Python',
      'java': 'Java',
      'kotlin': 'Kotlin',
      'swift': 'Swift',
      'go': 'Go',
      'rust': 'Rust',
      'cpp': 'C++',
      'c': 'C',
      'csharp': 'C#',
      'php': 'PHP',
      'ruby': 'Ruby',
      'sql': 'SQL',
      'html': 'HTML',
      'css': 'CSS',
      'scss': 'SCSS',
      'json': 'JSON',
      'xml': 'XML',
      'yaml': 'YAML',
      'markdown': 'Markdown',
      'bash': 'Bash',
      'shell': 'Shell',
    };
    
    return languageNames[lang.toLowerCase()] ?? lang.toUpperCase();
  }
  
  Widget _buildLineNumbers(String code) {
    final lines = code.split('\n');
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          lines.length,
          (index) => Text(
            '${index + 1}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'Courier New',
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF3D3D3D),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D2D2D), Color(0xFF262626)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Language badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF00D4FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Color(0xFF00D4FF).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _getLanguageDisplay(widget.language),
                    style: TextStyle(
                      color: Color(0xFF00D4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (widget.title != null) ...[
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                Spacer(),
                // Action buttons
                Row(
                  children: [
                    if (widget.enableCopy)
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            _copied ? Icons.check : Icons.copy,
                            key: ValueKey(_copied),
                            size: 16,
                            color: _copied ? Colors.green : Colors.grey[400],
                          ),
                        ),
                        onPressed: _copyCode,
                        tooltip: 'کپی کد',
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      tooltip: _isExpanded ? 'بستن' : 'باز کردن',
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Code content
          AnimatedCrossFade(
            firstChild: Container(
              constraints: BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showLineNumbers)
                      _buildLineNumbers(widget.code),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(12),
                        child: HighlightView(
                          widget.code,
                          language: widget.language,
                          theme: _currentTheme,
                          padding: EdgeInsets.zero,
                          textStyle: TextStyle(
                            fontFamily: 'Courier New',
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            secondChild: Container(
              padding: EdgeInsets.all(12),
              child: Text(
                '${widget.code.split('\n').length} خط کد',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ویجت ساده‌تر برای نمایش inline code
class InlineCode extends StatelessWidget {
  final String code;
  final Color? backgroundColor;
  final Color? textColor;
  
  const InlineCode({
    Key? key,
    required this.code,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 13,
          color: textColor ?? Color(0xFF00D4FF),
        ),
      ),
    );
  }
}