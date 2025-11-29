import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:my_word_game/pages/level_page.dart';
import 'package:my_word_game/utils/game/widgets/decounter.dart';
import 'package:my_word_game/utils/game/widgets/word_panel.dart';
import 'package:my_word_game/utils/regular/widgets.dart';

class GameLayout extends StatelessWidget {
  final Widget wordGrid;
  final int score;
  final bool stop;
  final List<String> wordsFound;
  final List<String> wordsNotFound;
  // ignore: prefer_typing_uninitialized_variables, strict_top_level_inference
  final win;

  final int chosenLevel;

  const GameLayout({
    super.key,
    required this.wordGrid,
    this.score = 0,
    this.stop = false,
    this.wordsFound = const [],
    this.win,
    required this.wordsNotFound,
    required this.chosenLevel,
  });

  @override
  Widget build(BuildContext context) {
    // wordsFound.removeAt(wordsFound.indexOf(""));
    // wordsFound.removeAt(wordsFound.indexOf(""));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SafeArea(
          child: Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: WordBackground(
                    child: Column(
                      children: [
                        GoldenText(
                          "Score",
                          mfontWeight: FontWeight.w100,
                          mfontSize: 24,
                        ),
                        FancyScoreText("$score"),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 2,
                  child: DecounterWidget(
                    win: win,
                    onEnd: () async {
                      if (win) {
                        await Hive.openBox("myBox");
                        var box = Hive.box("myBox");

                        int levelUp = box.get("level") + 1;

                        if (chosenLevel == levelUp - 1) {
                          box.put("level", levelUp);
                        }
                      }
                      showDialog(
                        useSafeArea: true,
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          // ignore: deprecated_member_use
                          return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Center(
                                child: Neumorphic(
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.convex,
                                    depth: 8,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 300,
                                    width: 300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: win
                                              ? GoldenText(
                                                  "Well Played !",
                                                  mfontSize: 22,
                                                )
                                              : GoldenText(
                                                  "Time is Over",
                                                  mfontSize: 22,
                                                ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16.0,
                                            ),
                                            child: Text(
                                              "Words Found :",
                                              style: kTextStylePanelHeader,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: win ? 100 : 60,
                                          child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: wordsFound.length,
                                            itemBuilder: (_, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16.0,
                                                ),
                                                child: NeumorphicText(
                                                  wordsFound[index],
                                                  style: NeumorphicStyle(
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                        fontSize: 17,
                                                        fontFamily:
                                                            "Reem Kuffi",
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        !win
                                            ? Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 16.0,
                                                      ),
                                                  child: Text(
                                                    "Words not Found :",
                                                    style:
                                                        kTextStylePanelHeader,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        !win
                                            ? SizedBox(
                                                height: 60,
                                                child: ListView.builder(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      wordsNotFound.length,
                                                  itemBuilder: (_, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 16.0,
                                                          ),
                                                      child: NeumorphicText(
                                                        wordsNotFound[index],
                                                        style: NeumorphicStyle(
                                                          color: Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  "Reem Kuffi",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(),
                                        Expanded(
                                          flex: 2,
                                          child: Button(
                                            mText: "EXIT",
                                            mfontSize: 22,
                                            monPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LevelPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    pause: stop,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox.expand(child: wordGrid),
          ),
        ),
      ],
    );
  }
}

class GameBackground extends StatelessWidget {
  final String assetPath;

  final Widget child;

  const GameBackground({
    super.key,
    required this.assetPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.fill),
      ),
      child: child,
    );
  }
}

///* To pause the game
/* IconButton(
                      icon: Icon(
                        Icons.pause_rounded,
                        color: Colors.amber.shade600,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Button(
                                      mText: "Resume",
                                      monPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Button(
                                      mText: "Exit",
                                      monPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LevelPage()));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }); 
                      }),*/
