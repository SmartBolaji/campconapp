import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campcon/widgets/reward_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  TextEditingController openPanaController = TextEditingController();
  TextEditingController closePanaController = TextEditingController();
  TextEditingController digitController = TextEditingController();
  // String _mrkOpenTime = 'Market Open Time';
  // String _mrkCloseTime = 'Market Close Time';

  // Late variables
  late SharedPreferences sharedPreferences;

  QuerySnapshot? _snap;
  QuerySnapshot? _snap1;
  bool circular = false;
  bool refreshCircle = false;
  // Market details
  String allGame = '';
  int allDigit = 0;
  int allOpenPana = 0;
  int allClosePana = 0;

  QuerySnapshot? _snap2;
  QuerySnapshot? _snap3;
  bool circularBid = false;
  bool refreshCircleBid = false;
  bool refreshLoad = false;
  bool resetLoad = false;
  int currentSnapSize = 0; // Variable to keep track of snapshot size

  // Market details
  int userId = 0;
  String allMrkName = '';
  String allMrkSection = '';
  String allMrkType = '';
  String allBidMrkSession = '';
  int allBidDigit = 0;
  int allBidOpenPana = 0;
  int allBidClosePana = 0;
  double allStakeAmt = 0.0;
  Timestamp fetchDate = Timestamp.now();

  // Get the current date
  DateTime now = DateTime.now();
  String currentTime = DateFormat('MMMM').format(DateTime.now());

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = Colors.blue.shade300;

  // Games
  String select0 = 'Select Game';
  List<String> gameList = [
    'Select Game',
  ];
  // Session
  String select1 = 'Select Session';
  List<String> sessList = [
    'Select Session',
    'Open',
    'Close',
  ];

  // Functions
  String formatDate(DateTime date) {
    // Format the date as "EEEE" to get the day of the week (e.g., "Monday")
    String dayOfWeek = DateFormat('EEEE').format(date);
    // Format the date as "yyyy-MM-dd" (e.g., "2024-04-27")
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Combine the day of the week and the formatted date
    return '$dayOfWeek - $formattedDate';
  }

  // Method to refresh data
  Future<void> refreshData() async {
    setState(() {
      loadGamesData();
      loadBidsData();
    });
  }

  // Method to load games data
  Future<void> loadSelectData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Games')
          .orderBy('created', descending: false)
          .get();
      if (snap.docs.isEmpty) {
        _snap1 = await FirebaseFirestore.instance
            .collection('Games')
            .orderBy('created', descending: false)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap1 = snap;
      }
      // Clear the lists before adding new values
      gameList.clear();
      gameList.add('Select Game');

      // Extract values of "Market Name" from the query
      for (final doc in _snap1!.docs) {
        gameList.add(doc['mrkname']);
      }
      setState(() {}); // Update UI after fetching data
    } catch (e) {
      e.toString();
    }
  }

  // Method to load games data
  Future<void> loadGamesData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Games')
          .orderBy('created', descending: false)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Games')
            .orderBy('created', descending: false)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }
      setState(() {}); // Update UI after fetching data
    } catch (e) {
      e.toString();
    }
  }

  // Method to refresh data
  Future<void> refreshBidData() async {
    setState(() {
      loadBidsData();
    });
  }

  // Method to load games data
  Future<void> loadBidsData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Bids')
          .where('status', isEqualTo: 'Booked')
          .orderBy('created', descending: true)
          .get();
      if (snap.docs.isEmpty) {
        _snap2 = await FirebaseFirestore.instance
            .collection('Bids')
            .where('status', isEqualTo: 'Booked')
            .orderBy('created', descending: true)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap2 = snap;
      }
      setState(() {
        if (_snap2!.size > 20) {
          currentSnapSize = 20; // Update to 20
        } else {
          currentSnapSize = _snap2!.size; // Update default
        }
      });
    } catch (e) {
      e.toString();
    }
  }

  // Method to reset games data
  Future<void> resetGamesData(int index) async {
    final doc = _snap!.docs[index];
    try {
      doc.reference.update(({
        'digit': 1000,
        'openpana': 1000,
        'closepana': 1000,
      }));

      setState(() {}); // Update UI after fetching data
    } catch (e) {
      e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSelectData();
    loadGamesData();
    loadBidsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
                'Declare Results',
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, right: 20, left: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  )),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Game',
                    style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  customField(formatDate(now), Icons.calendar_today, null, null,
                      false, true, null),
                  customSelect(context, gameList, select0, (String sel) {
                    setState(() {
                      select0 = sel;
                    });
                  }),
                  // customSelect(context, sessList, select1, (String sel) {
                  //   setState(() {
                  //     select1 = sel;
                  //   });
                  // }),
                  customField('Digit', null, null, digitController, false,
                      false, (value) {}),
                  customField('Open Pana', null, null, openPanaController,
                      false, false, (value) {}),
                  customField('Close Pana', null, null, closePanaController,
                      false, false, (value) {}),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      if (select0 == 'Select Game') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Select a valid game and try again!',
                              style: TextStyle(
                                fontFamily: 'Nexa Light',
                                fontSize: screenWidth / 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        setState(() {
                          circular = false;
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('Games')
                            .doc(select0)
                            .update({
                          'digit': digitController.text == ''
                              ? 1000
                              : int.parse(digitController.text),
                          'openpana': openPanaController.text == ''
                              ? 1000
                              : int.parse(openPanaController.text),
                          'closepana': closePanaController.text == ''
                              ? 1000
                              : int.parse(closePanaController.text),
                          'updated': DateTime.now(),
                        }).then(
                          (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.blue.shade300,
                                content: Text(
                                  'Success!',
                                  style: TextStyle(
                                    fontFamily: 'Nexa Light',
                                    fontSize: screenWidth / 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                            refreshData();
                            setState(() {
                              circular = false;
                              //     halfSangamPanaClController,
                              //     fullSangamPanaOpController,
                              //     fullSangamPanaClController,
                              // select0 = 'Select Game';
                            });
                          },
                        );
                      }
                    },
                    child: Container(
                      height: 60,
                      width: screenWidth,
                      margin: EdgeInsets.only(top: screenHeight / 40),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Center(
                        child: circular
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator(
                                    color: Colors.white))
                            : Text(
                                'SUBMIT',
                                style: TextStyle(
                                    fontFamily: 'Nexa Bold',
                                    fontSize: screenWidth / 26,
                                    color: Colors.white,
                                    letterSpacing: 2),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 50,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight / 50,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  )),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 24),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Results (${DateFormat('yyyy-MM-dd').format(now)})',
                        style: TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            refreshCircle = true;
                          });
                          refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blue.shade300,
                              content: Text(
                                'Done!',
                                style: TextStyle(
                                  fontFamily: 'Nexa Light',
                                  fontSize: screenWidth / 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              refreshCircle = false;
                            });
                          });
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade800,
                          child: refreshCircle
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white))
                              : Icon(
                                  Icons.refresh,
                                  size: screenWidth / 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            resetLoad = true;
                          });
                          List.generate(_snap!.size, (index) {
                            resetGamesData(index);
                          });
                          refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blue.shade300,
                              content: Text(
                                'Reset!',
                                style: TextStyle(
                                  fontFamily: 'Nexa Light',
                                  fontSize: screenWidth / 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              resetLoad = false;
                            });
                          });
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade800,
                          child: resetLoad
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white))
                              : Icon(
                                  Icons.restore,
                                  size: screenWidth / 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        // padding: const EdgeInsets.only(left: 2, right: 2),
                        width: 600,
                        child: // Use ListView to display games
                            _snap != null
                                ? Column(
                                    children: [
                                      ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Table(
                                            border: TableBorder.all(),
                                            columnWidths: const {
                                              0: FractionColumnWidth(0.08),
                                              1: FractionColumnWidth(0.30),
                                              2: FractionColumnWidth(0.12),
                                              // 3: FractionColumnWidth(0.15),
                                              // 4: FractionColumnWidth(0.15)
                                            },
                                            children: [
                                              buildRow([
                                                '#',
                                                'Game\nName',
                                                'Digit',
                                                'Open\nPana',
                                                'Close\nPana',
                                              ],
                                                  isHeader: true,
                                                  rowIndex: 0,
                                                  onTap: () {}),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ListView(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: List.generate(
                                          _snap!.size,
                                          (index) {
                                            final doc = _snap!.docs[index];
                                            final allDate = doc.get('updated');
                                            allGame = doc.get('mrkname');
                                            allDigit = doc.get('digit');
                                            allOpenPana = doc.get('openpana');
                                            allClosePana = doc.get('closepana');

                                            return DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            allDate.toDate()) ==
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(now)
                                                ? Table(
                                                    border: const TableBorder(
                                                      verticalInside:
                                                          BorderSide(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.black),
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.black),
                                                      left: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.black),
                                                      right: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.black),
                                                    ),
                                                    columnWidths: const {
                                                      0: FractionColumnWidth(
                                                          0.08),
                                                      1: FractionColumnWidth(
                                                          0.30),
                                                      2: FractionColumnWidth(
                                                          0.12),
                                                      // 3: FractionColumnWidth(0.15),
                                                      // 4: FractionColumnWidth(0.15)
                                                    },
                                                    children: [
                                                      buildRow([
                                                        '${index + 1}',
                                                        allGame,
                                                        allDigit.toString() ==
                                                                '1000'
                                                            ? 'null'
                                                            : allDigit
                                                                .toString(),
                                                        allOpenPana.toString() ==
                                                                '1000'
                                                            ? 'null'
                                                            : allOpenPana
                                                                .toString(),
                                                        allClosePana.toString() ==
                                                                '1000'
                                                            ? 'null'
                                                            : allClosePana
                                                                .toString(),
                                                      ],
                                                          isHeader: false,
                                                          rowIndex: 1,
                                                          onTap: () async {
                                                        // // Use viewTransact and await the Future
                                                        // await editGames(
                                                        //     context,
                                                        //     doc,
                                                        //     screenHeight,
                                                        //     screenWidth);
                                                        // After the Future completes (status change is done), reload the page
                                                        // refreshData();
                                                      }),
                                                    ],
                                                  )
                                                : const SizedBox();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 200,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.blue.shade200,
                                        radius: 50,
                                        child:
                                            const CircularProgressIndicator()),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight / 70,
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  )),
              alignment: Alignment.centerLeft,
              // margin: EdgeInsets.symmetric(horizontal: screenWidth / 24),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Wins (${DateFormat('yyyy-MM-dd').format(now)})',
                        style: TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            refreshCircle = true;
                            refreshBidData();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blue.shade300,
                              content: Text(
                                'Done!',
                                style: TextStyle(
                                  fontFamily: 'Nexa Light',
                                  fontSize: screenWidth / 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              refreshCircle = false;
                            });
                          });
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade800,
                          child: refreshCircle
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white))
                              : Icon(
                                  Icons.refresh,
                                  size: screenWidth / 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        // padding: const EdgeInsets.only(left: 2, right: 2),
                        width: 1200,
                        child: // Use ListView to display games
                            _snap2 != null
                                ? Column(
                                    children: [
                                      ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Table(
                                            border: TableBorder.all(),
                                            columnWidths: const {
                                              0: FractionColumnWidth(0.05),
                                              // 1: FractionColumnWidth(0.14),
                                              // 2: FractionColumnWidth(0.15),
                                              // 3: FractionColumnWidth(0.15),
                                              // 4: FractionColumnWidth(0.15)
                                            },
                                            children: [
                                              buildRow([
                                                '#',
                                                'Game\nName',
                                                'Section',
                                                'Bid',
                                                'Session',
                                                'Digit',
                                                'Open\nPana',
                                                'Close\nPana',
                                                'Member',
                                                'Action',
                                              ],
                                                  isHeader: true,
                                                  rowIndex: 0,
                                                  onTap: () {}),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ListView(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: List.generate(
                                          currentSnapSize,
                                          (index) {
                                            final doc = _snap2!.docs[index];
                                            userId = doc.get('id');
                                            allMrkName = doc.get('market');
                                            allMrkSection =
                                                doc.get('mrksection');
                                            allMrkType = doc.get('mrktype');
                                            allBidMrkSession =
                                                doc.get('session');
                                            allBidDigit = doc.get('digit');
                                            allBidOpenPana =
                                                doc.get('openpana');
                                            allBidClosePana =
                                                doc.get('closepana');
                                            allStakeAmt = doc.get('points');

                                            fetchDate = doc.get('created');
                                            String formatAllDate =
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(fetchDate.toDate());

                                            if (allDigit == allBidDigit ||
                                                allOpenPana == allBidOpenPana ||
                                                allClosePana ==
                                                    allBidClosePana) {
                                              return DateFormat('yyyy-MM-dd')
                                                          .format(fetchDate
                                                              .toDate()) ==
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(now)
                                                  ? Table(
                                                      border: const TableBorder(
                                                        verticalInside:
                                                            BorderSide(
                                                                width: 1.0,
                                                                color: Colors
                                                                    .black),
                                                        bottom: BorderSide(
                                                            width: 1.0,
                                                            color:
                                                                Colors.black),
                                                        left: BorderSide(
                                                            width: 1.0,
                                                            color:
                                                                Colors.black),
                                                        right: BorderSide(
                                                            width: 1.0,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      columnWidths: const {
                                                        0: FractionColumnWidth(
                                                            0.05),
                                                        // 1: FractionColumnWidth(
                                                        //     0.14),
                                                        // 2: FractionColumnWidth(
                                                        //     0.15),
                                                        // 3: FractionColumnWidth(
                                                        //     0.15),
                                                        // 4: FractionColumnWidth(
                                                        //     0.15)
                                                      },
                                                      children: [
                                                        buildRow([
                                                          '${index + 1}',
                                                          allMrkName,
                                                          allMrkSection,
                                                          allStakeAmt
                                                              .toString(),
                                                          allBidMrkSession,
                                                          allBidDigit
                                                              .toString(),
                                                          allBidOpenPana
                                                              .toString(),
                                                          allBidClosePana
                                                              .toString(),
                                                          userId.toString(),
                                                          'Reward'
                                                        ],
                                                            isHeader: false,
                                                            rowIndex: 1,
                                                            onTap: () async {
                                                          final snap =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .where('id',
                                                                      isEqualTo:
                                                                          userId)
                                                                  .get();
                                                          if (snap
                                                              .docs.isEmpty) {
                                                            _snap3 = await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Users')
                                                                .where('id',
                                                                    isEqualTo:
                                                                        userId)
                                                                .get(const GetOptions(
                                                                    source: Source
                                                                        .cache));
                                                          } else {
                                                            _snap3 = snap;
                                                          }

                                                          await rewardUser(
                                                                  context,
                                                                  _snap3!.docs
                                                                      .first,
                                                                  screenHeight,
                                                                  screenWidth)
                                                              .then((_) {
                                                            doc.reference
                                                                .update({
                                                              'status': 'Won'
                                                            });
                                                          });
                                                          // After the Future completes (status change is done), reload the page
                                                          refreshData();
                                                        }),
                                                      ],
                                                    )
                                                  : const SizedBox();
                                            } else {
                                              return const SizedBox();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 200,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.blue.shade200,
                                        radius: 50,
                                        child:
                                            const CircularProgressIndicator()),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight / 50,
            ),
          ],
        ),
      ),
    );
  }

  TableRow buildRow(List<String> cells,
      {required bool isHeader,
      required int rowIndex,
      required Function onTap}) {
    Color backgroundColor =
        rowIndex.isEven ? Colors.white : Colors.grey.shade100;

    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade300 : backgroundColor,
      ),
      children: cells.map((cell) {
        final TextStyle title = TextStyle(
          fontFamily: 'Nexa Bold',
          fontSize: screenWidth / 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
        Color color = Colors.black;
        if (cell == allGame || cell == 'Reward') {
          color = Colors.blue.shade800;
        }

        final cellStyle = TextStyle(
            fontFamily: 'Nexa Light', fontSize: screenWidth / 26, color: color);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              onTap();
            },
            child: Text(
              cell,
              style: isHeader ? title : cellStyle,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: screenWidth / 26, fontFamily: 'Nexa Bold'),
      ),
    );
  }

  Widget fgtPass(String title, {required Function onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Text(
          title,
          style: TextStyle(
              fontSize: screenWidth / 30,
              fontFamily: 'Nexa Bold',
              color: Colors.blue.shade300),
        ),
      ),
    );
  }

  Widget customField(
      String hint,
      IconData? icon,
      IconData? suffixicon,
      TextEditingController? controller,
      bool obscure,
      bool readOnly,
      Function(String)? onChanged) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ]),
      child: Row(
        children: [
          readOnly
              ? SizedBox(
                  width: screenWidth / 6,
                  child: Icon(
                    icon,
                    color: primary,
                    size: screenWidth / 15,
                  ),
                )
              : SizedBox(
                  width: screenWidth / 10,
                ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 30),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Nexa Light',
                    fontSize: screenWidth / 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                readOnly: readOnly,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.number,
                // maxLength: 2,
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: readOnly ? screenHeight / 35 : screenHeight / 50,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: readOnly
                      ? TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)
                      : null,
                  // suffixIcon: GestureDetector(
                  //   onTap: () {
                  //     onTap();
                  //   },
                  //   child: Icon(
                  //     suffixicon,
                  //     color: Colors.grey.shade600,
                  //     size: screenWidth / 15,
                  //   ),
                  // ),
                ),
                maxLines: 1,
                obscureText: obscure,
                onChanged: (newChange) {
                  onChanged!(newChange);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget customTime(
    String mrkTime,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: screenWidth,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              )
            ]),
        child: Row(
          children: [
            SizedBox(
              width: screenWidth / 10,
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: screenWidth / 30),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
                    child: Text(
                      mrkTime,
                      style: TextStyle(
                          fontFamily: 'Nexa Light',
                          fontSize: screenWidth / 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget customSelect(BuildContext context, List<String>? items,
      String valueAll, Function(String) onChanged) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ]),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth / 10,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 30),
              child: DropdownButton<String>(
                dropdownColor: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
                hint: Text(
                  valueAll,
                  style: TextStyle(
                      fontFamily: 'Nexa Light',
                      fontSize: screenWidth / 21,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                value: valueAll,
                isExpanded: true,
                underline: Container(),
                onChanged: (newCat) {
                  onChanged(newCat!);
                },
                items: items!.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(
                            fontFamily: 'Nexa Light',
                            fontSize: screenWidth / 21,
                            // fontWeight: FontWeight.bold,
                            color: value != valueAll
                                ? Colors.black
                                : Colors.blue.shade800)),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
