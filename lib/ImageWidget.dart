import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FirebaseImageWidget extends StatefulWidget {
  final String imageName;

  const FirebaseImageWidget({Key? key, required this.imageName})
      : super(key: key);

  @override
  _FirebaseImageWidgetState createState() => _FirebaseImageWidgetState();
}

class _FirebaseImageWidgetState extends State<FirebaseImageWidget> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Future<String> _imageFuture;

  @override
  void initState() {
    super.initState();
    // Fetch image URL when the widget is initialized
    _imageFuture = _getImageUrl();
  }

  Future<String> _getImageUrl() async {
    try {
      // Get download URL for the image
      var imageUrl = await _firebaseStorage
          .ref()
          .child("data/${widget.imageName}")
          .getDownloadURL();
      return imageUrl;
    } catch (e) {
      // Handle errors
      print("Error getting image URL: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading image');
        } else if (snapshot.data == "") {
          return Text('Image not found');
        } else {
          // Use PhotoViewGallery for zooming capabilities
          return PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(snapshot.data!),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageController: PageController(),
          );
        }
      },
    );
  }
}
