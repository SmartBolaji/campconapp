import 'package:flutter/material.dart';

class TwoLineMenuIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 19,
          height: 2,
          color: Colors.grey.shade500,
        ),
        SizedBox(height: 4),
        Container(
          width: 14,
          height: 2,
          color: Colors.grey.shade500,
        ),
        SizedBox(height: 4),
        Container(
          width: 19,
          height: 2,
          color: Colors.grey.shade500,
        ),
      ],
    );
  }
}
