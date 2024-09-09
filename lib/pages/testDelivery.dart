import 'package:flutter/material.dart';

class TestDelivery extends StatefulWidget {
  const TestDelivery({super.key});

  @override
  State<TestDelivery> createState() => _TestDeliveryState();
}

class _TestDeliveryState extends State<TestDelivery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          "https://firebasestorage.googleapis.com/v0/b/samgyup-business-ni-dani.appspot.com/o/data%2Ffirst_parcel.jpg?alt=media&token=475d7e2a-3699-481f-abe6-63430db7538d",),),
    );
  }
}
