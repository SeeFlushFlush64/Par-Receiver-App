import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Image.network('https://firebasestorage.googleapis.com/v0/b/samgyup-business-ni-dani.appspot.com/o/proofDeposit%2F%3CCash%20Container%20D%3EMaanFebruary27?alt=media&token=c1886c56-acaf-4cfa-9cc1-d5280822667f'),
      ),
    );
  }
}