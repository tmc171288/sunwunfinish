import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:my_word_game/pages/home_page.dart';
import 'package:my_word_game/view/painter/level_painter.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_word_game/pages/game.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});
  @override
  LevelPageState createState() => LevelPageState();
}

class LevelPageState extends State<LevelPage> {
  final _fireStore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  late Future<List<Widget>> _futurePages;
  int unlockedNum = 1;

  @override
  void initState() {
    super.initState();
    _futurePages = _initialise();
  }

  Future<void> safeUpdateLevel(int unlockedNum) async {
    final docRef = _fireStore.collection("level").doc("Ni0twAWbAduhEYnnYfsV");

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          await docRef.update({"levelNumber": unlockedNum});
        } else {
          await docRef.set({"levelNumber": unlockedNum});
        }
        break;
      } catch (e) {
        retryCount++;
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
  }

  Future<List<Widget>> _initialise() async {
    await Hive.openBox("myBox");
    var box = Hive.box("myBox");

    if (box.get("level") == null) {
      box.put("level", 1);
    }

    unlockedNum = box.get("level");
    await safeUpdateLevel(unlockedNum);

    return [
      MapPage1(unlockedNum),
      MapPage2((unlockedNum - 6).clamp(0, unlockedNum)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!mounted) return false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.brown.shade300,
        body: FutureBuilder<List<Widget>>(
          future: _futurePages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final pages = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      itemBuilder: (context, index) => pages[index],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double selectedness = 0.0;
                            if (_pageController.hasClients &&
                                _pageController.page != null) {
                              selectedness =
                                  (1.0 - (_pageController.page! - index).abs())
                                      .clamp(0.0, 1.0);
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  Colors.brown.shade200,
                                  Colors.brown.shade800,
                                  selectedness,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.brown.shade200,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// ---------------------- MAP PAGE WRAPPER ----------------------

class MapPage extends StatelessWidget {
  final String assetPath;
  final Widget child;
  const MapPage({super.key, required this.assetPath, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: NeumorphicButton(
              margin: EdgeInsets.all(12),
              style: NeumorphicStyle(
                depth: 2,
                color: Colors.transparent,
                shape: NeumorphicShape.convex,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.chevron_left_rounded, size: 27),
            ),
          ),
        ),
      ],
    );
  }
}

// =======================================================================
// ------------------------- MAP PAGE 1 ----------------------------------
// =======================================================================

class MapPage1 extends StatelessWidget {
  final int unlockedNum;

  final circlePosition = [
    Offset(0.31, 0.85),
    Offset(0.80, 0.64),
    Offset(0.25, 0.61),
    Offset(0.81, 0.44),
    Offset(0.28, 0.31),
    Offset(0.61, .19),
  ];

  final words = [
    ["zero", "two", "one"],
    ["three", "five", "four"],
    ["six", "eight", "seven"],
    ["nine", "first", "ten"],
    ["blue", "red", "green"],
    ["white", "black", "pink"],
  ];

  MapPage1(this.unlockedNum, {super.key});

  double _distance(Offset a, Offset b) => (a - b).distance;

  @override
  Widget build(BuildContext context) {
    return MapPage(
      assetPath: "assets/images/map1.jpg",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final tapPos = details.localPosition;

              for (int i = 0; i < circlePosition.length; i++) {
                final Offset e = circlePosition[i];
                final center = Offset(e.dx * size.width, e.dy * size.height);

                final isUnlocked = unlockedNum > i;
                final radius = isUnlocked ? 28.0 : 12.0;

                if (isUnlocked && _distance(tapPos, center) <= radius) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Level1(words[i], i + 1)),
                  );
                  break;
                }
              }
            },
            child: CustomPaint(
              size: size,
              painter: Map1Painter(
                context: context,
                circlePosition: circlePosition,
                words: words,
                unlockedNumbers: unlockedNum,
                begin: 0,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =======================================================================
// ------------------------- MAP PAGE 2 ----------------------------------
// =======================================================================

class MapPage2 extends StatelessWidget {
  final int unlockedNum;

  final circlePosition = [
    Offset(0.36, 0.17),
    Offset(0.19, 0.47),
    Offset(0.17, 0.78),
    Offset(0.75, 0.77),
    Offset(0.53, 0.58),
    Offset(0.83, .41),
    Offset(0.56, .27),
  ];

  final words = [
    ["fruit", "kiwi", "melon"],
    ["pear", "apple", "grape"],
    ["berry", "coco", "lime"],
    ["peach", "mango", "fig"],
    ["cake", "pizza", "pasta", "rice"],
    ["fish", "meat", "egg"],
    ["chips", "pie", "toast", "bread"],
  ];

  MapPage2(this.unlockedNum, {super.key});

  double _distance(Offset a, Offset b) => (a - b).distance;

  @override
  Widget build(BuildContext context) {
    return MapPage(
      assetPath: "assets/images/map2.jpg",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final tapPos = details.localPosition;

              for (int i = 0; i < circlePosition.length; i++) {
                final Offset e = circlePosition[i];
                final center = Offset(e.dx * size.width, e.dy * size.height);

                final isUnlocked = unlockedNum > i;
                final radius = isUnlocked ? 28.0 : 12.0;

                if (isUnlocked && _distance(tapPos, center) <= radius) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Level1(words[i], i + 1 + 6),
                    ),
                  );
                  break;
                }
              }
            },
            child: CustomPaint(
              size: size,
              painter: Map2Painter(
                context: context,
                circlePosition: circlePosition,
                words: words,
                unlockedNumbers: unlockedNum,
                begin: 6,
              ),
            ),
          );
        },
      ),
    );
  }
}
