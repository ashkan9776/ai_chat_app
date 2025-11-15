import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/chat_provider.dart';
import 'services/deepseek_service.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            deepSeekService: DeepSeekService(
              apiKey: dotenv.env['DEEPSEEK_API_KEY'] ?? '',
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'DeepSeek AI Chat',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/settings': (context) => SettingsScreen()},
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          fontFamily: 'Vazir',
        ),
        home: ChatScreen(),
      ),
    );
  }
}
