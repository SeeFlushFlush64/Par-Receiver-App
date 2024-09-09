import 'package:flutter/material.dart';

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.2, 0); // Top left
    path.lineTo(size.width * 0.8, 0); // Top right
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();

    canvas.drawPath(path, paint);

    final barWidth = size.width * 0.04; // Width of each barcode line
    final gapWidth = size.width * 0.02; // Gap between barcode lines

    for (double x = size.width * 0.2;
        x < size.width * 0.8;
        x += barWidth + gapWidth) {
      final barPath = Path();
      barPath.moveTo(x, 0);
      barPath.lineTo(x + barWidth, 0);
      barPath.lineTo(x + barWidth * 0.5, size.height);
      barPath.lineTo(x, size.height);
      barPath.close();

      canvas.drawPath(barPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
