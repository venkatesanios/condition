import 'package:flutter/cupertino.dart';

class CreateUser extends ChangeNotifier{
  String? uid = '';
  String getValue = 'userornot';
  String verificationId = '';
  CreateUser({this.uid});

  void state(value){
    getValue = '';
    getValue += value;
    notifyListeners();
  }
  void verifyId(value){
    verificationId = '';
    verificationId = value;
    notifyListeners();
  }
}