import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:campcon/screens/play_setup.dart';
import 'package:campcon/widgets/play_option_tile.dart';

class PlayScreen extends StatefulWidget {
  final String mainTitle;
  final String mainSection;

  const PlayScreen(
      {super.key, required this.mainTitle, required this.mainSection});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    // Color primary = Colors.blue.shade300;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                child: const MainScreen(),
                type: PageTransitionType.topToBottom,
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            size: screenHeight / 30,
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.mainTitle,
                style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: screenWidth / 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
          top: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayOptionTile(
              allicon1: RpgAwesome.perspective_dice_one,
              allicon2: null,
              allsub1: 'Single',
              allsub2: 'Digit',
              allonTapCallback: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: PlaySetUpScreen(
                      mainTitle: widget.mainTitle,
                      mainSection: widget.mainSection,
                      playType: 'Single Digit',
                      playId: 0,
                    ),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.mainSection == 'Mumbai'
                    ? PlayOptionTile(
                        allicon1: FontAwesome5.dice,
                        allicon2: null,
                        allsub1: 'Jodi',
                        allsub2: 'Digit',
                        allonTapCallback: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: PlaySetUpScreen(
                                mainTitle: widget.mainTitle,
                                mainSection: widget.mainSection,
                                playType: 'Jodi Digit',
                                playId: 1,
                              ),
                              type: PageTransitionType.leftToRight,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
                PlayOptionTile(
                  allicon1: RpgAwesome.spades_card,
                  allicon2: RpgAwesome.perspective_dice_one,
                  allsub1: 'Single',
                  allsub2: 'Pana',
                  allonTapCallback: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: PlaySetUpScreen(
                          mainTitle: widget.mainTitle,
                          mainSection: widget.mainSection,
                          playType: 'Single Pana',
                          playId: 2,
                        ),
                        type: PageTransitionType.leftToRight,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayOptionTile(
                  allicon1: RpgAwesome.spades_card,
                  allicon2: FontAwesome5.dice,
                  allsub1: 'Double',
                  allsub2: 'Pana',
                  allonTapCallback: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: PlaySetUpScreen(
                          mainTitle: widget.mainTitle,
                          mainSection: widget.mainSection,
                          playType: 'Double Pana',
                          playId: 3,
                        ),
                        type: PageTransitionType.leftToRight,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
                PlayOptionTile(
                  allicon1: RpgAwesome.perspective_dice_one,
                  allicon2: FontAwesome5.dice,
                  allsub1: 'Triple',
                  allsub2: 'Pana',
                  allonTapCallback: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: PlaySetUpScreen(
                          mainTitle: widget.mainTitle,
                          mainSection: widget.mainSection,
                          playType: 'Triple Pana',
                          playId: 4,
                        ),
                        type: PageTransitionType.leftToRight,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                )
              ],
            ),
            widget.mainSection == 'Mumbai'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayOptionTile(
                        allicon1: RpgAwesome.diamonds_card,
                        allicon2: FontAwesome5.dice_four,
                        allsub1: 'Half',
                        allsub2: 'Sangam',
                        allonTapCallback: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: PlaySetUpScreen(
                                mainTitle: widget.mainTitle,
                                mainSection: widget.mainSection,
                                playType: 'Half Sangam',
                                playId: 5,
                              ),
                              type: PageTransitionType.leftToRight,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      ),
                      PlayOptionTile(
                        allicon1: RpgAwesome.diamonds_card,
                        allicon2: RpgAwesome.diamonds_card,
                        allsub1: 'Full',
                        allsub2: 'Sangam',
                        allonTapCallback: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: PlaySetUpScreen(
                                mainTitle: widget.mainTitle,
                                mainSection: widget.mainSection,
                                playType: 'Full Sangam',
                                playId: 6,
                              ),
                              type: PageTransitionType.leftToRight,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      )
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
