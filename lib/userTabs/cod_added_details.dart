import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool imageLoaded = false;

Widget buildDetailsRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 29), // Adjust the width as needed
        Text(
          value,
        ),
      ],
    ),
  );
}

class CODAddedDetails {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('proofOfDeposit');
  final String productName;
  final String dateAdded;
  final double price;
  final String timeAdded;
  final String trackingNumber;
  CODAddedDetails({
    required this.productName,
    required this.dateAdded,
    required this.timeAdded,
    required this.price,
    required this.trackingNumber,
  });

  showCODReceivedDetails(
    BuildContext context,
    String productName,
    String dateAdded,
    String timeAdded,
    double price,
    String trackingNumber,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color circularBackgroundColor = Color(0xFF191970);

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transaction Details",
                style: GoogleFonts.ubuntu(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circularBackgroundColor,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDetailsRow("Name:", productName),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.006),
              buildDetailsRow("Track #:", trackingNumber),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.006),
              buildDetailsRow("Price:", "₱ " + price.toString()),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.006),
              buildDetailsRow("Date Added:", dateAdded),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.006),
              buildDetailsRow("Time Added:", timeAdded),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.016),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        Color circularBackgroundColor = Color(0xFF191970);

                        return FutureBuilder<DocumentSnapshot>(
                          future: _reference.doc(trackingNumber).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                !snapshot.data!.exists) {
                              return AlertDialog(
                                title: Text(
                                  "No picture to display",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "You have skipped the Proof of Deposit",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            // Check if the 'image' field exists
                            var documentData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            if (!documentData.containsKey('image') ||
                                documentData['image'] == null ||
                                documentData['image'].isEmpty) {
                              return AlertDialog(
                                title: Text(
                                  "No picture to display",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "You have skipped the Proof of Deposit",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            String imageUrl = documentData['image'];
                            log("The document tracking number: " +
                                trackingNumber);
                            log("The image URL is: " + imageUrl);

                            return AlertDialog(
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.network(
                                        imageUrl,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Center(
                                              child: Column(
                                                children: [
                                                  CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    "Loading, please wait.",
                                                    style: GoogleFonts.ubuntu(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            12.0, 2.0, 2.0, 12.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: circularBackgroundColor,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20.0,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                    'Proof of Transaction',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: circularBackgroundColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
