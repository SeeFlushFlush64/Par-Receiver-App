import 'package:flutter/material.dart';

class TransparentBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.31,
      height: MediaQuery.sizeOf(context).height * 0.026,
      color: Colors.white.withOpacity(0.5),
    );
  }
}
