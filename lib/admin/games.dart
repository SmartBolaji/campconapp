import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/widgets/edit_games.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  TextEditingController mrkNameController = TextEditingController();
  String _mrkOpenTime = 'Market Open Time';
  String _mrkCloseTime = 'Market Close Time';

  // Late variables
  late SharedPreferences sharedPreferences;

  QuerySnapshot? _snap;
  bool circular = false;
  bool refreshCircle = false;
  // Market details
  String allMrkName = '';
  String allMrkSection = '';
  String allMrkOpen = '';
  String allMrkClose = '';
  String allMrkStatus = '';

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = Colors.blue.shade300;

  // Session
  String select0 = 'Choose Game';

  List<String> gameList = [
    'Choose Game',
    'Starline',
    'Mumbai',
  ];

  // Function

  // Method to refresh data
  Future<void> refreshData() async {
    setState(() {
      loadGamesData();
    });
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
      Transform.scale(
          scale: 0.5,
          child: const CircularProgressIndicator(color: Colors.white));
    }
  }

  @override
  void initState() {
    super.initState();
    loadGamesData();
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
                'Games',
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
                    'New Game',
                    style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  customField('Market Name', null, null, mrkNameController,
                      false, false, (value) {}),
                  customSelect(context, gameList, select0, (String sel) {
                    setState(() {
                      select0 = sel;
                    });
                  }),
                  customTime(
                    _mrkOpenTime,
                    () async {
                      final TimeOfDay? mrkOpenTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: primary,
                                    secondary: primary,
                                    onSecondary: Colors.white),
                              ),
                              child: child!);
                        },
                      );
                      if (mrkOpenTime != null) {
                        setState(() {
                          _mrkOpenTime = mrkOpenTime.format(context);
                        });
                      }
                    },
                  ),
                  customTime(
                    _mrkCloseTime,
                    () async {
                      final TimeOfDay? mrkCloseTime = await showTimePicker(
                        // barrierColor: Colors.blue.shade300,
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: primary,
                                    secondary: primary,
                                    onSecondary: Colors.white),
                              ),
                              child: child!);
                        },
                      );
                      if (mrkCloseTime != null) {
                        setState(() {
                          _mrkCloseTime = mrkCloseTime.format(context);
                        });
                      }
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      String mrkName = mrkNameController.text.trim();

                      if (mrkName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Market name is empty!',
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
                      } else if (_mrkOpenTime == 'Market Open Time' ||
                          _mrkCloseTime == 'Market Close Time') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Set market time and try again!',
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
                            .doc(mrkName)
                            .set({
                          'mrkname': mrkName,
                          'mrksection': select0,
                          'mrkopen': _mrkOpenTime,
                          'mrkclose': _mrkCloseTime,
                          'created': DateTime.now(),
                          'digit': 1000,
                          'openpana': 1000,
                          'closepana': 1000,
                          'updated': DateTime.now(),
                          'status': 'Active',
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
                              mrkNameController.clear();
                              _mrkOpenTime = 'Market Open Time';
                              _mrkCloseTime = 'Market Close Time';
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
                        'All',
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
                        width: 700,
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
                                              0: FractionColumnWidth(0.10),
                                              1: FractionColumnWidth(0.35),
                                              // 2: FractionColumnWidth(0.15),
                                              // 3: FractionColumnWidth(0.15),
                                              // 4: FractionColumnWidth(0.15)
                                            },
                                            children: [
                                              buildRow([
                                                '#',
                                                'Game\nName',
                                                'Section',
                                                'Today\nOpen',
                                                'Today\nClose',
                                                'Market\nStatus'
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
                                            allMrkName = doc.get('mrkname');
                                            allMrkSection =
                                                doc.get('mrksection');
                                            allMrkOpen = doc.get('mrkopen');
                                            allMrkClose = doc.get('mrkclose');
                                            allMrkStatus = doc.get('status');
                                            // doc.reference.update(({ 'digit': 1000, 'openpana': 1000, 'closepana': 1000,}));
                                            return Table(
                                              border: const TableBorder(
                                                verticalInside: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.black),
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
                                                0: FractionColumnWidth(0.10),
                                                1: FractionColumnWidth(0.35),
                                                // 2: FractionColumnWidth(0.15),
                                                // 3: FractionColumnWidth(0.15),
                                                // 4: FractionColumnWidth(0.15)
                                              },
                                              children: [
                                                buildRow([
                                                  '${index + 1}',
                                                  allMrkName,
                                                  allMrkSection,
                                                  allMrkOpen,
                                                  allMrkClose,
                                                  allMrkStatus
                                                ], isHeader: false, rowIndex: 1,
                                                    onTap: () async {
                                                  // Use viewTransact and await the Future
                                                  await editGames(
                                                      context,
                                                      doc,
                                                      screenHeight,
                                                      screenWidth);
                                                  // After the Future completes (status change is done), reload the page
                                                  refreshData();
                                                }),
                                              ],
                                            );
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

        final cellStyle = TextStyle(
          fontFamily: 'Nexa Light',
          fontSize: screenWidth / 26,
          color: cell == allMrkName ? Colors.blue.shade800 : Colors.black,
        );

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
