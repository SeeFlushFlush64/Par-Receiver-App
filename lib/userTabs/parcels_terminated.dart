import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/cod_terminated_details.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/userTabs/terminated_details.dart';
import 'package:modernlogintute/userTabs/terminated_details.dart';

class ParcelsTerminated extends StatefulWidget {
  ParcelsTerminated({super.key});

  @override
  State<ParcelsTerminated> createState() => _ParcelsTerminatedState();
}

class _ParcelsTerminatedState extends State<ParcelsTerminated> {
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
      FirebaseFirestore.instance.collection('terminated');

  

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
              List<TerminatedDetails> terminatedDetails = documents
                  .map(
                    (e) => TerminatedDetails(
                      modeOfPayment: e['Mode of Payment'],
                      productName: e['Product Name'],
                      trackingId: e['Tracking ID'],
                      date: e['Date'],
                      time: e['Time'],
                      unread: e['Unread'],
                      uid: e['UID'],
                    ),
                  )
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("terminated")
                    .where("UID", isEqualTo: currentUID)
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

                  return terminatedDetails.isEmpty || codOrders == 0
                      ? Center(
                          child: Text(
                            'Whoa! No Parcels terminated yet',
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
                                  itemCount: terminatedDetails.length,
                                  itemBuilder: (context, index) {
                                    terminatedDetails.sort((a, b) {
                                      int dateComparison = b.date
                                          .compareTo(a.date);
                                      if (dateComparison != 0) {
                                        return dateComparison;
                                      } else {
                                        return b.time
                                            .compareTo(a.time);
                                      }
                                    });

                                    if (terminatedDetails[index].uid ==
                                        currentUID) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Card(
                                            color: terminatedDetails[index].unread
                                                ? Colors.white
                                                : Colors.grey.withOpacity(0.5),
                                            child: InkWell(
                                              onTap: () async {
                                                // Navigate to details
                                                CODTerminatedDetails(
                                                  trackingNumber:
                                                      terminatedDetails[index]
                                                          .trackingId,
                                                  productName:
                                                      terminatedDetails[index]
                                                          .productName,
                                                
                                                  date:
                                                      terminatedDetails[index]
                                                          .date,
                                                  time:
                                                      terminatedDetails[index]
                                                          .time,
                                                ).showCODTerminatedDetails(
                                                  context,
                                                  terminatedDetails[index]
                                                      .productName,
                                                  terminatedDetails[index]
                                                      .date,
                                                  terminatedDetails[index]
                                                      .time,
                                                  terminatedDetails[index]
                                                      .trackingId,
                                                );
                                                // Update Firestore
                                                await _reference
                                                    .doc(terminatedDetails[index]
                                                        .trackingId)
                                                    .update({"Unread": false});

                                                // Update local state
                                                setState(
                                                  () {
                                                    terminatedDetails[index]
                                                        .unread = false;
                                                  },
                                                );
                                              },
                                              child: ListTile(
                                                leading: terminatedDetails[index]
                                                        .unread
                                                    ? CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xFF191970),
                                                        radius: 8,
                                                      )
                                                    : null,
                                                title: Text(
                                                  terminatedDetails[index]
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
                                                      "${terminatedDetails[index].date} ${terminatedDetails[index].time}",
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
