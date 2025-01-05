import 'package:flutter/material.dart';

class SingleTaskViewPage extends StatefulWidget {
  @override
  _SingleTaskViewPageState createState() => _SingleTaskViewPageState();
}

class _SingleTaskViewPageState extends State<SingleTaskViewPage> {
  final Map<String, dynamic> task = {
    "title": "Complete Course Registration",
    "description":
        "Ensure all documents are submitted and fees are paid to avoid delays in the registration process.",
    "subtasks": [
      {
        "title": "Submit required documents",
        "note": "Include admission letter and passport photo.",
        "completed": false,
        "expanded": false,
      },
      {
        "title": "Pay registration fees",
        "note": "Payment can be made online or at the bank.",
        "completed": false,
        "expanded": false,
      },
      {
        "title": "Collect registration confirmation",
        "note": "Visit the admin office to collect confirmation slip.",
        "completed": false,
        "expanded": false,
      },
    ],
    "completed": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFBA9E02),
        child: Icon(
          Icons.question_mark,
          size: 25,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          task['title'],
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey.shade800,
          ),
        ),
        actions: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: task['completed'],
              onChanged: (value) {
                setState(() {
                  task['completed'] = value!;
                  for (var subtask in task['subtasks']) {
                    subtask['completed'] = value;
                  }
                });
              },
              activeColor: const Color(0xFFBA9E02),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40), // Rounded corners
              ),
              side: BorderSide(
                color: Colors.grey.shade300, // Border color of the checkbox
                width: 2, // Border width
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        padding:
            const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Description
            Text(
              task['description'],
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontFamily: 'Lato',
              ),
            ),
            const SizedBox(height: 20),
            // Subtasks List
            Expanded(
              child: ListView.builder(
                itemCount: task['subtasks'].length,
                itemBuilder: (context, index) {
                  final subtask = task['subtasks'][index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        // Subtask Header (Expand/Collapse Icon, Title, and Checkbox)
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(30, 0, 10, 0),
                          trailing: IconButton(
                            style: ButtonStyle(
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.all(3)),
                                backgroundColor: WidgetStatePropertyAll(
                                    Colors.grey.shade100)),
                            icon: Icon(
                              subtask['expanded']
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 25,
                            ),
                            onPressed: () {
                              setState(() {
                                subtask['expanded'] = !subtask['expanded'];
                              });
                            },
                          ),
                          title: Text(
                            subtask['title'],
                            style: TextStyle(
                              fontSize: 14,
                              color: subtask['completed']
                                  ? Colors.grey.shade600
                                  : Colors.black,
                              decoration: subtask['completed']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontFamily: 'Lato',
                            ),
                            maxLines: 2,
                          ),
                          // trailing: Checkbox(
                          //   value: subtask['completed'],
                          //   onChanged: (value) {
                          //     setState(() {
                          //       subtask['completed'] = value!;
                          //       task['completed'] = task['subtasks']
                          //           .every((st) => st['completed']);
                          //     });
                          //   },
                          //   activeColor: Colors.green,
                          // ),
                        ),
                        // Subtask Details (Notes)
                        if (subtask['expanded'])
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 50, left: 30, bottom: 20),
                            child: Text(
                              subtask['note'] ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
