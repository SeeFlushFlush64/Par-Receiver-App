import 'package:flutter/material.dart';

class LowerLine extends StatefulWidget {
  final thickness;
  final color;
  LowerLine({
    super.key,
    required this.thickness,
    required this.color,
  });

  @override
  State<LowerLine> createState() => _LowerLineState();
}

class _LowerLineState extends State<LowerLine> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.thickness,
      width: MediaQuery.of(context).size.width * 0.34,
      child: Container(
        color: widget.color,
      ),
    );
  }
}
