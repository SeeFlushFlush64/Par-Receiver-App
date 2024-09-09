import 'package:flutter/material.dart';

class LCDScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.black,
            width: 4.0,
          ),
        ),
        child: Stack(
          children: [
            // Display Area
            Positioned.fill(
              child: Container(
                color: Color.fromARGB(255, 2, 47, 184),
              ),
            ),
            // Backlight (optional)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.blue,
                    ],
                    stops: [0.0, 0.1, 0.9, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
