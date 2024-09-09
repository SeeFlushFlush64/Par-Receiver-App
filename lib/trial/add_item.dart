import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';

class AddItem extends StatefulWidget {
  final String trackingNumber;
  final String productName;
  final String monthName;
  final String cashContainer;
  final String day;
  final String time;
  const AddItem({
    Key? key,
    required this.trackingNumber,
    required this.productName,
    required this.monthName,
    required this.day,
    required this.time,
    required this.cashContainer,
  }) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  // TextEditingController _controllerName = TextEditingController();
  // TextEditingController _controllerQuantity = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('proofOfDeposit');

  String imageUrl = '';
  void showUploadSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Creating upload link for your image',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ADD CASH PAYMENT',
          style: GoogleFonts.ubuntu(
            color: Color(0xFF191970),
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TextFormField(
                  //   controller: _controllerName,
                  //   decoration:
                  //       InputDecoration(hintText: 'Enter the name of the item'),
                  //   validator: (String? value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter the item name';
                  //     }

                  //     return null;
                  //   },
                  // ),
                  // TextFormField(
                  //   controller: _controllerQuantity,
                  //   decoration:
                  //       InputDecoration(hintText: 'Enter the quantity of the item'),
                  //   validator: (String? value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter the item quantity';
                  //     }

                  //     return null;
                  //   },
                  // ),
                  Container(
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Image.asset('lib/images/file.png'),
                          ),
                          Flexible(
                            flex: 10,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              child: Text(
                                "Kindly open the cash container where the payment will be placed. Upon opening, kindly do the following procedure:",
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Image.asset('lib/images/deliver.png'),
                          ),
                          Flexible(
                            flex: 10,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 8.0, 8.0, 8.0),
                                child: Text(
                                  "NOTE: Kindly use the blue tray for rider's convenience.",
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                      child: Text(
                        "a) Put the fixed cash inside.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                      child: Text(
                        "b) Take a picture as a proof of cash deposit.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                      child: Text(
                        "c) Ensure the green light is off before closing the container.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: Text(
                        "d) Pull the door to check if properly closed before leaving.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () async {
                      /*
                    * Step 1. Pick/Capture an image   (image_picker)
                    * Step 2. Upload the image to Firebase storage
                    * Step 3. Get the URL of the uploaded image
                    * Step 4. Store the image URL inside the corresponding
                    *         document of the database.
                    * Step 5. Display the image on the list
                    *
                    * */

                      /*Step 1:Pick image*/
                      //Install image_picker
                      //Import the corresponding library

                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.camera);
                      print('${file?.path}');

                      if (file == null) return;
                      //Import dart:core
                      String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      /*Step 2: Upload to Firebase storage*/
                      //Install firebase_storage
                      //Import the library

                      //Get a reference to storage root
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                          referenceRoot.child('proofDeposit');

                      //Create a reference for the image to be stored
                      Reference referenceImageToUpload = referenceDirImages.child(
                          '<${widget.cashContainer}>${widget.productName}${widget.monthName}${widget.day}');

                      //Handle errors/success
                      try {
                        //Store the file
                        // if (imageUrl == '') {
                        //   showUploadSnackbar(context);
                        // }
                        // if (imageUrl.isEmpty) {
                        //   log("Wala pang image URL");

                        //   return;
                        // }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Creating upload link for your image. Please wait.',
                              style: GoogleFonts.ubuntu(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.yellow,
                          ),
                        );
                        await referenceImageToUpload.putFile(File(file.path));
                        //Success: get the download URL

                        imageUrl =
                            await referenceImageToUpload.getDownloadURL();
                        log(imageUrl);
                        log(widget.trackingNumber);

                        if (!(imageUrl.isEmpty)) {
                          log("Ito yung ImageURL: " + imageUrl);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You can now add the image as your proof',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          return;
                        }
                      } catch (error) {
                        //Some error occurred
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        color: Color(0xFF191970),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      // color: Color(0xFF191970),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Take a Picture",
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: () async {
                      if (imageUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please upload an image',
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        return;
                      }

                      if (key.currentState!.validate()) {
                        // String itemName = _controllerName.text;
                        // String itemQuantity = _controllerQuantity.text;
                        String customDocumentId = widget.trackingNumber;

                        //Create a Map of data
                        Map<String, String> dataToSend = {
                          // 'name': itemName,
                          // 'quantity': itemQuantity,
                          'image': imageUrl,
                        };

                        //Add a new item

                        _reference.doc(customDocumentId).set(dataToSend);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Image uploaded successfully',
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParcelTabs(),
                          ),
                        );
                        bool parcelAdded = true;

                        if (parcelAdded) {}
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF191970),
                          width: 2.0,
                        ),
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      // color: Color(0xFF191970),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF191970),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Submit",
                            style: GoogleFonts.ubuntu(
                              color: Color(0xFF191970),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Don't wanna take a picture?",
                    style: GoogleFonts.ubuntu(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParcelTabs(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Proof of Deposit skipped',
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      "Skip now",
                      style: GoogleFonts.ubuntu(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () async {

                  //   },
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width * 0.5,
                  //     height: MediaQuery.of(context).size.width * 0.1,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         color: Color(0xFF191970),
                  //         width: 2.0,
                  //       ),
                  //       // color: Colors.white,
                  //       borderRadius: BorderRadius.circular(15.0),
                  //     ),
                  //     // color: Color(0xFF191970),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(
                  //           Icons.check_circle_outline,
                  //           color: Color(0xFF191970),
                  //         ),
                  //         SizedBox(
                  //           width: 10.0,
                  //         ),
                  //         Text(
                  //           "Submit",
                  //           style: GoogleFonts.ubuntu(
                  //             color: Color(0xFF191970),
                  //             fontSize: 14.0,
                  //             fontWeight: FontWeight.w900,
                  //             letterSpacing: 2.0,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Container(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       foregroundColor: Color(0xFF191970),
                  //     ),
                  //     onPressed: () async {
                  //       if (imageUrl.isEmpty) {
                  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //             content: Text('Please upload an image')));

                  //         return;
                  //       }

                  //       if (key.currentState!.validate()) {
                  //         // String itemName = _controllerName.text;
                  //         // String itemQuantity = _controllerQuantity.text;
                  //         String customDocumentId = widget.trackingNumber;

                  //         //Create a Map of data
                  //         Map<String, String> dataToSend = {
                  //           // 'name': itemName,
                  //           // 'quantity': itemQuantity,
                  //           'image': imageUrl,
                  //         };

                  //         //Add a new item

                  //         _reference.doc(customDocumentId).set(dataToSend);
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             content: Text('Image uploaded successfully'),
                  //           ),
                  //         );
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => ParcelTabs(),
                  //           ),
                  //         );
                  //         bool parcelAdded = true;

                  //         if (parcelAdded) {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             SnackBar(
                  //               content: Text('Parcel added'),
                  //             ),
                  //           );
                  //         }
                  //       }
                  //     },
                  //     child: Text('Submit'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
