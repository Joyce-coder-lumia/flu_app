import 'package:flutter/material.dart';
import 'package:covhealth/screens/homePage.dart';
import 'signPage.dart';
import'package:firebase_auth/firebase_auth.dart';
import 'package:covhealth/widgets/firebase_auth_services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Blob Shape.png', width: 250.0, height: 250.0,),

              Text('Se connecter Maintenant',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),),
              SizedBox(height: height * 0.01,),
              //Text('Veuillez vous connecter maintenant pour continuer notre application', style: TextStyle(fontSize: 9.0),),
              Center(
                child: Text(
                  'Veuillez vous connecter maintenant\npour continuer notre application',
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: height * 0.05,),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [Color(0xFFD062FA), Color(0xFF4B39EF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  5),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  background: Paint()..color = Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [Color(0xFFD062FA), Color(0xFF4B39EF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  5),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: "mot de passe",
                                labelStyle: TextStyle(
                                  background: Paint()..color = Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05,),
                      _isLoading
                          ? CircularProgressIndicator()
                      : InkWell(
                        onTap: () {
                          _signIn();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.00, -1.00),
                              end: Alignment(0, 1),
                              colors: [Color(0xFFCD4FFF), Color(0xCC3214E9)],
                            ),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1),
                              borderRadius: BorderRadius.circular(29),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(1, 3),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 12,
                                offset: Offset(1, 19),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Se connecter',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30,),
                            ),
                          ),
                        ),
                      ),

                    ],

                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(16.0),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('nouvel utilisateur?', style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.6000000238418579),),),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SignPage()),);

                    }, child: Text('Créer un compte',style: TextStyle(color:Color(0xFFD062FA),)),
                    )
                  ],

                ) ,)

            ],
          ),
        ),

      ),
    );
  }

  void _signIn() async{
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    print("Tentative de connexion avec l'email : $email");

    User? user = await _auth.signInEmailAndPassword(email, password, context);

    setState(() {
      _isLoading = false;
    });

    if(user != null){

      AwesomeDialog(
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.success,
        showCloseIcon: true,
        title: 'Success',
        desc: 'Connexion réussie!',
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      )..show();
      print("user is successfully connected");

    }else{
      AwesomeDialog(
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.error,
        showCloseIcon: true,
        title: 'Erreur',
        desc: ' Erreur lors de la connexion',
        btnOkOnPress: () {},
      )..show();
      print("Some error");
    }
  }
}






















