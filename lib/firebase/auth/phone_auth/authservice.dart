 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/firebase/auth/phone_auth/get_phone.dart';
import 'package:civideoconnectapp/src/pages/Index.dart';


class AuthService {
  //Handles Auth
  String currentUserMobile;
  FirebaseAuth _auth;  
  FirebaseUser _user;


  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            
            return IndexPage();
          } else {
            return PhoneAuthGetPhone();
          }
        });
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
    
}





 
}