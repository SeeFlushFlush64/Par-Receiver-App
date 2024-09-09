import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  bool isTotalVisible = true;
  double totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("parcels").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Text('No data available');
            }

            totalPrice = calculateTotalPrice(snapshot.data!);

            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Total Price Display
                Visibility(
                  visible: isTotalVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      'Total Price: ${isTotalVisible ? totalPrice.toString() : '********'}',
                    ),
                  ),
                ),

                // Eye Toggle Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTotalVisible = !isTotalVisible;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: CustomPaint(
                      size: Size(30, 30),
                      painter: EyePainter(isTotalVisible),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double calculateTotalPrice(QuerySnapshot snapshot) {
    List<double> prices = [];
    snapshot.docs.forEach((document) {
      var price = document['Price'] ?? 0.0;
      prices.add(price);
    });
    return prices.reduce((value, element) => value + element);
  }
}

class EyePainter extends CustomPainter {
  final bool isOpen;

  EyePainter(this.isOpen);

  @override
  void paint(Canvas canvas, Size size) {
    Paint whitePaint = Paint()..color = Colors.white;
    Paint blackPaint = Paint()..color = Colors.black;

    // Draw the white of the eye
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), whitePaint);

    if (isOpen) {
      // Draw eyelashes
      double angle = 0;
      double eyelashLength = size.width * 0.1;

      for (int i = 0; i < 5; i++) {
        double startX = size.width - cos(angle) * eyelashLength;
        double startY = sin(angle) * eyelashLength;

        double endX = size.width;
        double endY = 0;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), blackPaint);

        angle += (pi /
            8); // Divide the upper half of the circle into 5 parts for 5 eyelashes
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
