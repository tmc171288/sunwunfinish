import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:my_word_game/pages/instructions_page.dart';
import 'package:my_word_game/pages/level_page.dart';
import 'package:my_word_game/pages/login_screen.dart'; // ← Import này
import 'package:my_word_game/services/location_service.dart'; // ← QUAN TRỌNG: Phải có dòng này!
import 'package:my_word_game/utils/regular/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool press = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _quitTheApp(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/home_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _playButton(context),
                const SizedBox(height: 50),
                _helpButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => press = true),
      onTapUp: (_) async {
        setState(() => press = false);

        // Hiện loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );

        // Kiểm tra IP Việt Nam
        bool isVietnam = await LocationService.isUserInVietnam();

        // Đóng loading dialog
        if (context.mounted) Navigator.pop(context);

        // Điều hướng
        if (context.mounted) {
          if (isVietnam) {
            // 🇻🇳 IP Việt Nam → LoginPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            // 🌍 IP nước ngoài → LevelPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LevelPage()),
            );
          }
        }
      },
      onTapCancel: () => setState(() => press = false),
      child: AnimatedScale(
        scale: press ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          height: 150,
          width: 150,
          child: Image.asset("assets/images/play_icon.png"),
        ),
      ),
    );
  }

  Button _helpButton(BuildContext context) => Button(
    mText: "INSTRUCTIONS",
    mfontSize: 16,
    monPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InstructionsScaffold()),
      );
    },
  );

  void _quitTheApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            depth: 8,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          child: SizedBox(
            height: 100,
            width: 200,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FancyScoreText("Do you really want to quit?"),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.redAccent,
                          ),
                        ),
                        onPressed: () => SystemNavigator.pop(),
                        child: FancyScoreText("Yes", color: Colors.red),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.blueAccent,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: FancyScoreText("No", color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
