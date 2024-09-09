import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/pages/test_showpicture.dart';
import 'package:modernlogintute/trial/try_show_image.dart';

bool imageLoaded = false;
Widget buildDetailsRow(String label, String value, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01),
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

class AdminCODStoredDetails {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection("proofOfDelivery");
  final String productName;
  final String dateAdded;
  final String dateReceived;
  final double price;
  final String timeReceived;
  // final String imageUrl;
  final String trackingNumber;
  // final String cashContainer;
  AdminCODStoredDetails({
    required this.productName,
    required this.dateAdded,
    required this.dateReceived,
    required this.price,
    required this.trackingNumber,
    required this.timeReceived,
    // required this.cashContainer,
  });
  showAdminCODStoredDetails(
    BuildContext context,
    String productName,
    String dateAdded,
    String dateReceived,
    String timeReceived,
    double price,
    String trackingNumber,
    // String cashContainer,
  ) {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text(
    //         "Transaction Details",
    //         style: GoogleFonts.ubuntu(
    //           fontSize: 20.0,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       content: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           // Text(
    //           //   "Name: ${productName}\nPrice: ${price}\nTime Added: ${dateAdded}\nTime Received: ${dateReceived}",
    //           // ),
    //           Text(
    //             "Name: ${productName}",
    //           ),
    //           Text(
    //             "Price: ${price}",
    //           ),
    //           Text(
    //             "Time Added: ${dateAdded}",
    //           ),
    //           Text(
    //             "Time Received: ${dateReceived}",
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define the color for the circular background
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
                // padding: EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.0,
                    color: Colors.white, // Set the color of the "X" button
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
              buildDetailsRow("Name:", productName, context),
              SizedBox(height: 5.0),
              buildDetailsRow("Price:", "₱ " + price.toString(), context),
              SizedBox(height: 5.0),
              buildDetailsRow("Date Added:", dateAdded, context),
              SizedBox(height: 5.0),
              buildDetailsRow("Date Received:", dateReceived, context),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    log("The document tracking number: " + trackingNumber);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Define the color for the circular background
                        Color circularBackgroundColor = Color(0xFF191970);

                        return FutureBuilder<DocumentSnapshot>(
                          future: _reference.doc(trackingNumber.trim()).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text(
                                    "Failed to fetch data from Firestore."),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                !snapshot.data!.exists) {
                              return AlertDialog(
                                title: Text("Error"),
                                content:
                                    Text("Document not found in Firestore."),
                              );
                            }

                            var data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            if (data != null && data.containsKey("ParcelPic")) {
                              String imageUrl = data["ParcelPic"];
                              log("The image URL is: $imageUrl");

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
                                              ImageChunkEvent?
                                                  loadingProgress) {
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
                            } else {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text(
                                    "ParcelPic field not found or is null in Firestore document."),
                              );
                            }
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
