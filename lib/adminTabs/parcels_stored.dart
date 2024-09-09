import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/adminTabs/admin_cod_stored.dart';
import 'package:modernlogintute/adminTabs/stored_details.dart';
import 'package:modernlogintute/userTabs/cod_received_details.dart';
import 'package:flutter/material.dart';

class ParcelsStored extends StatefulWidget {
  ParcelsStored({super.key});

  @override
  State<ParcelsStored> createState() => _ParcelsStoredState();
}

class _ParcelsStoredState extends State<ParcelsStored> {
  int codOrders = 0;
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    inputData();
  }

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    print(currentUID);
  }

  var time = DateTime.now();

  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('stored');

  @override
  Widget build(BuildContext context) {
    inputData();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: StreamBuilder<QuerySnapshot>(
          stream: _reference.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Something Went Wrong"),
              );
            }
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data!;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;
              List<StoredDetails> storedDetails = documents
                  .map(
                    (e) => StoredDetails(
                      addOrReceived: e['Add or Received'],
                      modeOfPayment: e['Mode of Payment'],
                      price: e['Price'],
                      productName: e['Product Name'],
                      trackingId: e['Tracking ID'],
                      dateAdded: e['Date Added'],
                      dateReceived: e['Date Received'],
                      timeReceived: e['Time Received'],
                      unread: e['Unread'],
                      uid: e['UID'],
                    ),
                  )
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("stored")
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

                  return storedDetails.isEmpty || codOrders == 0
                      ? Center(
                          child: Text(
                            'Whoa! No Parcels stored yet',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              color: Color(0xFF191970),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: storedDetails.length,
                                  itemBuilder: (context, index) {
                                    storedDetails.sort((a, b) {
                                      int dateComparison = b.dateReceived
                                          .compareTo(a.dateReceived);
                                      if (dateComparison != 0) {
                                        return dateComparison;
                                      } else {
                                        return b.timeReceived
                                            .compareTo(a.timeReceived);
                                      }
                                    });

                                    if (storedDetails[index].uid !=
                                        currentUID) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Card(
                                            color: storedDetails[index].unread
                                                ? Colors.white
                                                : Colors.grey.withOpacity(0.5),
                                            child: InkWell(
                                              onTap: () async {
                                                // Navigate to details
                                                AdminCODStoredDetails(
                                                  trackingNumber:
                                                      storedDetails[index]
                                                          .trackingId,
                                                  productName:
                                                      storedDetails[index]
                                                          .productName,
                                                  dateAdded:
                                                      storedDetails[index]
                                                          .dateAdded,
                                                  dateReceived:
                                                      storedDetails[index]
                                                          .dateReceived,
                                                  price: storedDetails[index]
                                                      .price!
                                                      .toDouble(),
                                                  timeReceived:
                                                      storedDetails[index]
                                                          .timeReceived,
                                                ).showAdminCODStoredDetails(
                                                  context,
                                                  storedDetails[index]
                                                      .productName,
                                                  storedDetails[index]
                                                      .dateAdded,
                                                  storedDetails[index]
                                                      .dateReceived,
                                                  storedDetails[index]
                                                      .timeReceived,
                                                  storedDetails[index]
                                                      .price!
                                                      .toDouble(),
                                                  storedDetails[index]
                                                      .trackingId,
                                                );
                                                // Update Firestore
                                                await _reference
                                                    .doc(storedDetails[index]
                                                        .trackingId)
                                                    .update({"Unread": false});

                                                // Update local state
                                                setState(
                                                  () {
                                                    storedDetails[index]
                                                        .unread = false;
                                                  },
                                                );
                                              },
                                              child: ListTile(
                                                leading: storedDetails[index]
                                                        .unread
                                                    ? CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xFF191970),
                                                        radius: 8,
                                                      )
                                                    : null,
                                                title: Text(
                                                  storedDetails[index]
                                                      .productName,
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${storedDetails[index].dateAdded} ${storedDetails[index].timeReceived}",
                                                      style: GoogleFonts.ubuntu(
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Text(
                                                  "${storedDetails[index].addOrReceived} ₱${storedDetails[index].price}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 145.0,
                              ),
                            ],
                          ),
                        );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
