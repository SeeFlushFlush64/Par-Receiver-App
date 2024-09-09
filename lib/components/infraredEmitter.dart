// import 'package:flutter/material.dart';

// class InfraredEmitter extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 122,
//       height: 140,
//       child: CustomPaint(
//         painter: BeamPainter(),
//       ),
//     );
//   }
// }

// class BeamPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Colors.red,
//           Colors.red.withOpacity(0.1),
//         ],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     path.moveTo(size.width / 2, 0); // Top center
//     path.lineTo(size.width, size.height); // Bottom right
//     path.lineTo(0, size.height); // Bottom left
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

import 'package:flutter/material.dart';

class InfraredEmitter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.sizeOf(context).width * 0.31,
          MediaQuery.sizeOf(context).height * 0.142),
      painter: BeamPainter(),
    );
  }
}

class BeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red,
          Colors.red.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.45, 0); // Slightly wider top left
    path.lineTo(size.width * 0.55, 0); // Slightly wider top right
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
