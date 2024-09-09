import 'package:flutter/material.dart';

class OccupiedOrNot extends StatefulWidget {
  final thickness;
  final color;
  OccupiedOrNot({
    super.key,
    required this.thickness,
    required this.color,
  });

  @override
  State<OccupiedOrNot> createState() => _OccupiedOrNotState();
}

class _OccupiedOrNotState extends State<OccupiedOrNot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      width: widget.thickness,
      child: Container(
        color: widget.color,
      ),
    );
  }
}