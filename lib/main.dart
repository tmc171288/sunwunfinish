import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_word_game/utils/regular/widgets.dart'; // ← Giữ lại vì cần WordSplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const WordApp());
}

class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Word Game',
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown.shade600,
          brightness: Brightness.light,
        ),
        fontFamily: "Reem Kuffi",
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.brown.shade600,
          ),
        ),
      ),
      home: const WordSplashScreen(), // ← Vào WordSplashScreen như cũ
    );
  }
}
