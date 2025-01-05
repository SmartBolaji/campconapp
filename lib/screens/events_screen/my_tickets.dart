import 'package:flutter/material.dart';

class MyTicketsPage extends StatelessWidget {
  final List<Map<String, String>> tickets = [
    {
      "event": "Phoenix Lounge",
      "date": "March 25, 2025",
      "location": "Palms Mall Shopping Complex, Ibadan",
      "price": "\$50.00",
      "quantity": "2",
      "image": "assets/images/social.jpeg",
    },
    {
      "event": "Ibadan Music Fest",
      "date": "April 15, 2025",
      "location": "Civic Centre, Ibadan",
      "price": "\$30.00",
      "quantity": "1",
      "image": "assets/images/social.jpeg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String ticketid = '${now.millisecondsSinceEpoch}';

    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          title: const Text(
            "My Tickets",
            style: TextStyle(
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
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
              onPressed: () {
                // Filter action
              },
            ),
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.grey.shade800),
              onPressed: () {
                // Help action
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
                padding: const EdgeInsets.only(
                    // left: 20,
                    // right: 20,
                    // bottom: 20,
                    ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                )),
            tickets.isEmpty
                ? Column(
                    children: [
                      Center(
                        child: Text(
                          "No tickets purchased yet!",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ticket Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      ticket['image']!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket['event']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          ticket['location']!,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Ticket ID: $ticketid",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Price: ${ticket['price']}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              "Quantity: ${ticket['quantity']}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Lato',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Date
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${ticket['date']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Trebuchet',
                                    ),
                                  ),
                                ),
                              ),
                              // Tag (e.g., "Bought")
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Bought",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Trebuchet',
                                    ),
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
        ));
  }
}
