import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../constants/http_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../Dealer/DealerDashboard.dart';


// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  bool _isInit = true;
  var _contact = '';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String phoneNo;
  late String smsOTP;
  late String verificationId;
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _otpPinFieldKey = GlobalKey<OtpPinFieldState>();

  //this is method is used to initialize data
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once after screen load
    if (widget._isInit) {
      widget._contact = '${ModalRoute.of(context)?.settings.arguments as String}';
      generateOtp(widget._contact);
      widget._isInit = false;
    }
  }

  //dispose controllers
  @override
  void dispose() {
    super.dispose();
  }

  //build method for UI
  @override
  Widget build(BuildContext context) {
    //Getting screen height width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Navigator.pushReplacementNamed(context, '/loginOTP');
      },
      child: Scaffold(
         backgroundColor: Colors.teal.shade50,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  Image.asset(
                    'assets/images/otp.png',
                    height: screenHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Text(
                    'Verification',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    ' Enter the 6-digit OTP that was sent to  that was sent to ${widget._contact}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'If you didn\'t receive the OTP, you can',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: (){
                      generateOtp(widget._contact);
                    },
                     child: Text(
                      'Resend OTP',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.04,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        // ignore: prefer_const_literals_to_create_immutables
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: screenWidth * 0.025),
                          child: OtpPinField(
                            key: _otpPinFieldKey,
                            textInputAction: TextInputAction.done,
                            maxLength: 6,
                            fieldWidth: 40,
                            onSubmit: (text) {
                              smsOTP = text;
                            },
                            onChange: (text) {},
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.04,
                        ),
                        GestureDetector(
                          onTap: (){
                            verifyOtp();
                          },

                          // onTap: () async{
                          //   verifyOtp();
                          //      final prefs = await SharedPreferences.getInstance();
                          //     final userIdFromPref = prefs.getString('deviceToken') ?? '';
                          // //     print('device Token:--->$userIdFromPref');
                          //
                          //     // if(userIdFromPref.isNotEmpty && userIdFromPref != '') {
                          //       List<String> mobileNumbers = widget._contact.split(' ');
                          //
                          //         Map<String,
                          //           Object> body = {
                          //         'mobileNumber': mobileNumbers[1],
                          //         'password': '123456',
                          //         'deviceToken': userIdFromPref,
                          //       };
                          // //        print('body $body');
                          //       final response = await HttpService()
                          //           .postRequest(
                          //           "userSignIn", body);
                          // //       print('Response::::${response.body}');
                          //       if (response.statusCode ==
                          //           200) {
                          //         var data = jsonDecode(
                          //             response.body);
                          //         if (data["code"] ==
                          //             200) {
                          //            final customerData = data["data"];
                          //           final customerInfo = customerData["user"];
                          //            /*List<dynamic> siteData = data['data']['site'];
                          //                           List<String> siteList = siteData.map((site) => json.encode(site)).toList();*/
                          // //           print(customerInfo);
                          //
                          //           final prefs = await SharedPreferences
                          //               .getInstance();
                          //           await prefs.setString(
                          //               'userType',
                          //               customerInfo["userType"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'userName',
                          //               customerInfo["userName"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'userId',
                          //               customerInfo["userId"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'countryCode',
                          //               customerInfo["countryCode"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'mobileNumber',
                          //               customerInfo["mobileNumber"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'password',
                          //               customerInfo["password"]
                          //                   .toString());
                          //           await prefs.setString(
                          //               'email',
                          //               customerInfo["email"]
                          //                   .toString());
                          //           //await prefs.setStringList('site', siteList);
                          //
                          //           if (mounted) {
                          //             Navigator
                          //                 .pushReplacementNamed(
                          //                 context,
                          //                 '/dashboard');
                          //           }
                          //         }
                          //         else {
                          //           _showSnackBar(
                          //               data["message"]);
                          //         }
                          //       }
                          //
                          //
                          //     // }
                          //     // else
                          //     //   {
                          //     //     _showSnackBar('We Can\'t  Fetch your Device Token Try Again');
                          //     //   }
                          //
                          //   Navigator.pushReplacementNamed(context, '/dashboard');
                          // },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 28, 123, 137),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Verify',
                              style: TextStyle(color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Future<void> generateOtp(String contact) async {
    final PhoneCodeSent smsOTPSent = (verId, forceResendingToken) {
      verificationId = verId;
    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: contact,
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        codeSent: smsOTPSent,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential phoneAuthCredential) {},
        verificationFailed: (error) {
          // print(error);
        },
      );
    } catch (e) {
      // print('error generateOtp');
      handleError(e as PlatformException);
    }
  }

   Future<void> verifyOtp() async {
    if (smsOTP.isEmpty || smsOTP == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential user = await _auth.signInWithCredential(credential);
      final User? currentUser = _auth.currentUser;
      assert(user.user?.uid == currentUser?.uid);
      await checkNumber(widget._contact);
    } on PlatformException catch(e){
      handleError(e);
    }
    catch (e) {
      // print('error $e');
    }
  }
  Future<String> checkNumber(String countryCode)
  async
  {
    // verifyOtp();
     final prefs = await SharedPreferences.getInstance();
    final userIdFromPref = prefs.getString('deviceToken') ?? '';
    // // print('device Token:--->$userIdFromPref');
    Map<String,
        Object> body = {
      'countryCode': countryCode.split(' ')[0].replaceFirst('+', ''),
      'mobileNumber': countryCode.split(' ')[1],
      // 'macAddress': '123456',
      'deviceToken': userIdFromPref,
      'isMobile' : true
    };
    // print(body);
    final response = await HttpService()
        .postRequest(
        "userVerification", body);
       if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["code"] == 200) {

          final customerData = data["data"];
          final customerInfo = customerData["user"];

          /*List<dynamic> siteData = data['data']['site'];
                                                  List<String> siteList = siteData.map((site) => json.encode(site)).toList();*/
          // print(customerInfo);

          final prefs = await SharedPreferences
              .getInstance();
          await prefs.setString(
              'userType',
              customerInfo["userType"]
                  .toString());
          await prefs.setString(
              'userName',
              customerInfo["userName"]
                  .toString());
          await prefs.setString(
              'userId',
              customerInfo["userId"]
                  .toString());
          await prefs.setString(
              'countryCode',
              customerInfo["countryCode"]
                  .toString());
          await prefs.setString(
              'mobileNumber',
              customerInfo["mobileNumber"]
                  .toString());
          await prefs.setString(
              'password',
              customerInfo["password"]
                  .toString());
          await prefs.setString(
              'email',
              customerInfo["email"]
                  .toString());
          //await prefs.setStringList('site', siteList);
          final userType =  prefs.getString('userType') ?? '';
          if (mounted) {
            if(userType == "2") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DealerDashboard(userName: prefs.getString('userName')!, countryCode:  prefs.getString('countryCode')!, mobileNo:  prefs.getString('mobileNumber')!, userId: int.parse(prefs.getString('userId')!), emailId: prefs.getString('email')!)));
            }else if(userType == "1"){
              _showSnackBar("Admin cannot login through mobile phone");
            }
            else if(userType == "3"){
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              _showSnackBar("User type not found");
            }
          }

          return 'true';
        }
        else {
          _showSnackBar(
              data["message"]);
          return 'false';
        }

      }
     else {
      return 'false';

    }
  }
  //Method for handle the errors
  void handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        showAlertDialog(context, 'Invalid Code');
        break;
      default:
        showAlertDialog(context, error.message ?? 'Warning');
        break;
    }
  }

  //Basic alert dialogue for alert errors and confirmations
  void showAlertDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Warning'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}