import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _systemPromptController;
  
  double _temperature = 0.7;
  int _maxTokens = 2048;
  double _topP = 0.95;
  bool _streamResponse = true;
  String _selectedModel = 'deepseek-chat';
  String _selectedTheme = 'dark';
  bool _saveHistory = true;
  bool _showLineNumbers = true;
  
  final List<String> _availableModels = [
    'deepseek-chat',
    'deepseek-coder',
  ];
  
  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _systemPromptController = TextEditingController();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _systemPromptController.text = prefs.getString('system_prompt') ?? '';
      _temperature = prefs.getDouble('temperature') ?? 0.7;
      _maxTokens = prefs.getInt('max_tokens') ?? 2048;
      _topP = prefs.getDouble('top_p') ?? 0.95;
      _streamResponse = prefs.getBool('stream_response') ?? true;
      _selectedModel = prefs.getString('model') ?? 'deepseek-chat';
      _selectedTheme = prefs.getString('theme') ?? 'dark';
      _saveHistory = prefs.getBool('save_history') ?? true;
      _showLineNumbers = prefs.getBool('show_line_numbers') ?? true;
    });
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', _apiKeyController.text);
    await prefs.setString('system_prompt', _systemPromptController.text);
    await prefs.setDouble('temperature', _temperature);
    await prefs.setInt('max_tokens', _maxTokens);
    await prefs.setDouble('top_p', _topP);
    await prefs.setBool('stream_response', _streamResponse);
    await prefs.setString('model', _selectedModel);
    await prefs.setString('theme', _selectedTheme);
    await prefs.setBool('save_history', _saveHistory);
    await prefs.setBool('show_line_numbers', _showLineNumbers);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('تنظیمات ذخیره شد'),
          ],
        ),
        backgroundColor: Color(0xFF2D2D2D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2D2D2D),
        title: Text(
          'پاک کردن تاریخچه',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید تمام تاریخچه چت‌ها را پاک کنید؟',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('پاک کردن'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
      Provider.of<ChatProvider>(context, listen: false).clearChat();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تاریخچه پاک شد'),
          backgroundColor: Color(0xFF2D2D2D),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),
        title: Text('تنظیمات'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // بخش API
          _buildSectionHeader('تنظیمات API', Icons.key),
          _buildCard([
            _buildTextField(
              controller: _apiKeyController,
              label: 'کلید API',
              hint: 'کلید API دیپ سیک خود را وارد کنید',
              obscureText: true,
              icon: Icons.vpn_key,
            ),
            SizedBox(height: 16),
            _buildDropdown(
              label: 'مدل',
              value: _selectedModel,
              items: _availableModels,
              onChanged: (value) {
                setState(() {
                  _selectedModel = value!;
                });
              },
              icon: Icons.model_training,
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش پارامترها
          _buildSectionHeader('پارامترهای مدل', Icons.tune),
          _buildCard([
            _buildSlider(
              label: 'Temperature',
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _temperature = value;
                });
              },
              helperText: 'میزان خلاقیت پاسخ‌ها (0 = دقیق، 2 = خلاقانه)',
            ),
            SizedBox(height: 16),
            _buildSlider(
              label: 'حداکثر توکن',
              value: _maxTokens.toDouble(),
              min: 100,
              max: 4096,
              divisions: 40,
              onChanged: (value) {
                setState(() {
                  _maxTokens = value.toInt();
                });
              },
              helperText: 'حداکثر طول پاسخ',
            ),
            SizedBox(height: 16),
            _buildSlider(
              label: 'Top P',
              value: _topP,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _topP = value;
                });
              },
              helperText: 'احتمال انتخاب کلمات (nucleus sampling)',
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش System Prompt
          _buildSectionHeader('پیام سیستم', Icons.chat),
          _buildCard([
            TextField(
              controller: _systemPromptController,
              decoration: InputDecoration(
                labelText: 'System Prompt (اختیاری)',
                hintText: 'دستورالعمل‌های اولیه برای AI',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF3D3D3D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF00D4FF)),
                ),
                filled: true,
                fillColor: Color(0xFF2D2D2D),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 4,
              textDirection: TextDirection.rtl,
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش ظاهر
          _buildSectionHeader('ظاهر', Icons.palette),
          _buildCard([
            _buildDropdown(
              label: 'تم',
              value: _selectedTheme,
              items: ['dark', 'light', 'auto'],
              itemLabels: {'dark': 'تیره', 'light': 'روشن', 'auto': 'خودکار'},
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
              icon: Icons.brightness_6,
            ),
            SizedBox(height: 16),
            _buildSwitch(
              label: 'نمایش شماره خطوط در کد',
              value: _showLineNumbers,
              onChanged: (value) {
                setState(() {
                  _showLineNumbers = value;
                });
              },
              icon: Icons.format_list_numbered,
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش رفتار
          _buildSectionHeader('رفتار', Icons.settings_applications),
          _buildCard([
            _buildSwitch(
              label: 'پاسخ استریم (Real-time)',
              value: _streamResponse,
              onChanged: (value) {
                setState(() {
                  _streamResponse = value;
                });
              },
              icon: Icons.stream,
              subtitle: 'نمایش پاسخ به صورت کلمه به کلمه',
            ),
            SizedBox(height: 16),
            _buildSwitch(
              label: 'ذخیره تاریخچه',
              value: _saveHistory,
              onChanged: (value) {
                setState(() {
                  _saveHistory = value;
                });
              },
              icon: Icons.history,
              subtitle: 'ذخیره خودکار مکالمات',
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش داده‌ها
          _buildSectionHeader('مدیریت داده‌ها', Icons.storage),
          _buildCard([
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'پاک کردن تاریخچه',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'حذف تمام مکالمات ذخیره شده',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                onPressed: _clearHistory,
              ),
            ),
            Divider(color: Color(0xFF3D3D3D)),
            ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF00D4FF)),
              title: Text(
                'آمار استفاده',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      'در حال بارگذاری...',
                      style: TextStyle(color: Colors.grey[400]),
                    );
                  }
                  
                  final prefs = snapshot.data!;
                  final messageCount = prefs.getInt('total_messages') ?? 0;
                  final tokenCount = prefs.getInt('total_tokens') ?? 0;
                  
                  return Text(
                    '$messageCount پیام | ~$tokenCount توکن',
                    style: TextStyle(color: Colors.grey[400]),
                  );
                },
              ),
            ),
          ]),
          
          SizedBox(height: 24),
          
          // بخش درباره
          _buildSectionHeader('درباره', Icons.info),
          _buildCard([
            ListTile(
              leading: Icon(Icons.code, color: Color(0xFF00D4FF)),
              title: Text(
                'نسخه اپلیکیشن',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '1.0.0',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            Divider(color: Color(0xFF3D3D3D)),
            ListTile(
              leading: Icon(Icons.developer_mode, color: Color(0xFF00D4FF)),
              title: Text(
                'توسعه‌دهنده',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'ساخته شده توسط اشکان',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ]),
          
          SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00D4FF), size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF3D3D3D)),
      ),
      child: Column(children: children),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.grey[400])
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF3D3D3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF00D4FF)),
        ),
        filled: true,
        fillColor: Color(0xFF1E1E1E),
      ),
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    Map<String, String>? itemLabels,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.grey[400]),
          SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF3D3D3D)),
                ),
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  dropdownColor: Color(0xFF2D2D2D),
                  underline: Container(),
                  style: TextStyle(color: Colors.white),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(itemLabels?[item] ?? item),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value < 10
                    ? value.toStringAsFixed(2)
                    : value.toStringAsFixed(0),
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Color(0xFF00D4FF),
          inactiveColor: Color(0xFF3D3D3D),
          onChanged: onChanged,
        ),
        if (helperText != null)
          Text(
            helperText,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
      ],
    );
  }
  
  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null
          ? Icon(icon, color: Colors.grey[400])
          : null,
      title: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF00D4FF),
        activeTrackColor: Color(0xFF00D4FF).withOpacity(0.5),
        inactiveTrackColor: Color(0xFF3D3D3D),
      ),
    );
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }
}