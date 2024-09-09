import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashContainerStatus extends StatelessWidget {
  Stream<int> _cashContainerStream() {
    return FirebaseFirestore.instance
        .collection('parcels')
        .where('Cash Container', whereIn: [
          'Cash Container A',
          'Cash Container B',
          'Cash Container C',
          'Cash Container D'
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _cashContainerStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        int cashContainerCount = snapshot.data ?? 0;

        return Text(
          '$cashContainerCount',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        );
      },
    );
  }
}
