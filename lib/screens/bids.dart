import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/view_bid.dart';
import 'package:provider/provider.dart';

class BidsScreen extends StatelessWidget {
  const BidsScreen({super.key});

  // double screenHeight = 0.0;

  // double screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    Color primary = Colors.blue.shade300;

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
              )),
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bid History',
                  style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 17,
                      color: Colors.white),
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
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 32),
                    child: Text(
                      taskData.month2,
                      style: TextStyle(
                        fontFamily: 'Nexa Bold',
                        fontSize: screenWidth / 20,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(top: 32),
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
                          taskData.updateM2(
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
              SizedBox(
                height: screenHeight / 20,
              ),
              SizedBox(
                  height: screenHeight / 1.4,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Bids')
                        .where('id', isEqualTo: taskData.id)
                        .orderBy('created', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final snap = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: snap.length,
                            itemBuilder: (context, index) {
                              final snap0 = snap[index];
                              return DateFormat('MMMM').format(
                                          snap[index]['created'].toDate()) ==
                                      taskData.month2
                                  ? customTxn(
                                      Icons.done,
                                      snap[index]['trackid'],
                                      DateFormat('M/dd/yyyy, h:mm:ss a').format(
                                          snap[index]['created'].toDate()),
                                      snap[index]['points'],
                                      index,
                                      screenWidth, () {
                                      viewInfo(context, snap0, screenHeight,
                                          screenWidth);
                                    })
                                  : const SizedBox();
                            });
                      } else {
                        return const SizedBox();
                      }
                    },
                  ))
            ],
          ),
        ));
  }

  Widget customTxn(IconData icon, String txn, String date, double amount,
      int colorIndex, double screenWidth, Function onTap) {
    Color backgroundColor =
        colorIndex % 2 == 0 ? Colors.white : Colors.grey.shade200;

    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side
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
              ),
            ),
            const SizedBox(width: 16),
            // Middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: screenWidth / 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side
            Text(
              '\- $amount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
