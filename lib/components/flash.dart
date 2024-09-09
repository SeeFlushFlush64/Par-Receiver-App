import 'package:flutter/material.dart';

class FlashWidget extends StatelessWidget {
  final double diameter;

  const FlashWidget({
    Key? key,
    required this.diameter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.yellow.withOpacity(0.8), // More transparent yellow
            Colors.yellow.withOpacity(0.3), // Less transparent yellow
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: diameter * 0.6,
              height: diameter * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.withOpacity(0.5), // Adjusted glare opacity
              ),
            ),
          ),
        ],
      ),
    );
  }
}