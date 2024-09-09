import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShelfWidget extends StatelessWidget {
  final int index;
  ShelfWidget({required this.index});
  List<String> cashContainerLetters = [
    'A',
    'B',
    'C',
    'D',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        children: [
          // Shelf Content
          // Center(
          //   child: Text(
          //     'Shelf Content',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
          Positioned(
            right: 0,
            top: 3,
            left: 3,
            bottom: 0,
            child: Container(
              width: 15,
              child: Text(
                cashContainerLetters[index],
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Circular Handle
          Positioned(
            right: 1,
            top: 0,
            bottom: 0,
            child: Container(
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.brown,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              // child: Center(
              //   child: Icon(
              //     Icons.drag_handle,
              //     color: Colors.white,
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   width: 170,
    //   height: 50,
    //   // color: Colors.grey.shade50,
    //   decoration: BoxDecoration(
    //     color: Colors.grey.shade50,
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.2),
    //         spreadRadius: 5,
    //         blurRadius: 7,
    //         offset: Offset(
    //             0, 10), // Adjust the Y-offset for better shadow placement
    //       ),
    //     ],
    //   ),
    // );
    return Material(
      // elevation: 4,
      child: Container(
        width: 170,
        height: 50,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// class DrawerWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 4, // Elevation for the whole drawer
//       child: Column(
//         children: [
//           Container(
//             width: 170,
//             height: 10, // Height for the upper shadow
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   spreadRadius: 2,
//                   blurRadius: 3,
//                   offset: Offset(0,
//                       -2), // Negative Y-offset to place shadow above the drawer
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 170,
//             height: 40, // Height for the main content
//             color: Colors.grey.shade400,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LCDScreen extends StatelessWidget {
//   const LCDScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 30,
//       height: 20,
//       color: Colors.grey.shade50,
//     );
//   }
// }

class CashContainerHandle extends StatelessWidget {
  const CashContainerHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
