import 'package:flutter/material.dart';

class MatrixKeypad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (BuildContext context, int index) {
            return KeypadKey(
              label: getLabel(index),
              backgroundColor: getBackgroundColor(index),
            );
          },
        ),
      ),
    );
  }

  String getLabel(int index) {
    if (index == 3 || index == 7 || index == 11 || index == 15) {
      // These are "letter" and "punctuation" keys
      return String.fromCharCode(65 + index ~/ 4); // A, B, C, D
    } else {
      // These are "number" keys
      return (index % 4 + 1).toString();
    }
  }

  Color getBackgroundColor(int index) {
    if (index == 3 ||
        index == 7 ||
        index == 11 ||
        index == 15 ||
        index == 12 ||
        index == 14) {
      // "letter" and "punctuation" keys should have red background
      return Colors.red;
    } else {
      // "number" keys should have blue background
      return Colors.blue.shade400;
    }
  }
}

class KeypadKey extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  KeypadKey({required this.label, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                backgroundColor, // Set text color same as the background color
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: MatrixKeypad(),
//   ));
// }
