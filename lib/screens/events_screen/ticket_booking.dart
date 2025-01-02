import 'package:flutter/material.dart';

class TicketBookingPage extends StatefulWidget {
  @override
  _TicketBookingPageState createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  int selectedTickets = 1; // Default ticket count
  double ticketPrice = 50.0; // Example price per ticket
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String ticketid = '${now.millisecondsSinceEpoch}';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          "Book Tickets",
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
            icon: Icon(Icons.help_outline, color: Colors.grey.shade800),
            onPressed: () {
              // Help action
            },
          ),
        ],
        // elevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Event Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phoenix Lounge",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Date: March 25, 2025",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Palms Mall Shopping Complex, Ibadan",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ticket ID: $ticketid",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ticket Selection
                const Text(
                  "Select Tickets",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ticket Price",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "\$${ticketPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Number of Tickets",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: selectedTickets > 1
                                ? () {
                                    setState(() {
                                      selectedTickets--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            "$selectedTickets",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                selectedTickets++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Summary
                const Text(
                  "Total Price",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: Text(
                    "\$${(ticketPrice * selectedTickets).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle payment
              },
              icon: Icon(
                Icons.payment, // Payment icon
                color: Colors.grey.shade100,
              ),
              label: Text(
                "Proceed to Payment",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lato',
                  color: Colors.grey.shade100,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: const RoundedRectangleBorder(
                    // borderRadius:
                    //     BorderRadius.circular(12), // Adds consistent styling
                    ),
                backgroundColor: const Color(0xFF9c936b),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
