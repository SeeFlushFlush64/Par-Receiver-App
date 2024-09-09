import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CountCOD extends StatefulWidget {
  const CountCOD({Key? key}) : super(key: key);

  @override
  State<CountCOD> createState() => _CountCODState();
}

class _CountCODState extends State<CountCOD> {
  int codOrders = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("parcels").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No data available');
                }

                var documents = snapshot.data!.docs;
                var totalCount = documents.length;

                // Print total count for verification (comment out in production)
                print('Total documents: $totalCount');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.0),
                    Text('Total Documents: $totalCount'),
                  ],
                );
              },
            ),
            SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("parcels")
                  .where("Mode of Payment", isEqualTo: "Cash on Delivery")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No data available');
                }

                var codCount = snapshot.data!.docs.length;
                codOrders = codCount;

                // Print COD count for verification (comment out in production)
                print('COD documents: $codOrders');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.0),
                    Text('COD Documents: $codCount'),
                  ],
                );
              },
            ),
            SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("parcels")
                  .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No data available');
                }

                var nonCodCount = snapshot.data!.docs.length;

                // Print COD count for verification (comment out in production)
                print('Non-COD documents: $nonCodCount');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.0),
                    Text('Non-COD Documents: $nonCodCount'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
