import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/added_details.dart';
import 'package:modernlogintute/userTabs/cod_added_details.dart';

class ParcelsAdded extends StatefulWidget {
  ParcelsAdded({Key? key}) : super(key: key);

  @override
  State<ParcelsAdded> createState() => _ParcelsAddedState();
}

class _ParcelsAddedState extends State<ParcelsAdded> {
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
      FirebaseFirestore.instance.collection('added');

  @override
  Widget build(BuildContext context) {
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
              List<AddedDetails> addedDetails = documents
                  .map(
                    (e) => AddedDetails(
                      addOrReceived: e['Add or Received'],
                      modeOfPayment: e['Mode of Payment'],
                      price: e['Price'],
                      productName: e['Product Name'],
                      trackingId: e['Tracking ID'],
                      dateAdded: e['Date Added'],
                      timeAdded: e['Time Added'],
                      uid: e['UID'],
                      unread: e['Unread'],
                    ),
                  )
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("added")
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

                  return addedDetails.isEmpty || codOrders == 0
                      ? Center(
                          child: Text(
                            'Whoa! No Parcels added yet',
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
                                  itemCount: addedDetails.length,
                                  itemBuilder: (context, index) {
                                    addedDetails.sort((a, b) {
                                      int dateComparison =
                                          b.dateAdded.compareTo(a.dateAdded);
                                      if (dateComparison != 0) {
                                        return dateComparison;
                                      } else {
                                        return b.timeAdded
                                            .compareTo(a.timeAdded);
                                      }
                                    });

                                    if (addedDetails[index].uid == currentUID) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Card(
                                            color: addedDetails[index].unread
                                                ? Colors.white
                                                : Colors.grey.withOpacity(0.5),
                                            child: InkWell(
                                              onTap: () async {
                                                // Update Firestore

                                                // Navigate to details
                                                CODAddedDetails(
                                                  trackingNumber:
                                                      addedDetails[index]
                                                          .trackingId,
                                                  productName:
                                                      addedDetails[index]
                                                          .productName,
                                                  dateAdded: addedDetails[index]
                                                      .dateAdded,
                                                  timeAdded: addedDetails[index]
                                                      .timeAdded,
                                                  price: addedDetails[index]
                                                      .price!,
                                                ).showCODReceivedDetails(
                                                  context,
                                                  addedDetails[index]
                                                      .productName,
                                                  addedDetails[index].dateAdded,
                                                  addedDetails[index].timeAdded,
                                                  addedDetails[index].price!,
                                                  addedDetails[index]
                                                      .trackingId,
                                                );
                                                await _reference
                                                    .doc(addedDetails[index]
                                                        .trackingId)
                                                    .update({"Unread": false});

                                                // Update local state
                                                setState(
                                                  () {
                                                    addedDetails[index].unread =
                                                        false;
                                                  },
                                                );
                                              },
                                              child: ListTile(
                                                leading: addedDetails[index]
                                                        .unread
                                                    ? CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xFF191970),
                                                        radius: 8,
                                                      )
                                                    : null,
                                                title: Text(
                                                  addedDetails[index]
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
                                                      "${addedDetails[index].dateAdded} ${addedDetails[index].timeAdded}",
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
                                                  "${addedDetails[index].addOrReceived} PHP ${addedDetails[index].price.toString()}",
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
