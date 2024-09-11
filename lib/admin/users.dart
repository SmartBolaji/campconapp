import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/edit_trans.dart';
import 'package:campcon/widgets/edit_users.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Late variables
  late SharedPreferences sharedPreferences;

  QuerySnapshot? _snap;
  bool circular = false;
  bool refreshCircle = false;
  bool refreshLoad = false;
  int currentSnapSize = 0; // Variable to keep track of snapshot size

  // Get the current date
  DateTime now = DateTime.now();

  // Market details
  int userId = 0;
  String allName = '';
  double allPoints = 0.0;
  Timestamp fetchDate = Timestamp.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = Colors.blue.shade300;

  // Function

  // Method to refresh data
  Future<void> refreshData() async {
    setState(() {
      loadBidsData();
    });
  }

  // Method to load games data
  Future<void> loadBidsData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .orderBy('created', descending: true)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Users')
            .orderBy('created', descending: true)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }
      setState(() {
        if (_snap!.size > 20) {
          currentSnapSize = 20; // Update to 20
        } else {
          currentSnapSize = _snap!.size; // Update default
        }
      });
    } catch (e) {
      Transform.scale(
          scale: 0.5,
          child: const CircularProgressIndicator(color: Colors.white));
    }
  }

  // Load more bids data
  Future<void> loadMoreBidsData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .orderBy('created', descending: true)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Users')
            .orderBy('created', descending: true)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }
      setState(() {
        if (_snap!.size > currentSnapSize &&
            currentSnapSize > currentSnapSize + 10) {
          currentSnapSize += 10; // Increase to 10
        } else {
          currentSnapSize = _snap!.size; // Update default
        }
      });
    } catch (e) {
      Transform.scale(
          scale: 0.5,
          child: const CircularProgressIndicator(color: Colors.white));
    }
  }

  @override
  void initState() {
    super.initState();
    loadBidsData();
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    Color primary = Colors.blue.shade300;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
                'Users',
                style: TextStyle(
                    fontFamily: 'Nexa Bold',
                    fontSize: screenWidth / 17,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      // drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
          top: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    taskData.month5,
                    style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 20,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      final month = await showMonthYearPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2099),
                        builder: (context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: primary,
                                    secondary: primary,
                                    onSecondary: Colors.white),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: primary,
                                  ),
                                ),
                                textTheme: const TextTheme(
                                  headlineMedium:
                                      TextStyle(fontFamily: 'Nexa Bold'),
                                  labelSmall:
                                      TextStyle(fontFamily: 'Nexa Bold'),
                                  labelLarge:
                                      TextStyle(fontFamily: 'Nexa Bold'),
                                  // displaySmall:
                                  //     TextStyle(fontFamily: 'Nexa Light'),
                                ),
                              ),
                              child: child!);
                        },
                      );

                      if (month != null) {
                        taskData.updateM5(
                            context, DateFormat('MMMM').format(month));
                      }
                    },
                    child: Text(
                      'Pick a Month',
                      style: TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 20,
                          color: Colors.blue.shade500),
                    ),
                  ),
                ),
              ],
            ),
            Container(
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
                            refreshData();
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
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            refreshLoad = true;
                            // refreshData();
                          });
                          loadMoreBidsData();
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
                              refreshLoad = false;
                            });
                          });
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade800,
                          child: refreshLoad
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white))
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  size: screenWidth / 30,
                                  color: Colors.white,
                                ),
                        ),
                      )
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
                                              0: FractionColumnWidth(0.05),
                                              // 1: FractionColumnWidth(0.14),
                                              // 2: FractionColumnWidth(0.15),
                                              // 3: FractionColumnWidth(0.15),
                                              // 4: FractionColumnWidth(0.15)
                                            },
                                            children: [
                                              buildRow([
                                                '#',
                                                'Member',
                                                'Balance',
                                                'Date',
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
                                            final doc = _snap!.docs[index];
                                            userId = doc.get('id');
                                            allName = doc.get('name');
                                            allPoints = doc.get('points');
                                            fetchDate = doc.get('created');
                                            String formatAllDate =
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(fetchDate.toDate());

                                            return DateFormat('MMMM').format(
                                                        fetchDate.toDate()) ==
                                                    taskData.month5
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
                                                        '${userId.toString()}\n($allName)',
                                                        allPoints.toString(),
                                                        formatAllDate,
                                                      ],
                                                          isHeader: false,
                                                          rowIndex: 1,
                                                          onTap: () async {
                                                        // Use viewTransact and await the Future
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UserDetailsPage(
                                                                          doc:
                                                                              doc,
                                                                        )));
                                                        // After the Future completes (status change is done), reload the page
                                                        refreshData();
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
          color: cell == '${userId.toString()}\n($allName)'
              ? Colors.blue.shade800
              : Colors.black,
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

  Widget buildContainer(
      String title, String digit, IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 25,
          bottom: 25,
          right: 20,
          left: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black, // Shadow color
          //     spreadRadius: 3, // Spread radius
          //     blurRadius: 3, // Blur radius
          //     offset: Offset(0, 3), // Offset from the top left corner
          //   ),
          // ],
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nexa Light',
                    fontSize: screenWidth / 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  digit,
                  style: TextStyle(
                    fontFamily: 'Nexa Bold',
                    fontSize: screenWidth / 18,
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
