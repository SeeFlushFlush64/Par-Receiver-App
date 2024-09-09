import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modernlogintute/components/barcodeScanner.dart';
import 'package:modernlogintute/components/occupiedOrNot.dart';
import 'package:modernlogintute/count%20page/cash_container_status.dart';
import 'package:modernlogintute/pages/cabinetwidget.dart';
import 'package:modernlogintute/pages/register_page.dart';
import 'package:modernlogintute/pages/shelfwidget.dart';
import 'package:modernlogintute/services/auth_services.dart';
import 'package:modernlogintute/userTabs/received_details.dart';
import 'package:modernlogintute/userTabs/terminated_details.dart';
import 'package:modernlogintute/userTabs/transactions.dart';
import 'package:modernlogintute/userTabs/userName_email_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Home extends StatefulWidget {
  final PersistentTabController controller;
  Home({super.key, required this.controller});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  int codCount = 0; // Variable to store COD count
  int nonCodCount = 0; // Variable to store non-COD count
  double totalPrice = 0.0;
  bool showTotalPrice = true; // Variable to toggle visibility
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("proofOfDelivery");

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
  }

  Future<void> markAsRead(String collection, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .update({'Unread': false});
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<String?> getTrackingID(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('received')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        String? trackingID = documentSnapshot.get('Tracking ID');
        return trackingID;
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error retrieving document: $e");
      return null;
    }
  }

  String formatTimeDifference(String dateReceived, String timeReceived) {
    final now = DateTime.now();
    final receivedDateTime =
        DateFormat("MMMM dd, yyyy HH:mm").parse("$dateReceived $timeReceived");
    final difference = now.difference(receivedDateTime);

    if (difference.inMinutes < 1) {
      return "Just Now";
    } else if (difference.inMinutes == 1) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inMinutes > 1 && difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours == 1) {
      return "${difference.inHours} hr ago";
    } else if (difference.inHours > 1 && difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else if (difference.inDays == 1) {
      return "Yesterday at ${DateFormat.Hm().format(receivedDateTime)}";
    } else if (difference.inDays > 1 && difference.inDays < 7) {
      return "${difference.inDays} days ago, ${DateFormat.Hm().format(receivedDateTime)}";
    } else {
      return DateFormat.yMMMd()
          .add_Hm()
          .format(receivedDateTime); // e.g., "Mar 21, 16:54"
    }
  }

  Stream<ReceivedDetails?> getMostRecentReceivedDocument(String currentUID) {
    return FirebaseFirestore.instance
        .collection('received')
        .orderBy('Date Received', descending: true)
        .snapshots()
        .map((querySnapshot) {
      DateFormat dateFormat =
          DateFormat('MMMM dd, yyyy', 'en_US'); // Set locale to US English
      Timestamp? mostRecentTimestamp;
      ReceivedDetails? mostRecentDocument;

      for (var doc in querySnapshot.docs) {
        if (doc['UID'] == currentUID) {
          var dateReceived = doc['Date Received'];

          // Convert string date to Timestamp if necessary
          Timestamp? timestamp;
          if (dateReceived is String) {
            try {
              dateReceived = dateReceived.trim(); // Trim any whitespace
              DateTime dateTime = dateFormat.parse(dateReceived);
              timestamp = Timestamp.fromDate(dateTime);
            } catch (e) {
              print('Error parsing date: "$dateReceived" - ${e.toString()}');
              continue;
            }
          } else if (dateReceived is Timestamp) {
            timestamp = dateReceived;
          }

          // Update most recent document if this one is more recent
          if (timestamp != null &&
              (mostRecentTimestamp == null ||
                  timestamp.compareTo(mostRecentTimestamp) > 0)) {
            mostRecentTimestamp = timestamp;
            mostRecentDocument =
                ReceivedDetails.fromJson(doc.data() as Map<String, dynamic>);
          }
        }
      }
      return mostRecentDocument;
    });
  }

  Stream<TerminatedDetails?> getMostRecentTerminatedDocument(
      String currentUID) {
    return FirebaseFirestore.instance
        .collection('terminated')
        .orderBy('Date', descending: true)
        .snapshots()
        .map((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['UID'] == currentUID) {
          return TerminatedDetails.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    });
  }

  @override
  void initState() {
    super.initState();

    inputData();
    fetchCODData();
    fetchNonCODData();
  }

  void googleAddUser() async {
    UserNameEmailSignIn userNameEmailSignIn = UserNameEmailSignIn(
      name: user.displayName!,
      uid: user.uid,
      codLimits: 4,
      nonCodLimits: 8,
      signInWith: "Google",
    );
    final userNameEmailSignInRef = FirebaseFirestore.instance
        .collection('userName_email_sign_in')
        .doc(currentUID);
    userNameEmailSignIn.id = userNameEmailSignInRef.id;
    final userName = userNameEmailSignIn.toJson();
    await userNameEmailSignInRef.set(userName).whenComplete(() => null);
  }

  void fetchCODData() {
    FirebaseFirestore.instance
        .collection("parcels")
        .where("UID", isEqualTo: currentUID)
        .where("Mode of Payment", isEqualTo: "Cash on Delivery")
        .get()
        .then((snapshot) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          codCount = snapshot.docs.length;
        });
      });
    }).catchError((error) {
      print('Error getting COD count: $error');
    });
  }

  void fetchNonCODData() {
    FirebaseFirestore.instance
        .collection("parcels")
        .where("UID", isEqualTo: currentUID)
        .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
        .get()
        .then((snapshot) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          nonCodCount = snapshot.docs.length;
        });
      });
    }).catchError((error) {
      print('Error getting Non-COD count: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    googleAddUser();
    // fetchCODData();
    // fetchNonCODData();
    return SafeArea(
      child: Scaffold(
        drawer: Navbar(),
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Container(
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 30.0,
                    color: Color(0xFF191970),
                    onPressed: signUserOut,
                    icon: Icon(Icons.logout_outlined),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(right: 15.0),
            //   child: Container(
            //     child: Align(
            //       alignment: Alignment.center,
            //       child: GestureDetector(
            //         onTap: () {
            //           // Handle the onTap event (e.g., trigger Google Sign In)
            //           // You can add your Google Sign In logic here
            //           // Example: signInWithGoogle();
            //           CircularProgressIndicator();
            //           AuthService().signInWithGoogle();
            //         },
            //         child: CircleAvatar(
            //           radius: 15.0,
            //           backgroundImage: NetworkImage(
            //             // Replace with the URL of your profile picture
            //             '${user.photoURL}',
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
          // title: Text("Par-Receiver"),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade50,
          titleTextStyle: GoogleFonts.ubuntu(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF191970),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 25.0,
                    ),
                    Text(
                      "Welcome back!",
                      // "Welcome, ${user.displayName!.split(' ')[0]}",
                      style: GoogleFonts.ubuntu(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // SizedBox(
                //   height: MediaQuery.sizeOf(context).height * .14,
                //   width: MediaQuery.sizeOf(context).width * .90,
                //   child: Card(
                //     color: Color(0xFF191970),
                //     child: ListTile(
                //       subtitle: StreamBuilder<double>(
                //         stream: calculateTotalPriceStream(currentUID),
                //         builder: (context, snapshot) {
                //           if (snapshot.connectionState ==
                //               ConnectionState.waiting) {
                //             return CircularProgressIndicator();
                //           } else if (!snapshot.hasData) {
                //             return Text(
                //               "₱ 0.00",
                //               style: GoogleFonts.ubuntu(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize:
                //                     MediaQuery.of(context).size.height * 0.03,
                //                 color: Colors.white,
                //               ),
                //             );
                //           } else {
                //             double totalPrice = snapshot.data ?? 0.0;
                //             String totalPriceString = showTotalPrice
                //                 ? totalPrice.toStringAsFixed(2)
                //                 : '*' * totalPrice.toStringAsFixed(2).length;

                //             return Text(
                //               '₱ $totalPriceString',
                //               style: GoogleFonts.ubuntu(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize:
                //                     MediaQuery.of(context).size.height * 0.03,
                //                 color: Colors.white,
                //               ),
                //             );
                //           }
                //         },
                //       ),
                //       title: SingleChildScrollView(
                //         scrollDirection: Axis.horizontal,
                //         child: Row(
                //           children: [
                //             Text(
                //               'Par-Receiver\nCash Balance',
                //               style: GoogleFonts.ubuntu(
                //                 fontSize:
                //                     MediaQuery.of(context).size.height * 0.015,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.white,
                //               ),
                //             ),
                //             IconButton(
                //               icon: Icon(
                //                 showTotalPrice
                //                     ? Icons.visibility
                //                     : Icons.visibility_off,
                //                 color: Colors.white,
                //               ),
                //               onPressed: () {
                //                 setState(() {
                //                   showTotalPrice = !showTotalPrice;
                //                 });
                //               },
                //             ),
                //           ],
                //         ),
                //       ),
                //       trailing: SizedBox(
                //         height: MediaQuery.of(context).size.height * 0.3,
                //         width: MediaQuery.of(context).size.width * 0.3,
                //         child: AspectRatio(
                //             aspectRatio: 1.0,
                //             child:
                //                 Lottie.asset('lib/images/shopping_cart.json')),
                //       ),
                //       // trailing: Image.asset('lib/images/par_receiver_logo.png',
                //       //     height: 200.0, width: 120.0),
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .159,
                  width: MediaQuery.sizeOf(context).width * .90,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Par-Receiver\nYour Cash Balance',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          showTotalPrice
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showTotalPrice = !showTotalPrice;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ListTile(
                                    subtitle: StreamBuilder<double>(
                                      stream:
                                          calculateTotalPriceStream(currentUID),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (!snapshot.hasData) {
                                          return Text(
                                            showTotalPrice
                                                ? "PHP 0.00"
                                                : "PHP *****",
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.03,
                                              color: Colors.white,
                                            ),
                                          );
                                        } else {
                                          double totalPrice =
                                              snapshot.data ?? 0.0;
                                          String totalPriceString =
                                              showTotalPrice
                                                  ? totalPrice
                                                      .toStringAsFixed(2)
                                                  : '*****';

                                          return Text(
                                            'PHP $totalPriceString',
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.03,
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Lottie.asset(
                            'lib/images/shopping_cart.json',
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * .08,
                      width: MediaQuery.sizeOf(context).width * .45,
                      child: Card(
                        child: ListTile(
                          leading: codCount == 0
                              ? Text(
                                  "0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    color: Color(0xFF191970),
                                  ),
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("parcels")
                                      .where("UID", isEqualTo: currentUID)
                                      .where("Mode of Payment",
                                          isEqualTo: "Cash on Delivery")
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      print(
                                          'Error getting COD count: ${snapshot.error}');
                                      return Text('Error getting COD count');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Placeholder widget while loading
                                    }

                                    // Process the data
                                    final codCount =
                                        snapshot.data?.docs.length ?? 0;

                                    // Update your UI accordingly
                                    return Text(
                                      '${codCount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Color(0xFF191970),
                                      ),
                                    );
                                  },
                                ),
                          title: Text(
                            "Pending COD",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191970),
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).height * .08,
                      width: MediaQuery.sizeOf(context).width * .45,
                      child: Card(
                        child: ListTile(
                          leading: nonCodCount == 0
                              // ? CircularProgressIndicator()
                              ? Text(
                                  "0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    color: Color(0xFF191970),
                                  ),
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("parcels")
                                      .where("UID", isEqualTo: currentUID)
                                      .where("Mode of Payment",
                                          isEqualTo: "Non-Cash on Delivery")
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      print(
                                          'Error getting Non-COD count: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Placeholder widget while loading
                                    }

                                    // Process the data
                                    final nonCodCount =
                                        snapshot.data?.docs.length ?? 0;

                                    // Update your UI accordingly
                                    return Text(
                                      '${nonCodCount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Color(0xFF191970),
                                      ),
                                    );
                                  },
                                ),
                          title: Text(
                            "Pending Non-COD",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191970),
                              fontSize: 13.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.025,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.06),
                  child: Row(
                    children: [
                      Text(
                        'Machine Status',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.023,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // CashContainerStatus(),
                InkWell(
                  onTap: () {
                    // Handle onTap event
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('machine_status')
                                  .doc('Internet Connectivity')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Text(
                                    'Error: Document does not exist',
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  );
                                }

                                bool isOnline =
                                    snapshot.data!['Online'] ?? false;
                                String imagePath = isOnline
                                    ? 'lib/images/green_light.png'
                                    : 'lib/images/red_light.png';

                                return Image.asset(
                                  imagePath,
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                );
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('machine_status')
                                  .doc('Internet Connectivity')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Text(
                                    'Error: Document does not exist',
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  );
                                }

                                bool isOnline =
                                    snapshot.data!['Online'] ?? false;
                                String connectivityStatus = isOnline
                                    ? 'Par-Receiver is online'
                                    : 'Par-Receiver is offline';

                                return Text(
                                  connectivityStatus,
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Handle onTap event
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CashContainerStatus(),
                                StreamBuilder<int>(
                                  stream: FirebaseFirestore.instance
                                      .collection('parcels')
                                      .where('Cash Container', whereIn: [
                                        'Cash Container A',
                                        'Cash Container B',
                                        'Cash Container C',
                                        'Cash Container D'
                                      ])
                                      .snapshots()
                                      .map((snapshot) => snapshot.docs.length),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    int count = snapshot.data ?? 0;
                                    String message;
                                    switch (count) {
                                      case 0:
                                        message =
                                            'All cash containers are available';
                                        break;
                                      case 1:
                                        message = '3 cash containers available';
                                        break;
                                      case 2:
                                        message = '2 cash containers available';
                                        break;
                                      case 3:
                                        message = '1 cash container available';
                                        break;
                                      case 4:
                                        message =
                                            'No cash container available. COD registration is temporarily unavailable';
                                        break;
                                      default:
                                        message =
                                            'Error determining cash container status';
                                    }

                                    return Text(
                                      message,
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.sizeOf(context).height *
                                                0.0125,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.06),
                  child: Row(
                    children: [
                      Text(
                        'Recently Received',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     widget.controller.jumpToTab(1); // Navigate to the About tab
                //   },
                //   child: Text('Go to About'),
                // ),

                InkWell(
                  onTap: () async {
                    final mostRecentDoc =
                        await getMostRecentReceivedDocument(currentUID).first;
                    if (mostRecentDoc != null && mostRecentDoc.unread == true) {
                      await markAsRead('received', mostRecentDoc.trackingId);
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.sizeOf(context).height * 0.40,
                            width: MediaQuery.sizeOf(context).width,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.sizeOf(context).height * 0.02),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.005,
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.1,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.015,
                                      ),
                                      Text(
                                        "Parcel Track #: ${mostRecentDoc.trackingId}",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.02,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child:
                                                FutureBuilder<DocumentSnapshot>(
                                              future: _reference
                                                  .doc(mostRecentDoc.trackingId)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                if (snapshot.hasError ||
                                                    !snapshot.hasData ||
                                                    snapshot.data == null ||
                                                    !snapshot.data!.exists) {
                                                  // return AlertDialog(
                                                  //   title: Text("ERROR"),
                                                  //   content: Text(
                                                  //       "Proof of Delivery not available"),
                                                  // );
                                                  return Container();
                                                }

                                                var data = snapshot.data!.data()
                                                    as Map<String, dynamic>?;
                                                if (data != null &&
                                                    data.containsKey(
                                                        "ParcelPic")) {
                                                  String imageUrl =
                                                      data["ParcelPic"];
                                                  log("The image URL is: $imageUrl");
                                                  return Transform.rotate(
                                                    angle:
                                                        3.14159, // 180 degrees in radians
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.40, // Desired width
                                                      height:
                                                          200.0, // Desired height
                                                      loadingBuilder: (BuildContext
                                                              context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        } else {
                                                          return Column(
                                                            children: [
                                                              CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        (loadingProgress.expectedTotalBytes ??
                                                                            1)
                                                                    : null,
                                                              ),
                                                              SizedBox(
                                                                  height: 8.0),
                                                              Text(
                                                                "Loading, please wait.",
                                                                style:
                                                                    GoogleFonts
                                                                        .ubuntu(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.045,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03,
                                                ),
                                                child: Text(
                                                  "Product: ${mostRecentDoc.productName}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontSize: MediaQuery.sizeOf(
                                                                context)
                                                            .height *
                                                        0.015,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.01,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03,
                                                ),
                                                child: mostRecentDoc
                                                            .modeOfPayment ==
                                                        "Cash on Delivery"
                                                    ? Text(
                                                        "Mode of Payment: COD",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                          fontSize:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : Text(
                                                        "Mode of Payment: Non-COD",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                          fontSize:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.01,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03,
                                                ),
                                                child: mostRecentDoc
                                                            .modeOfPayment ==
                                                        "Cash on Delivery"
                                                    ? Text(
                                                        "Price: ₱ ${mostRecentDoc.price}",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                          fontSize:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : Container(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                      widget.controller.jumpToTab(
                                          3); // Navigate to the Transactions tab
                                    },
                                    child: Text(
                                      'See More Transactions',
                                      style: GoogleFonts.ubuntu(
                                        fontSize:
                                            MediaQuery.sizeOf(context).height *
                                                0.015,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFF191970),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "All set",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              "No parcels received at the moment",
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * .08,
                    width: MediaQuery.sizeOf(context).width * .9,
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder<ReceivedDetails?>(
                              stream: getMostRecentReceivedDocument(currentUID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Container(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: MediaQuery.sizeOf(context).height *
                                          0.05,
                                    ),
                                  );
                                } else {
                                  ReceivedDetails mostRecentDoc =
                                      snapshot.data!;

                                  // log(mostRecentDoc.timeReceived);
                                  String formattedTime = formatTimeDifference(
                                      mostRecentDoc.dateReceived,
                                      mostRecentDoc.timeReceived);

                                  // log(formattedTime);
                                  return mostRecentDoc.unread == true
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          child: Text(
                                            formattedTime,
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          // child: Lottie.asset(
                                          //     'lib/images/shopping_cart.json',
                                          //     height: MediaQuery.of(context)
                                          //             .size
                                          //             .height *
                                          //         0.09),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.05,
                                          ),
                                        );
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<ReceivedDetails?>(
                                  stream:
                                      getMostRecentReceivedDocument(currentUID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Text(
                                        'No parcels received recently',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ),
                                      );
                                    } else {
                                      ReceivedDetails mostRecentDoc =
                                          snapshot.data!;
                                      return mostRecentDoc.unread == true
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Product Name: ${mostRecentDoc.productName}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Mode of Payment: ${mostRecentDoc.modeOfPayment}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'No parcels received recently',
                                              style: GoogleFonts.ubuntu(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12.0,
                                              ),
                                            );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.06),
                  child: Row(
                    children: [
                      Text(
                        'Recently Terminated',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                InkWell(
                  onTap: () async {
                    final mostRecentTerminatedDoc =
                        await getMostRecentTerminatedDocument(currentUID).first;
                    if (mostRecentTerminatedDoc != null &&
                        mostRecentTerminatedDoc.unread == true) {
                      await markAsRead('terminated', mostRecentTerminatedDoc.trackingId);
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.sizeOf(context).height * 0.40,
                            width: MediaQuery.sizeOf(context).width,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.sizeOf(context).height * 0.02),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.005,
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.1,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.015,
                                      ),
                                      Text(
                                        "Parcel Track #: ${mostRecentTerminatedDoc!.trackingId}",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.02,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child:
                                                FutureBuilder<DocumentSnapshot>(
                                              future: _reference
                                                  .doc(mostRecentTerminatedDoc
                                                      .trackingId)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                if (snapshot.hasError ||
                                                    !snapshot.hasData ||
                                                    snapshot.data == null ||
                                                    !snapshot.data!.exists) {
                                                  // return AlertDialog(
                                                  //   title: Text("ERROR"),
                                                  //   content: Text(
                                                  //       "Proof of Delivery not available"),
                                                  // );
                                                  return Container();
                                                }

                                                var data = snapshot.data!.data()
                                                    as Map<String, dynamic>?;
                                                if (data != null &&
                                                    data.containsKey(
                                                        "ParcelPic")) {
                                                  String imageUrl =
                                                      data["ParcelPic"];
                                                  log("The image URL is: $imageUrl");
                                                  return Transform.rotate(
                                                    angle:
                                                        3.14159, // 180 degrees in radians
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.40, // Desired width
                                                      height:
                                                          200.0, // Desired height
                                                      loadingBuilder: (BuildContext
                                                              context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        } else {
                                                          return Column(
                                                            children: [
                                                              CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        (loadingProgress.expectedTotalBytes ??
                                                                            1)
                                                                    : null,
                                                              ),
                                                              SizedBox(
                                                                  height: 8.0),
                                                              Text(
                                                                "Loading, please wait.",
                                                                style:
                                                                    GoogleFonts
                                                                        .ubuntu(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.045,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03,
                                                ),
                                                child: Text(
                                                  "Product: ${mostRecentTerminatedDoc.productName}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontSize: MediaQuery.sizeOf(
                                                                context)
                                                            .height *
                                                        0.015,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.01,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03,
                                                ),
                                                child: mostRecentTerminatedDoc
                                                            .modeOfPayment ==
                                                        "Cash on Delivery"
                                                    ? Text(
                                                        "Mode of Payment: COD",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                          fontSize:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : Text(
                                                        "Mode of Payment: Non-COD",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                          fontSize:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.01,
                                              ),
                                              // Padding(
                                              //   padding: EdgeInsets.symmetric(
                                              //     horizontal:
                                              //         MediaQuery.sizeOf(context)
                                              //                 .width *
                                              //             0.03,
                                              //   ),
                                              //   child: mostRecentDoc
                                              //               .modeOfPayment ==
                                              //           "Cash on Delivery"
                                              //       ? Text(
                                              //           "Price: ₱ ${mostRecentDoc.price}",
                                              //           style:
                                              //               GoogleFonts.ubuntu(
                                              //             fontSize:
                                              //                 MediaQuery.sizeOf(
                                              //                             context)
                                              //                         .height *
                                              //                     0.015,
                                              //             fontWeight:
                                              //                 FontWeight.bold,
                                              //           ),
                                              //         )
                                              //       : Container(),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                      widget.controller.jumpToTab(
                                          3); // Navigate to the Transactions tab
                                    },
                                    child: Text(
                                      'See More Transactions',
                                      style: GoogleFonts.ubuntu(
                                        fontSize:
                                            MediaQuery.sizeOf(context).height *
                                                0.015,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFF191970),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "All set",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              "No transaction terminated recently",
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * .08,
                    width: MediaQuery.sizeOf(context).width * .9,
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder<TerminatedDetails?>(
                              stream:
                                  getMostRecentTerminatedDocument(currentUID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Container(
                                    // color: Colors.red,
                                    // child: Lottie.asset(
                                    //     'lib/images/success_icon.json',
                                    //     height:
                                    //         MediaQuery.of(context).size.height *
                                    //             0.09),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: MediaQuery.sizeOf(context).height *
                                          0.05,
                                    ),
                                  );
                                } else {
                                  TerminatedDetails mostRecentDoc =
                                      snapshot.data!;

                                  // log(mostRecentDoc.timeReceived);
                                  String formattedTime = formatTimeDifference(
                                      mostRecentDoc.date, mostRecentDoc.time);

                                  // log(formattedTime);
                                  return mostRecentDoc.unread == true
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          child: Text(
                                            formattedTime,
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          // child: Lottie.asset(
                                          //     'lib/images/success_icon.json',
                                          //     height: MediaQuery.of(context)
                                          //             .size
                                          //             .height *
                                          //         0.09),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.05,
                                          ),
                                        );
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<TerminatedDetails?>(
                                  stream: getMostRecentTerminatedDocument(
                                      currentUID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Text(
                                        'No transaction terminated recently',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ),
                                      );
                                    } else {
                                      TerminatedDetails mostRecentDoc =
                                          snapshot.data!;
                                      return mostRecentDoc.unread == true
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Product Name: ${mostRecentDoc.productName}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Mode of Payment: ${mostRecentDoc.modeOfPayment}",
                                                  style: GoogleFonts.ubuntu(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'No transaction terminated recently',
                                              style: GoogleFonts.ubuntu(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 12.0,
                                              ),
                                            );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUserOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Logout",
            textAlign: TextAlign.center,
            style:
                GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to sign out?",
            textAlign: TextAlign.justify,
            style: GoogleFonts.ubuntu(
                fontSize: 14.0, fontWeight: FontWeight.normal),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close the dialog

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Account successfully logged out",
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  Stream<double> calculateTotalPriceStream(String currentUID) {
    return FirebaseFirestore.instance
        .collection("parcels")
        .where("UID", isEqualTo: currentUID)
        .snapshots()
        .map(
      (QuerySnapshot<Object?> snapshot) {
        List<double> prices = [];

        // Iterate through the documents and add the "Price" values to the list
        snapshot.docs.forEach((document) {
          var price = document['Price'] ?? 0.0; // Handle null values
          prices.add(price);
        });

        // Calculate the total value
        return prices.reduce((value, element) => value + element);
      },
    );
  }
}

Widget _buildContainer(String name, Color color, BuildContext context) {
  return Container(
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
        SizedBox(width: 4.0), // Adding some space between the icon and text
        Expanded(
          child: Text(
            "₱${price.toString()}",
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
