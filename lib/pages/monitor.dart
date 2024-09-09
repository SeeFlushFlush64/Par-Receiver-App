import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Monitor extends StatefulWidget {
  Monitor({super.key, required this.gcpChannel, required this.personalChannel});
  final WebSocketChannel gcpChannel;
  final WebSocketChannel personalChannel;
  @override
  State<Monitor> createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  final videoWidth = 640;
  final videoHeight = 480;

  double newVideoSizeHeight = 640;
  double newVideoSizeWidth = 480;

  bool isLandscape = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLandscape = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("MONITOR"),
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
      // body: OrientationBuilder(
      //   builder: (context, orientation) {
      //     var screenWidth = MediaQuery.of(context).size.width;
      //     var screenHeight = MediaQuery.of(context).size.height;

      //     if (orientation == Orientation.portrait) {
      //       isLandscape = false;

      //       newVideoSizeWidth =
      //           screenWidth > videoWidth ? videoWidth : screenWidth;
      //       newVideoSizeHeight = videoHeight * newVideoSizeWidth / videoWidth;
      //     } else {
      //       isLandscape = true;
      //       newVideoSizeHeight =
      //           screenHeight > videoHeight ? videoHeight : screenHeight;
      //       newVideoSizeWidth = videoWidth * newVideoSizeHeight / videoHeight;
      //     }
      //   }
      // )
      // body: OrientationBuilder(
      //   builder: (context, orientation) {
      //     var screenWidth = MediaQuery.of(context).size.width;
      //     var screenHeight = MediaQuery.of(context).size.height;

      //     if (orientation == Orientation.portrait) {
      //       isLandscape = false;
      //       newVideoSizeWidth =
      //           screenWidth > videoWidth ? videoWidth : screenWidth;
      //       newVideoSizeHeight = videoHeight * newVideoSizeWidth / videoWidth;
      //     } else {
      //       isLandscape = true;
      //       newVideoSizeHeight =
      //           screenHeight > videoHeight ? videoHeight : screenHeight;
      //       newVideoSizeWidth =
      //           videoWidth * newVideoSizeWidth / newVideoSizeHeight;
      //     }
      //   }
      // )
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: widget.gcpChannel.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    // child: CircularProgressIndicator(
                    //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    // ),
                    child: Text('Front Cam currently not available :('),
                  );
                } else {
                  return GestureZoomBox(
                    maxScale: 5.0,
                    doubleTapScale: 2.0,
                    duration: Duration(milliseconds: 200),
                    child: Image.memory(
                      snapshot.data,
                      gaplessPlayback: true,
                      width: newVideoSizeWidth,
                    ),
                  );
                }
              },
            ),
            // ParcelCam(),

            // StreamBuilder(
            //   stream: widget.personalChannel.stream,
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return Center(
            //         // child: CircularProgressIndicator(
            //         //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //         // ),
            //         child: Text('Parcel Cam currently not available :('),
            //       );
            //     } else {
            //       return GestureZoomBox(
            //         maxScale: 5.0,
            //         doubleTapScale: 2.0,
            //         duration: Duration(milliseconds: 200),
            //         child: Image.memory(
            //           snapshot.data,
            //           gaplessPlayback: true,
            //           width: newVideoSizeWidth,
            //         ),
            //       );
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class ParcelCam extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isRunning = useState(true);
    return Container(
      child: Center(
        child: Mjpeg(
          isLive: isRunning.value,
          error: (context, error, stack) {
            print(error);
            print(stack);
            return Text(error.toString(), style: TextStyle(color: Colors.red));
          },
          stream:
              'http://192.168.60.107:81/stream', //'http://192.168.1.37:8081',
        ),
      ),
    );
    ;
  }
}
