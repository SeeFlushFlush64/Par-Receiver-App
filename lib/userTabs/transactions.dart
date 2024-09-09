import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'parcels_added.dart';
import 'parcels_received.dart';
import 'parcels_terminated.dart';

class Transactions extends StatefulWidget {
  final int initialTabIndex;

  const Transactions({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late int current;

  @override
  void initState() {
    super.initState();
    current = widget.initialTabIndex;
  }

  List<String> modeOfPayments = [
    "Added",
    "Received",
    "Terminated",
  ];

  Widget _getBody(current) {
    switch (current) {
      case 0:
        return ParcelsAdded();
      case 1:
        return ParcelsReceived();
      case 2:
        return ParcelsTerminated();
      default:
        return ParcelsAdded();
    }
  }

  double changePositionOfLine(current) {
    switch (current) {
      case 0:
        return MediaQuery.sizeOf(context).width * 0.09;
      case 1:
        return MediaQuery.sizeOf(context).width * 0.32;
      case 2:
        return MediaQuery.sizeOf(context).width * 0.61;
      default:
        return 40;
    }
  }

  double changeContainerWidth(current) {
    switch (current) {
      case 0:
        return MediaQuery.sizeOf(context).width * 0.2;
      case 1:
        return MediaQuery.sizeOf(context).width * 0.27;
      case 2:
        return MediaQuery.sizeOf(context).width * 0.28;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'TRANSACTIONS',
            style: GoogleFonts.ubuntu(
              color: Color(0xFF191970),
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey.shade50,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        height: size.height * 0.05,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                width: size.width,
                                height: size.height * 0.04,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(modeOfPayments.length,
                                      (index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          current = index;
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: index == 0
                                              ? MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.01
                                              : MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.055,
                                          right:
                                              index == modeOfPayments.length - 1
                                                  ? MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.01
                                                  : MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.08,
                                          top:
                                              MediaQuery.sizeOf(context).width *
                                                  0.008,
                                        ),
                                        child: Text(
                                          modeOfPayments[index],
                                          style: GoogleFonts.ubuntu(
                                            color: Color(0xFF191970),
                                            fontSize: current == index
                                                ? MediaQuery.sizeOf(context)
                                                        .height *
                                                    0.02
                                                : MediaQuery.sizeOf(context)
                                                        .height *
                                                    0.017,
                                            fontWeight: current == index
                                                ? FontWeight.bold
                                                : FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              bottom: 0,
                              left: changePositionOfLine(current),
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: Duration(milliseconds: 500),
                              child: AnimatedContainer(
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: changeContainerWidth(current),
                                height: size.height * 0.008,
                                duration: Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFF191970),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _getBody(current),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('machine_status')
                      .doc('Internet Connectivity')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text(
                        'Error: Document does not exist',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                      );
                    }

                    bool isOnline = snapshot.data!['Online'] ?? false;
                    String imagePath = isOnline
                        ? 'lib/images/green_light.png'
                        : 'lib/images/red_light.png';
                    String statusText = isOnline
                        ? 'Par-Receiver is online'
                        : 'Par-Receiver is offline';

                    return Row(
                      children: [
                        Image.asset(
                          imagePath,
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          statusText,
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
