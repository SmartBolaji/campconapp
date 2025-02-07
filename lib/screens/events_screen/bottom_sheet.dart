import 'package:campcon/screens/events_screen/event_view.dart';
import 'package:campcon/screens/events_screen/ticket_booking.dart';
import 'package:campcon/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.widget,
  });

  final EventViewPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border:
              Border(top: BorderSide(width: 1, color: Colors.grey.shade300))),
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.price,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(
                IconlyBold.calendar,
                size: 30,
                color: Color(0xFF9c936b),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                IconlyBold.tick_square,
                size: 30,
                color: Color(0xFF9c936b),
              ),
              const SizedBox(
                width: 15,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add to checkout
                  NavigationHelper.navigateTo(context, TicketBookingPage());
                },
                icon: null,
                label: const Text(
                  'Get tickets',
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF9c936b),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
