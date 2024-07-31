import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:covhealth/screens/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import'package:covhealth/widgets/notificationService.dart';
import'package:covhealth/widgets/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'package:covhealth/screens/homePage.dart';

import'package:covhealth/screens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyA-u9sX02HurPZehtrIFx9ejKdKjltVIno",
        appId: "1:376398763375:web:a3f65f152969213c5ac49a",
        messagingSenderId: "376398763375",
        projectId: "apicov"),
    );
  }else{
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initNotification();



  /*runApp(const MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));*/
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserService()), //responsable de la gestion et de la notif des changements d'état de l'utilisateur
        Provider(create: (_) => FirebaseAuthService()),//pour la deconexion

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      home: SplashScreen(),

      debugShowCheckedModeBanner: false,
    );
  }
}






