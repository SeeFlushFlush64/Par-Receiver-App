import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modernlogintute/userTabs/add_CODparcels.dart';
import 'package:modernlogintute/userTabs/add_NON-CODparcels.dart';

class AdminScanToExtract extends StatefulWidget {
  const AdminScanToExtract({super.key});

  @override
  State<AdminScanToExtract> createState() => _AdminScanToExtractState();
}

class _AdminScanToExtractState extends State<AdminScanToExtract> {
  String extractedParcel = "";

  Future<void> handleFirestoreOperations(String barcodeText) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Get the document from the "received" collection
      DocumentSnapshot documentSnapshot =
          await firestore.collection('received').doc(barcodeText).get();

      if (documentSnapshot.exists) {
        // Ensure the document data is a Map<String, dynamic>
        final data = documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          // Create an identical document in the "extracted" collection
          await firestore.collection('extracted').doc(barcodeText).set(data);

          // Delete the document from the "received" collection
          await firestore.collection('received').doc(barcodeText).delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document transferred successfully.',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document data is not a Map<String, dynamic>.',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document not found in the received collection.',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> scanParcelBarcodeOrQR() async {
    String barcodeText;
    try {
      barcodeText = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
    } on PlatformException {
      barcodeText = "Failed to scan";
    }
    if (!mounted) return;
    setState(() {
      extractedParcel = barcodeText;
      log("Parcel scanned: " + extractedParcel);
    });

    // Show alert dialog
    if (barcodeText != "Failed to scan") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Scan Successful',
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                  fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Parcel scanned: $barcodeText',
              textAlign: TextAlign.start,
              style: GoogleFonts.ubuntu(
                  fontSize: 14.0, fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await handleFirestoreOperations(barcodeText);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("SCAN EXTRACTED PARCELS"),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container for the first image (COD) with rotated text
            SizedBox(
              height: 12.0,
            ),
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
                          "This process is crucial for the system to track how many parcels are still inside the machine, whenever a parcel is extracted.",
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
              height: 5.0,
            ),
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
                        padding: EdgeInsets.only(left: 6.0),
                        child: Image.asset(
                          'lib/images/parcels.png',
                          height: 80.0,
                          width: 70.0,
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
                          "Always check and fetch delivered parcels inside the Par-Receiver machine to avoid full storage warnings.",
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
            // SizedBox(
            //   height: 10.0,
            // ),
            // Container(
            //   child: Lottie.asset('lib/images/qrScanning.json',
            //       height: MediaQuery.sizeOf(context).height * 0.1),
            // ),
            // SizedBox(
            //   height: 10.0,
            // ),
            ElevatedButton(
              onPressed: () {
                scanParcelBarcodeOrQR();
              },
              child: Text(
                "Scan Parcel Barcode",
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
            ),
            // SizedBox(
            //   height: 20.0,
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     scanParcelQR();
            //   },
            //   child: Text(
            //     "Scan Parcel QR",
            //     style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
