import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

int codOrdersNungCurrentUser = 0;


class CODOrdersNungCurrentUser extends StatefulWidget {
  const CODOrdersNungCurrentUser({super.key});

  @override
  State<CODOrdersNungCurrentUser> createState() =>
      _CODOrdersNungCurrentUserState();
}

class _CODOrdersNungCurrentUserState extends State<CODOrdersNungCurrentUser> {
  String currentUID = "";

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    // print(currentUID);
    // here you write the codes to input the data into firestore
  }

  @override
  Widget build(BuildContext context) {
    inputData();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("parcels")
          .where("UID", isEqualTo: currentUID) // Filter documents by UID
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

        var parcelCount = snapshot.data!.docs.length;
        codOrdersNungCurrentUser = parcelCount;
        log(codOrdersNungCurrentUser.toString());

        // Print the count of documents with the same UID as currentUID
        print('Number of documents with UID $currentUID: $parcelCount');

        // Your remaining code goes here

        return Container();
      },
    );
  }
}
