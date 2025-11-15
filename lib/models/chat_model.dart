import 'message_model.dart';

// مدل برای نگهداری یک مکالمه کامل
class Chat {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final ChatSettings settings;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    ChatSettings? settings,
  }) : settings = settings ?? ChatSettings();

  // تبدیل به JSON برای ذخیره‌سازی
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'settings': settings.toJson(),
    };
  }

  // ساخت از JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
      settings: json['settings'] != null
          ? ChatSettings.fromJson(json['settings'])
          : ChatSettings(),
    );
  }

  // کپی با تغییرات
  Chat copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    ChatSettings? settings,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
    );
  }

  // محاسبه تعداد توکن‌های مصرف شده (تقریبی)
  int get estimatedTokens {
    int tokens = 0;
    for (var message in messages) {
      // تقریبا هر 4 کاراکتر = 1 توکن
      tokens += (message.content.length / 4).round();
    }
    return tokens;
  }

  // دریافت خلاصه چت
  String get summary {
    if (messages.isEmpty) return 'چت خالی';
    
    final firstUserMessage = messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => messages.first,
    );
    
    return firstUserMessage.content.length > 50
        ? '${firstUserMessage.content.substring(0, 50)}...'
        : firstUserMessage.content;
  }
}

// تنظیمات هر چت
class ChatSettings {
  final String model;
  final double temperature;
  final int maxTokens;
  final double topP;
  final bool streamResponse;
  final String? systemPrompt;

  ChatSettings({
    this.model = 'deepseek-chat',
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.topP = 0.95,
    this.streamResponse = true,
    this.systemPrompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'streamResponse': streamResponse,
      'systemPrompt': systemPrompt,
    };
  }

  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      model: json['model'] ?? 'deepseek-chat',
      temperature: json['temperature']?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] ?? 2048,
      topP: json['topP']?.toDouble() ?? 0.95,
      streamResponse: json['streamResponse'] ?? true,
      systemPrompt: json['systemPrompt'],
    );
  }

  ChatSettings copyWith({
    String? model,
    double? temperature,
    int? maxTokens,
    double? topP,
    bool? streamResponse,
    String? systemPrompt,
  }) {
    return ChatSettings(
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      streamResponse: streamResponse ?? this.streamResponse,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}

// مدیریت لیست چت‌ها
class ChatList {
  final List<Chat> chats;
  final String? activeCharId;

  ChatList({
    required this.chats,
    this.activeCharId,
  });

  // اضافه کردن چت جدید
  ChatList addChat(Chat chat) {
    return ChatList(
      chats: [chat, ...chats],
      activeCharId: chat.id,
    );
  }

  // حذف چت
  ChatList removeChat(String chatId) {
    return ChatList(
      chats: chats.where((c) => c.id != chatId).toList(),
      activeCharId: activeCharId == chatId ? null : activeCharId,
    );
  }

  // به‌روزرسانی چت
  ChatList updateChat(Chat updatedChat) {
    return ChatList(
      chats: chats.map((c) {
        return c.id == updatedChat.id ? updatedChat : c;
      }).toList(),
      activeCharId: activeCharId,
    );
  }

  // دریافت چت فعال
  Chat? get activeChat {
    if (activeCharId == null) return null;
    return chats.firstWhere(
      (c) => c.id == activeCharId,
      orElse: () => chats.first,
    );
  }

  // جستجو در چت‌ها
  List<Chat> search(String query) {
    if (query.isEmpty) return chats;
    
    final lowercaseQuery = query.toLowerCase();
    return chats.where((chat) {
      // جستجو در عنوان
      if (chat.title.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // جستجو در پیام‌ها
      for (var message in chat.messages) {
        if (message.content.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  // مرتب‌سازی چت‌ها
  ChatList sortBy(ChatSortType sortType) {
    List<Chat> sortedChats = List.from(chats);
    
    switch (sortType) {
      case ChatSortType.dateCreated:
        sortedChats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ChatSortType.dateUpdated:
        sortedChats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ChatSortType.title:
        sortedChats.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ChatSortType.messageCount:
        sortedChats.sort((a, b) => b.messages.length.compareTo(a.messages.length));
        break;
    }
    
    return ChatList(
      chats: sortedChats,
      activeCharId: activeCharId,
    );
  }
}

// انواع مرتب‌سازی
enum ChatSortType {
  dateCreated,
  dateUpdated,
  title,
  messageCount,
}

// آمار چت‌ها
class ChatStatistics {
  final int totalChats;
  final int totalMessages;
  final int totalTokens;
  final DateTime? firstChatDate;
  final DateTime? lastChatDate;
  final Map<String, int> messagesPerDay;

  ChatStatistics({
    required this.totalChats,
    required this.totalMessages,
    required this.totalTokens,
    this.firstChatDate,
    this.lastChatDate,
    required this.messagesPerDay,
  });

  factory ChatStatistics.fromChatList(List<Chat> chats) {
    if (chats.isEmpty) {
      return ChatStatistics(
        totalChats: 0,
        totalMessages: 0,
        totalTokens: 0,
        messagesPerDay: {},
      );
    }

    int totalMessages = 0;
    int totalTokens = 0;
    Map<String, int> messagesPerDay = {};

    for (var chat in chats) {
      totalMessages += chat.messages.length;
      totalTokens += chat.estimatedTokens;
      
      // شمارش پیام‌ها بر اساس روز
      for (var message in chat.messages) {
        final dateKey = '${message.timestamp.year}-${message.timestamp.month}-${message.timestamp.day}';
        messagesPerDay[dateKey] = (messagesPerDay[dateKey] ?? 0) + 1;
      }
    }

    // پیدا کردن اولین و آخرین تاریخ
    chats.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return ChatStatistics(
      totalChats: chats.length,
      totalMessages: totalMessages,
      totalTokens: totalTokens,
      firstChatDate: chats.first.createdAt,
      lastChatDate: chats.last.createdAt,
      messagesPerDay: messagesPerDay,
    );
  }
}