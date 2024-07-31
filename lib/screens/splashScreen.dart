import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covhealth/widgets/UserService.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /*@override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 8), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }*/

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userId = prefs.getString('userId');

    print("Statut de connexion : $isLoggedIn");

    Future.delayed(Duration(seconds: 8), () {
      if (isLoggedIn && userId != null) {
        print("Utilisateur connecté, redirection vers HomePage...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print("Utilisateur non connecté, redirection vers LoginPage...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logomobile.gif',
              width: 400,
              height: 400,
            ),

          ],
        ),
      ),

    );
  }


}
