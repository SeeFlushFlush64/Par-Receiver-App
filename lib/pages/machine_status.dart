import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/pages/cabinetwidget.dart';

class MachineStatus extends StatefulWidget {
  const MachineStatus({super.key});

  @override
  State<MachineStatus> createState() => _MachineStatusState();
}

class _MachineStatusState extends State<MachineStatus> {
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
  }

  @override
  void initState() {
    super.initState();
    inputData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MACHINE STATUS"),
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ubuntu(
          letterSpacing: 2.0,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Color(0xFF191970),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Image.asset(
                            'lib/images/firestore_logo.png',
                            height: 45.0,
                            width: 40.0,
                            // color: Color(0xFF191970),
                          ),
                        ),
                      ),
                      // Flexible(
                      //   flex: 1,
                      //   child: Container(),
                      // ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(
                        flex: 10,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            "Each cash container has an icon associated with it.\n> Green means Vacant (can be used by you or other users)\n> Red means occupied by other users (e.g. Clarissa)\n> Blue means occupied by you (instead of your name, it will display the amount of money you've deposited)",
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              // Text(
              //   "Par-Receiver Machine Status",
              //   style: GoogleFonts.ubuntu(
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFF191970),
              //     fontSize: 20.0,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.09,
                        ),
                        // SizedBox(
                        //   height: 120.0,
                        // ),
                        Container(
                          height: 30.0,
                          width: 70.0,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('parcels')
                                .where("Cash Container",
                                    isEqualTo: "Cash Container A")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While waiting for data, display the default "Vacant" container
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              if (snapshot.hasError) {
                                // Handle errors
                                return _buildContainer(
                                    'Error', Colors.red, context);
                              }
                              // If there are no documents or the document doesn't exist, display the default "Vacant" container
                              if (snapshot.data == null ||
                                  snapshot.data!.docs.isEmpty) {
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              // If document exists, extract the name and display it
                              String name = '';
                              double price = 0.0;
                              String UID = "";
                              if (snapshot.hasData) {
                                UID = snapshot.data!.docs[0].get('UID') ?? '';
                                price =
                                    snapshot.data!.docs[0].get('Price') ?? '';
                                log("Ito yung current UID: " + currentUID);
                                return UID != currentUID
                                    ? StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'userName_email_sign_in')
                                            .doc(UID)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // While waiting for data, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (!snapshot.hasData) {
                                            // If there is no data or the document doesn't exist, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (snapshot.hasData) {
                                            name = snapshot.data!.get('Name') ??
                                                '';
                                            log("Ito yung gumagamit ng Cash Container A: " +
                                                name);
                                          }

                                          return _buildContainer(
                                              name.isNotEmpty ? name : 'Vacant',
                                              name.isNotEmpty
                                                  ? Colors.red
                                                  : Colors.green,
                                              context);
                                        },
                                      )
                                    : _buildCurrentUIDContainer(
                                        price, Color(0xFF191970), context);
                              }
                              return _buildContainer(
                                  name.isNotEmpty ? name : 'Vacant',
                                  name.isNotEmpty ? Colors.red : Colors.green,
                                  context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          height: 30.0,
                          width: 70.0,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('parcels')
                                .where("Cash Container",
                                    isEqualTo: "Cash Container B")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While waiting for data, display the default "Vacant" container
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              if (snapshot.hasError) {
                                // Handle errors
                                return _buildContainer(
                                    'Error', Colors.red, context);
                              }
                              // If there are no documents or the document doesn't exist, display the default "Vacant" container
                              if (snapshot.data == null ||
                                  snapshot.data!.docs.isEmpty) {
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              // If document exists, extract the name and display it
                              String name = '';
                              double price = 0.0;
                              String UID = "";
                              if (snapshot.hasData) {
                                UID = snapshot.data!.docs[0].get('UID') ?? '';
                                price =
                                    snapshot.data!.docs[0].get('Price') ?? '';
                                log("Ito yung current UID: " + currentUID);
                                return UID != currentUID
                                    ? StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'userName_email_sign_in')
                                            .doc(UID)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // While waiting for data, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (!snapshot.hasData) {
                                            // If there is no data or the document doesn't exist, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (snapshot.hasData) {
                                            name = snapshot.data!.get('Name') ??
                                                '';
                                            log("Ito yung gumagamit ng Cash Container B: " +
                                                name);
                                          }

                                          return _buildContainer(
                                              name.isNotEmpty ? name : 'Vacant',
                                              name.isNotEmpty
                                                  ? Colors.red
                                                  : Colors.green,
                                              context);
                                        },
                                      )
                                    : _buildCurrentUIDContainer(
                                        price, Color(0xFF191970), context);
                              }
                              return _buildContainer(
                                  name.isNotEmpty ? name : 'Vacant',
                                  name.isNotEmpty ? Colors.red : Colors.green,
                                  context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          height: 30.0,
                          width: 70.0,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('parcels')
                                .where("Cash Container",
                                    isEqualTo: "Cash Container C")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While waiting for data, display the default "Vacant" container
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              if (snapshot.hasError) {
                                // Handle errors
                                return _buildContainer(
                                    'Error', Colors.red, context);
                              }
                              // If there are no documents or the document doesn't exist, display the default "Vacant" container
                              if (snapshot.data == null ||
                                  snapshot.data!.docs.isEmpty) {
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              // If document exists, extract the name and display it
                              String name = '';
                              double price = 0.0;
                              String UID = "";
                              if (snapshot.hasData) {
                                UID = snapshot.data!.docs[0].get('UID') ?? '';
                                price =
                                    snapshot.data!.docs[0].get('Price') ?? '';
                                log("Ito yung current UID: " + currentUID);
                                return UID != currentUID
                                    ? StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'userName_email_sign_in')
                                            .doc(UID)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // While waiting for data, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data == null) {
                                            // If there is no data or the document doesn't exist, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (snapshot.hasData) {
                                            name = snapshot.data!.get('Name') ??
                                                '';
                                            log("Ito yung gumagamit ng Cash Container C: " +
                                                name);
                                          }

                                          return _buildContainer(
                                              name.isNotEmpty ? name : 'Vacant',
                                              name.isNotEmpty
                                                  ? Colors.red
                                                  : Colors.green,
                                              context);
                                        },
                                      )
                                    : _buildCurrentUIDContainer(
                                        price, Color(0xFF191970), context);
                              }
                              return _buildContainer(
                                  name.isNotEmpty ? name : 'Vacant',
                                  name.isNotEmpty ? Colors.red : Colors.green,
                                  context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          height: 30.0,
                          width: 70.0,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('parcels')
                                .where("Cash Container",
                                    isEqualTo: "Cash Container D")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While waiting for data, display the default "Vacant" container
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              if (snapshot.hasError) {
                                // Handle errors
                                return _buildContainer(
                                    'Error', Colors.red, context);
                              }
                              // If there are no documents or the document doesn't exist, display the default "Vacant" container
                              if (snapshot.data == null ||
                                  snapshot.data!.docs.isEmpty) {
                                return _buildContainer(
                                    'Vacant', Colors.green, context);
                              }
                              // If document exists, extract the name and display it
                              String name = '';
                              double price = 0.0;
                              String UID = "";
                              if (snapshot.hasData) {
                                UID = snapshot.data!.docs[0].get('UID') ?? '';
                                price =
                                    snapshot.data!.docs[0].get('Price') ?? '';
                                log("Ito yung current UID: " + currentUID);
                                return UID != currentUID
                                    ? StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'userName_email_sign_in')
                                            .doc(UID)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // While waiting for data, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data == null) {
                                            // If there is no data or the document doesn't exist, display the default "Vacant" container
                                            return _buildContainer('Vacant',
                                                Colors.green, context);
                                          }
                                          if (snapshot.hasData) {
                                            name = snapshot.data!.get('Name') ??
                                                '';
                                            log("Ito yung gumagamit ng Cash Container D: " +
                                                name);
                                          }

                                          return _buildContainer(
                                              name.isNotEmpty ? name : 'Vacant',
                                              name.isNotEmpty
                                                  ? Colors.red
                                                  : Colors.green,
                                              context);
                                        },
                                      )
                                    : _buildCurrentUIDContainer(
                                        price, Color(0xFF191970), context);
                              }
                              return _buildContainer(
                                  name.isNotEmpty ? name : 'Vacant',
                                  name.isNotEmpty ? Colors.red : Colors.green,
                                  context);
                            },
                          ),
                        ),
                        // Container(
                        //   height: 30.0,
                        //   width: 70.0,
                        //   child: StreamBuilder<QuerySnapshot>(
                        //     stream: FirebaseFirestore.instance
                        //         .collection('parcels')
                        //         .where("Cash Container",
                        //             isEqualTo: "Cash Container B")
                        //         .snapshots(),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         // While waiting for data, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       if (!snapshot.hasData) {
                        //         // If there is no data or the document doesn't exist, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       // If document exists, extract the name and display it
                        //       String name = '';
                        //       if (snapshot.hasData) {
                        //         name = snapshot.data!.get('Name') ?? '';
                        //       }
                        //       return _buildContainer(
                        //           name.isNotEmpty ? name : 'Vacant',
                        //           name.isNotEmpty
                        //               ? Colors.red
                        //               : Colors.green);
                        //     },
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Container(
                        //   height: 30.0,
                        //   width: 70.0,
                        //   child: StreamBuilder<QuerySnapshot>(
                        //     stream: FirebaseFirestore.instance
                        //         .collection('parcels')
                        //         .where("Cash Container",
                        //             isEqualTo: "Cash Container C")
                        //         .snapshots(),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         // While waiting for data, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       if (!snapshot.hasData) {
                        //         // If there is no data or the document doesn't exist, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       // If document exists, extract the name and display it
                        //       String name = '';
                        //       if (snapshot.hasData) {
                        //         name = snapshot.data!.get('Name') ?? '';
                        //       }
                        //       return _buildContainer(
                        //           name.isNotEmpty ? name : 'Vacant',
                        //           name.isNotEmpty
                        //               ? Colors.red
                        //               : Colors.green);
                        //     },
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Container(
                        //   height: 30.0,
                        //   width: 70.0,
                        //   child: StreamBuilder<QuerySnapshot>(
                        //     stream: FirebaseFirestore.instance
                        //         .collection('parcels')
                        //         .where("Cash Container",
                        //             isEqualTo: "Cash Container D")
                        //         .snapshots(),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         // While waiting for data, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       if (!snapshot.hasData) {
                        //         // If there is no data or the document doesn't exist, display the default "Vacant" container
                        //         return _buildContainer(
                        //             'Vacant', Colors.green);
                        //       }
                        //       // If document exists, extract the name and display it
                        //       String name = '';
                        //       if (snapshot.hasData) {
                        //         name = snapshot.data!.get('Name') ?? '';
                        //       }
                        //       return _buildContainer(
                        //           name.isNotEmpty ? name : 'Vacant',
                        //           name.isNotEmpty
                        //               ? Colors.red
                        //               : Colors.green);
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: CabinetWidget(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildContainer(String name, Color color, BuildContext context) {
  return Container(
    // height: MediaQuery.of(context).size.height * 0.1,
    // width: MediaQuery.of(context).size.width * 0.9,
    height: 30.0,
    width: 70.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          name.isNotEmpty ? Icons.person : Icons.person_outline,
          color: Colors.white,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width *
                0.0005), // Add spacing between icon and text
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis, // Handle text overflow
            maxLines: 1, // Limit to one line
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}

Widget _buildCurrentUIDContainer(
    double price, Color color, BuildContext context) {
  return Container(
    // height: MediaQuery.of(context).size.height * 0.1,
    // width: MediaQuery.of(context).size.width * 0.9,
    height: 30.0,
    width: 70.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person,
          color: Colors.white,
        ),
        Text(
          "₱ " + price.toString(),
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            color: Colors.white,
          ),
        ),
      ],
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}
