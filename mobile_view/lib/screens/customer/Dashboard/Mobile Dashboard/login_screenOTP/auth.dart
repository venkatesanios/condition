

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/login_screenOTP/user.dart';
import 'package:provider/provider.dart';

class AuthService{
  final FirebaseAuth _auth  = FirebaseAuth.instance;
  String verificationIdReceived = '';
  FirebaseAuth get auth => _auth;
  // create user obj based on firebaseUser

  String _userFromFirebasUser(user){
    print("user.uid = ${user.uid}");
    final result = CreateUser(uid: user.uid);
    return user.uid;
  }
  void verify(){
    final passid = CreateUser();
    passid.verifyId(verificationIdReceived);
  }
//  sign in anonymous
  Future signInAnon()async{
    try{
      final result = await _auth.signInAnonymously();
      final user = result.user;
      // print(user?.uid);
      return _userFromFirebasUser(user);
    } on FirebaseAuthException catch(e){
      print(e.toString());
      print('error is worked');
      return null;
    }
  }
//sign in with email and password

//register with email and password
  Future signupWithEmailPassword(String email, String password)async{
    try{
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = result.user;
      return _userFromFirebasUser(user);

    } on FirebaseAuthException catch(e){
      print(e.toString());
      return null;
    }
  }

//sign out
  Future signOut()async{
    try{
      return await _auth.signOut();
    } on FirebaseAuthException catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign with phone number
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    print('phone number is : $phoneNumber');
    Completer<String> completer = Completer<String>();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException exception) async{
          print(exception.message);
        },
        codeSent: (String verificationId, int? resendToken) async{
          verificationIdReceived = verificationId;
          completer.complete(verificationId);
          print('verificationId is : $verificationIdReceived');
        },
        codeAutoRetrievalTimeout: (String verificationId) async{
          print('TimeOut');
        },
        timeout: await Duration(seconds: 60),
      );
      print(await 'verificationIdReceived : ${verificationIdReceived}.............');
      return completer.future;
    }on FirebaseAuthException catch(e) {
      print('Error verifying phone number: ${e.message}');
      return 'null';
    }
  }
}
