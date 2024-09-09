import 'package:flutter/material.dart';

class TestShowPicture extends StatefulWidget {
  const TestShowPicture({super.key});

  @override
  State<TestShowPicture> createState() => _TestShowPictureState();
}

class _TestShowPictureState extends State<TestShowPicture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network('https://firebasestorage.googleapis.com/v0/b/samgyup-business-ni-dani.appspot.com/o/data%2FMP0780995615.jpg?alt=media&token=a8479fea-203d-403a-8f2d-80dc7280e30f'),
      ),
    );
  }
}