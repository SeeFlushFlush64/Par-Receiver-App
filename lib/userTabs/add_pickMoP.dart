import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/add_CODparcels.dart';
import 'package:modernlogintute/userTabs/add_NON-CODparcels.dart';

class AddPickMoP extends StatefulWidget {
  const AddPickMoP({super.key});

  @override
  State<AddPickMoP> createState() => _AddPickMoPState();
}

class _AddPickMoPState extends State<AddPickMoP> {
  Future<int> _getCODCount() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('parcels')
        .where('Cash Container', whereIn: [
      'Cash Container A',
      'Cash Container B',
      'Cash Container C',
      'Cash Container D'
    ]).get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("MODE OF PAYMENT"),
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
            const SizedBox(
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
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Flexible(
                      flex: 10,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "This app depends on Firestore. It does not allow the renaming of documents (Tracking Number). Hence, if the Tracking Number of an added parcel is wrong, the user must delete it and recreate.",
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
            const SizedBox(
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
            SizedBox(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () async {
                int count = await _getCODCount();
                if (count == 4) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Warning",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          "No cash container available. COD registration temporarily unavailable.",
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.ubuntu(
                              fontSize: 14.0, fontWeight: FontWeight.normal),
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
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCODParcels(),
                    ),
                  );
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'lib/images/COD_background_1.jpg',
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      bottom: 40,
                      right: MediaQuery.of(context).size.width * 0.01,
                      child: Transform.rotate(
                        angle: 90 * 3.14159265 / 180,
                        child: Text(
                          'COD',
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNONCODParcels(),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'lib/images/NON-COD-background.jpg',
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.8,
                      bottom: 50,
                      child: Transform.rotate(
                        angle: -90 * 3.14159265 / 180,
                        child: Text(
                          'Non-COD',
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
    );
  }
}
