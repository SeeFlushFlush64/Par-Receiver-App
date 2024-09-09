import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final double horizontalDimension;
  final double verticalDimension;
  final String text;
  MyButton({super.key, required this.onTap, required this.text, required this.horizontalDimension, required this.verticalDimension});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalDimension, vertical: verticalDimension),
        margin: EdgeInsets.symmetric(horizontal: horizontalDimension),
        decoration: BoxDecoration(
          color: Color(0xFF191970),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
