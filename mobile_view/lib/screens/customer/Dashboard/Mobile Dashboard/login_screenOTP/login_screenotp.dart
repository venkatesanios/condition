import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/login_screenOTP/widget/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../constants/http_service.dart';
import '../../../../../constants/theme.dart';
import '../../../../../login_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _contactEditingController = TextEditingController();
  var _dialCode = '';
  int _clickCount = 0;
  String isoCode = 'IN';
  //Login click with contact number validation
  Future<void> clickOnLogin(BuildContext context) async {
     if (_contactEditingController.text.isEmpty) {
      showErrorDialog(context, 'Register number can\'t be empty.');
    }
     else {
      String checkval = await checkNumber(
          _dialCode, '${_contactEditingController.text}');
       if(checkval == 'true')
        {
        final responseMessage =
        await Navigator.pushNamed(context, '/OtpScreen',
            arguments: '$_dialCode ${_contactEditingController.text}');
      if (responseMessage != null) {
        showErrorDialog(context, responseMessage as String);
      }
    }
      else
        {
          _contactEditingController.text = '';
          showErrorDialog(context, 'This is Not Register Number \n Enter Register Correct Number');
        }
    }
  }

 Future<String> checkNumber(String countryCode,String mobileNumber)
     async
    {
      // verifyOtp();
      final prefs = await SharedPreferences.getInstance();
      final userIdFromPref = prefs.getString('deviceToken') ?? '';
         Map<String,
          Object> body = {
         'countryCode': countryCode.replaceFirst('+', ''),
        'mobileNumber': mobileNumber,
        // 'macAddress': '123456',
        'deviceToken': userIdFromPref,
        'isMobile' : true
      };
        final response = await HttpService()
          .postRequest(
          "userVerification", body);
       if (response.statusCode ==
          200) {
        var data = jsonDecode(
            response.body);
        if (response.statusCode ==
            200) {
          var data = jsonDecode(
              response.body);
          if (data["code"] ==
              200) {

            final customerData = data["data"];
            final customerInfo = customerData["user"];

            /*List<dynamic> siteData = data['data']['site'];
                                                  List<String> siteList = siteData.map((site) => json.encode(site)).toList();*/


            if (mounted) {
              Navigator
                  .pushReplacementNamed(
                  context,
                  '/dashboard');
            }
            return 'true';
          }
          else {
            // _showSnackBar(
            //     data["message"]);
            return 'false';
          }

        }
        else
          {
            return 'false';
          }

        }
        else {
          return 'false';

        }
      }

   //callback function of country picker
  void _callBackFunction(String name, String dialCode, String flag) {
    _dialCode = dialCode;
  }

  //Alert dialogue to show error and response
  void showErrorDialog(BuildContext context, String message) {
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

 // To track the number of clicks

  void _handleTap() {
    setState(() {
      _clickCount++;
      if (_clickCount >= 7) {
        // Navigate to a new screen when 7 clicks are reached
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginForm()),
        );
        // Reset click count after navigation
        _clickCount = 0;
      }
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on tap outside
      builder: (context) => AlertDialog(
        title: Text("Exit"),
        content: Text("Do you want to exit?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => exit(0),
            // onPressed: () => Navigator.of(context).pop(true),// Return true to pop the route
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(false), // Return false to stay on the route
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false; // Handle null case by returning false (stay on the route)
  }

  //build method for UI Representation
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        bool canPop = false;

          canPop = await _onWillPop(context);

        if (canPop) {
          Navigator.pop(context);
        } else {
          return;
        }
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                   GestureDetector(
                     onTap: _handleTap,
                     child: Image.asset(
                      'assets/images/otpmobile.png',
                      height: screenHeight * 0.3,
                      fit: BoxFit.contain,
                                     ),
                   ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Text(
                    'Login with OTP',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Text(
                    'Enter your Register mobile number to get an OTP and complete the verification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // InternationalPhoneNumberInput(
                        //   inputDecoration: InputDecoration(
                        //     border: const OutlineInputBorder(),
                        //      labelText: 'Phone Number',
                        //     suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.red,),
                        //         onPressed: () {
                        //           _contactEditingController.clear();
                        //         }),
                        //   ),
                        //   onInputChanged: (PhoneNumber number) {
                        //      setState(() {
                        //       _dialCode = number.dialCode!;
                        //       isoCode = number.isoCode!;
                        //     });
                        //   },
                        //   selectorConfig: SelectorConfig(
                        //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        //     setSelectorButtonAsPrefixIcon: true,
                        //     leadingPadding: 10,
                        //     useEmoji: true,
                        //   ),
                        //   ignoreBlank: false,
                        //   autoValidateMode: AutovalidateMode.always,
                        //   selectorTextStyle: myTheme.textTheme.titleMedium,
                        //   initialValue: PhoneNumber(isoCode: isoCode),
                        //   textFieldController: _contactEditingController,
                        //   formatInput: false,
                        //   keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        //   onSaved: (PhoneNumber number) {
                        //     setState(() {
                        //       _dialCode = number.dialCode!;
                        //       isoCode = number.isoCode!;
                        //     });
                        //     //print('On Saved: $number');
                        //   },
                        // ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomButton(clickOnLogin),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
