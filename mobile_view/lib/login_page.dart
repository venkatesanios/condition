import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_view/screens/Dealer/DealerDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/http_service.dart';

TextEditingController _mobileNoController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
bool _isObscure = true;
bool isValid = false;
bool visibleLoading = false;
bool _validate = false;

String strTitle = 'ORO DRIP IRRIGATION';
String strSubTitle = 'Drip irrigation is a type of watering system used in agriculture, gardening, and landscaping to efficiently deliver water directly to the roots of plants.';
String strOtpText = 'We will send you an OPT(One Time password) to the entered customer mobile number';

class LoginForm extends StatefulWidget
{
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  Future<String> printsr()
  async {
    final prefs = await SharedPreferences.getInstance();
    final userIdFromPref = prefs.getString('deviceToken') ?? '';
    return userIdFromPref;
    print(" DEVEICE TOKEN IS :$userIdFromPref");
  }
  @override
  Widget build(BuildContext context) {
    double width  =  MediaQuery.sizeOf(context).width;
    printsr();
     return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SafeArea(
            child: Scaffold(
              body: Row(
                children: [
                  if(constraints.maxWidth > 800)
                    Expanded(
                      flex:constraints.maxWidth > 1200 ? 2 : 1,
                      child: Container(
                          width: double.infinity, height: double.infinity,
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: SvgPicture.asset('assets/SVGPicture/login_left_picture.svg'),
                          )
                      ),
                    ),
                  Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Expanded(
                            //     child: Container(
                            //       color: Colors.white,
                            //       child: Row(
                            //         children: [
                            //           Expanded(flex: 3, child: Container()),
                            //           const Image(image: AssetImage('assets/images/login_top_corner.png')),
                            //         ],
                            //       ),
                            //     )
                            // ),
                            Expanded(
                                flex:5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 40),
                                      child: Column(
                                        children: [
                                          SvgPicture.asset('assets/SVGPicture/oro_logo.svg', fit: BoxFit.cover),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                            child: Text(strSubTitle, style: Theme.of(context).textTheme.titleSmall,),
                                          ),
                                          const SizedBox(height: 15,),
                                          // SizedBox(height: 50,
                                          //   child: InternationalPhoneNumberInput(
                                          //     inputDecoration: InputDecoration(
                                          //       border: const OutlineInputBorder(),
                                          //        labelText: 'Phone Number',
                                          //       suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.red,),
                                          //           onPressed: () {
                                          //             _mobileNoController.clear();
                                          //           }),
                                          //     ),
                                          //     onInputChanged: (PhoneNumber number) {
                                          //       //print(number);
                                          //     },
                                          //     selectorConfig: const SelectorConfig(
                                          //       selectorType: PhoneInputSelectorType.DROPDOWN,
                                          //       setSelectorButtonAsPrefixIcon: true,
                                          //       leadingPadding: 2,
                                          //       useEmoji: true,
                                          //     ),
                                          //     ignoreBlank: false,
                                          //     autoValidateMode: AutovalidateMode.disabled,
                                          //     selectorTextStyle: Theme.of(context).textTheme.titleMedium,
                                          //     initialValue: PhoneNumber(isoCode: 'IN'),
                                          //     textFieldController: _mobileNoController,
                                          //     formatInput: false,
                                          //     keyboardType:
                                          //     const TextInputType.numberWithOptions(signed: true, decimal: true),
                                          //     onSaved: (PhoneNumber number) {
                                          //       //print('On Saved: $number');
                                          //     },
                                          //   ),
                                          // ),
                                          const SizedBox(height: 15,),
                                          TextField(
                                            controller: _passwordController,
                                            obscureText: _isObscure,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                              border: const OutlineInputBorder(),
                                              labelText: 'Password',
                                              suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isObscure = !_isObscure;
                                                    });
                                                  }),
                                            ),
                                          ),
                                          const SizedBox(height: 10,),
                                          SizedBox(
                                              height: 30,
                                              width: width,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 2, left: 40),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text("Forgot Password ?", style: Theme.of(context).textTheme.bodyMedium),
                                                  ],
                                                ),
                                              )
                                          ),
                                          const SizedBox(height: 15,),
                                          SizedBox(
                                            width: 150.0,
                                            height: 40.0,
                                            child: MaterialButton(
                                              color: Theme.of(context).primaryColor,
                                              textColor: Colors.white,
                                              child: const Text('CONTINUE'),
                                              onPressed: () async {
                                                final prefs = await SharedPreferences.getInstance();
                                                final userIdFromPref = prefs.getString('deviceToken') ?? '';
                                                print('device Token:--->$userIdFromPref');
                                                 setState(() {
                                                  _mobileNoController.text.isEmpty ||_passwordController.text.isEmpty ? _showSnackBar('Value Can\'t Be Empty') :
                                                  _mobileNoController.text.length < 6 || _passwordController.text.length < 5 ? _showSnackBar('Invalid Mobile number or Password') : _validate = true;
                                                });
                                                 if(userIdFromPref.isNotEmpty && userIdFromPref != '') {
                                                   if (_validate) {
                                                     Map<String,
                                                         Object> body = {
                                                       'mobileNumber': _mobileNoController
                                                           .text,
                                                       'password': _passwordController
                                                           .text,
                                                       'deviceToken': userIdFromPref,
                                                       'isMobile' : true
                                                     };
                                                     final response = await HttpService().postRequest("userSignIn", body);
                                                     //print(response.body);
                                                     if (response.statusCode == 200) {
                                                       var data = jsonDecode(response.body);
                                                       if (data["code"] == 200) {
                                                         _mobileNoController.clear();
                                                         _passwordController.clear();

                                                         final customerData = data["data"];
                                                         final customerInfo = customerData["user"];

                                                         /*List<dynamic> siteData = data['data']['site'];
                                                  List<String> siteList = siteData.map((site) => json.encode(site)).toList();*/
                                                         // print(customerInfo);
                                                         print("customerData ==> $customerData");

                                                         if(customerInfo["userType"] != 1) {
                                                           final prefs = await SharedPreferences.getInstance();
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
                                                         }
                                                         final userType =  prefs.getString('userType') ?? '';
                                                         //await prefs.setStringList('site', siteList);

                                                         // print("userType ==> $userType");
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
                                                       }
                                                       else {
                                                         _showSnackBar(
                                                             data["message"]);
                                                       }
                                                     }
                                                   }
                                                 }
                                                 else
                                                   {
                                                     _showSnackBar('We Can\'t  Fetch your Device Token Try Again');
                                                   }
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(text: 'or Login with ', style: Theme.of(context).textTheme.titleSmall),
                                                TextSpan(text: 'OTP', style: Theme.of(context).textTheme.bodyMedium),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
          );
        }
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
