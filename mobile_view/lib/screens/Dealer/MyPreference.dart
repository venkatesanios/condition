import 'dart:convert';

import 'package:flutter/material.dart';
 import 'package:mobile_view/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/http_service.dart';


class MyPreference extends StatefulWidget {
  const MyPreference({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  State<MyPreference> createState() => _MyPreferenceState();
}

class _MyPreferenceState extends State<MyPreference>
{

  String countryCode = '', mobileNo = '', userName = '', emailId = '', password = '';
  final TextEditingController _controllerMblNo = TextEditingController();
  final TextEditingController _controllerUsrName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPwd = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    countryCode = prefs.getString('countryCode')!;
    mobileNo = prefs.getString('mobileNumber')!;
    userName = prefs.getString('userName')!;
    emailId = prefs.getString('email')!;
    password = prefs.getString('password')!;

    _controllerMblNo.text = mobileNo;
    _controllerUsrName.text = userName;
    _controllerEmail.text = emailId;
    _controllerPwd.text = password;

  }


  @override
  Widget build(BuildContext context)
  {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings', style: TextStyle(color: Colors.white),),
        backgroundColor: myTheme.primaryColor,
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // InternationalPhoneNumberInput(
                  //   onInputChanged: (PhoneNumber number) {
                  //     //print(number.phoneNumber);
                  //   },
                  //   selectorConfig: const SelectorConfig(
                  //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  //     setSelectorButtonAsPrefixIcon: true,
                  //     leadingPadding: 10,
                  //     useEmoji: false,
                  //   ),
                  //   ignoreBlank: false,
                  //   inputDecoration: InputDecoration(
                  //     labelText: 'Mobile Number',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0), // Border radius
                  //     ),
                  //   ),
                  //   autoValidateMode: AutovalidateMode.disabled,
                  //   selectorTextStyle: const TextStyle(color: Colors.black),
                  //   initialValue: PhoneNumber(isoCode: 'IN'),
                  //   textFieldController: _controllerMblNo,
                  //   formatInput: false,
                  //   keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  //   onSaved: (PhoneNumber number) {
                  //     //print('On Saved: $number');
                  //   },
                  // ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controllerUsrName,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              //_name = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controllerPwd,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              //_name = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controllerEmail,
                          decoration: InputDecoration(
                            labelText: 'Email Id',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email id';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              //_name = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Spacer(),
                            MaterialButton(
                              color: Colors.grey,
                              textColor: Colors.white,
                              child: const Text('CANCEL'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 20,),
                            MaterialButton(
                              color: myTheme.primaryColor,
                              textColor: Colors.white,
                              child: const Text('SAVE CHANGES'),
                              onPressed: () async {
                                try {
                                  if (_formKey.currentState!.validate()) {
                                    final body = {"userId": widget.userID, "userName": _controllerUsrName.text, "countryCode": countryCode, "mobileNumber": _controllerMblNo.text,
                                      "emailAddress": _controllerEmail.text,"password": _controllerPwd.text,"modifyUser": widget.userID,};
                                    print(body);
                                    final response = await HttpService().putRequest("updateUserDetails", body);
                                    if (response.statusCode == 200) {
                                      final jsonResponse = json.decode(response.body);
                                      _showSnackBar(jsonResponse['message']);
                                    }
                                  }

                                } catch (e) {
                                  print('Error: $e');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                padding: const EdgeInsets.all(10),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('When Mobile Number and Email update', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text("OTP (One-Time Password) is crucial when changing your "
                              "mobile number or email associated with the account"
                            , style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text("When you initiate such changes, the app often sends"
                              " an OTP to your current registered mobile number or email address."
                              " You need to enter this OTP to confirm and complete the update"
                            , style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20,),
                    Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('1.'),
                        SizedBox(width: 10,),
                        Text('at least 6 characters password', style: TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('2.'),
                        SizedBox(width: 10,),
                        Text('at least one uppercase letter', style: TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('3.'),
                        SizedBox(width: 10,),
                        Text('at least one number', style: TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
