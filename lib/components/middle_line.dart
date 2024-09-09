import 'package:flutter/material.dart';

class MiddleLine extends StatefulWidget {
  final thickness;
  final color;
  MiddleLine({
    super.key,
    required this.thickness,
    required this.color,
  });

  @override
  State<MiddleLine> createState() => _MiddleLineState();
}

class _MiddleLineState extends State<MiddleLine> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.177,
      width: widget.thickness,
      child: Container(
        color: widget.color,
      ),
    );
  }
}
