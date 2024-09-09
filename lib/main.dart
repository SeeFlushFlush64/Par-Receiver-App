import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/ImageWidget.dart';
import 'package:modernlogintute/api/firebase_message_api.dart';
import 'package:modernlogintute/count%20page/count_docs_test.dart';
import 'package:modernlogintute/count%20page/your_widget.dart';
import 'package:modernlogintute/pages/auth_page.dart';
import 'package:modernlogintute/pages/infraredEmitterWidget.dart';
import 'package:modernlogintute/pages/testDelivery.dart';
import 'package:modernlogintute/userTabs/transactions.dart';
import 'package:modernlogintute/trial/try_show_image.dart';
// import 'pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessagingApi().initNotifications();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF191970)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // home: FirebaseImageWidget(imageName: 'photo.jpg'),
      home: AuthPage(),
      // home: CountCOD(),
    );
  }
}
