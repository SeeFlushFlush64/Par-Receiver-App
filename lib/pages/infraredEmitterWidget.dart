import 'package:flutter/material.dart';

class InfraredEmitterWidget extends StatelessWidget {
  final double width;
  final double height;

  const InfraredEmitterWidget({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8), // Base color
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: width * 0.6,
              height: height * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.red.withOpacity(0.6), // Adjusted glare opacity
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}