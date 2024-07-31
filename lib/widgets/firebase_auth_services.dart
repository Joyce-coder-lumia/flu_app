import'package:firebase_auth/firebase_auth.dart';
import'package:covhealth/widgets/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';




class FirebaseAuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<User?> signUpEmailAndPassword(String email, String password, String nom, String prenom, String phoneNumber, BuildContext context) async{
    try{
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'phoneNumber': phoneNumber,
          'role': 'patient',
        });



        //nouvelle ajout
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        UserModel currentUser = UserModel(
          uid: user.uid,
          email: user.email!,
          nom: userData['nom'],
          prenom: userData['prenom'],
          phoneNumber: userData['phoneNumber'],
          role: userData['role'],
        );
        Provider.of<UserService>(context, listen: false).setCurrentUser(currentUser);

        String? token = await user.getIdToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        if (token != null) {
          await prefs.setString('userToken auservice', token);
        }
        await prefs.setString('userId', user.uid);  // Stocker l'identifiant utilisateur
        print("Utilisateur connecté et token stocké auservice: $token");
      }
      return user;

    } catch(e){
      print("Erreur lors de l'inscription : $e");
    }
    return null;
  }


  Future<User?> signInEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      // Connecte l'utilisateur avec les informations fournies.
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        UserModel currentUser = UserModel(
          uid: user.uid,
          email: user.email!,
          nom: userData['nom'],
          prenom: userData['prenom'],
          phoneNumber: userData['phoneNumber'],
          role: userData['role'],
        );
        Provider.of<UserService>(context, listen: false).setCurrentUser(currentUser);
        print("Données utilisateur mises à jour dans UserService.");


        String? token = await user.getIdToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Stocke un indicateur d'état de connexion.
        await prefs.setBool('isLoggedIn', true);
        if (token != null) {
          await prefs.setString('userToken', token);
        }
        await prefs.setString('userId', user.uid);  // Stocker l'identifiant utilisateur
        print("Utilisateur connecté et token stocké: $token");





      } else {
        print("Connexion échouée : utilisateur null.");
      }

      return user;
    } catch (e) {
      print("Erreur lors de la connexion : $e");
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Provider.of<UserService>(context, listen: false).clearCurrentUser();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userToken');
      await prefs.remove('userId');  // Supprimer l'identifiant utilisateur
      print("Déconnexion réussie  fireservice!");


    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }
  }


}