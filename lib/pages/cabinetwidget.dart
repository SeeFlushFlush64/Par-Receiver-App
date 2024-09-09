import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/barcodePointingDown.dart';
import 'package:modernlogintute/components/barcodeScanner.dart';
import 'package:modernlogintute/components/flash.dart';
import 'package:modernlogintute/components/infraredEmitter.dart';
import 'package:modernlogintute/components/lower_line.dart';
import 'package:modernlogintute/components/middle_line.dart';
import 'package:modernlogintute/components/occupiedOrNot.dart';
import 'package:modernlogintute/components/transparentBackground.dart';
import 'package:modernlogintute/pages/infraredEmitterWidget.dart';
import 'package:modernlogintute/pages/lcdscreen.dart';
import 'package:modernlogintute/pages/matrixkeypad.dart';
import 'package:modernlogintute/pages/shelfwidget.dart';

class CabinetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with Oblong Shadow
        Container(
          width: MediaQuery.of(context).size.width * 0.64,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 10), // Adjust the Y-offset to make it oblong
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.0,
          left: MediaQuery.of(context).size.width * 0.305,
          child: MiddleLine(
            color: Colors.black,
            thickness: 7.0,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.168,
          left: MediaQuery.of(context).size.width * 0.32,
          child: LowerLine(
            color: Colors.black,
            thickness: 7.0,
          ),
        ),
// Glass-like container in the upper right corner
        Positioned(
          top: 0,
          right: 0,
          child: ClipPath(
            clipper: GlassClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.32,
              height: MediaQuery.of(context).size.height * 0.17,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                    0.5), // Adjust the opacity for a glass-like effect
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        // Positioned(
        //   top: 55,
        //   left: 20,
        //   child: LCDScreen(),
        // ),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.325,
          child: TransparentBackground(),
        ),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.428,
          child: Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(
              child: CustomPaint(
                size: Size(MediaQuery.sizeOf(context).width * 0.105,
                    MediaQuery.sizeOf(context).height * 0.026),
                painter: BarcodePainter(),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.026,
          left: MediaQuery.of(context).size.width * 0.325,
          child: Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(
              child: InfraredEmitter(),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.36,
          left: MediaQuery.of(context).size.width * 0.48,
          child: Image.asset(
            'lib/images/firebase_icon.png',
            height: 55.0,
            width: 50.0,
            // color: Color(0xFF191970),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.36,
          left: MediaQuery.of(context).size.width * 0.36,
          child: Image.asset(
            'lib/images/flutter_icon.png',
            height: 55.0,
            width: 50.0,
            // color: Color(0xFF191970),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.115,
          left: MediaQuery.of(context).size.width * 0.0625,
          child: BarcodeScannerWidget(),
        ),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.1225,
          left: MediaQuery.of(context).size.width * 0.078,
          child: InfraredEmitterWidget(
            height: 13,
            width: 18,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.119,
          left: MediaQuery.of(context).size.width * 0.13,
          child: FlashWidget(
            diameter: 20,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.108,
          left: MediaQuery.of(context).size.width * 0.075,
          child: Image.asset(
            'lib/images/ultrasonic sensor.png',
            height: 80,
            width: 40,
          ),
        ),
        // Shelves
        Positioned(
          top: MediaQuery.of(context).size.height * 0.205,
          left: MediaQuery.of(context).size.width * 0.052,
          child: ShelfWidget(index: 0),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.253,
          left: MediaQuery.of(context).size.width * 0.052,
          child: ShelfWidget(index: 1),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.301,
          left: MediaQuery.of(context).size.width * 0.052,
          child: ShelfWidget(index: 2),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.349,
          left: MediaQuery.of(context).size.width * 0.052,
          child: ShelfWidget(index: 3),
        ),
        // Drawer
        Positioned(
          top: MediaQuery.of(context).size.height * 0.45,
          left: MediaQuery.of(context).size.width * 0.1,
          child: DrawerWidget(),
        ),

        // Window-like Image
        // Positioned(
        //   top: 20,
        //   right: 10,
        //   child: ClipPath(
        //     clipper: CustomWindowClipper(),
        //     child: Container(
        //       width: 50,
        //       height: 80,
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         border: Border.all(
        //           color: Colors.black,
        //           width: 2.0,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// class CustomWindowClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width - 20, size.height);
//     path.lineTo(size.width - 20, 20);
//     path.lineTo(0, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

// Custom Clipper for Glass-like effect
class GlassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
