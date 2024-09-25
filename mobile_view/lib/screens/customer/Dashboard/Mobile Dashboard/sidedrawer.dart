import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_view/screens/UserChat/user_chat.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/ControllerSettings.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/sub_user.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/verssionupdate.dart';
import 'package:mobile_view/screens/customer/SentAndReceived/sent_and_received.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/theme.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../../sevicecustomer.dart';
import 'AccountManagement.dart';

class DrawerWidget extends StatefulWidget {
  final MQTTManager manager;
  List<dynamic> listOfSite;
  DrawerWidget({super.key,required this.listOfSite, required this.manager});
  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}
class _DrawerWidgetState extends State<DrawerWidget> {
  String uName = '';
  String uMobileNo = '';
  String uEmail = '';
  late OverAllUse overAllPvd;
  late MqttPayloadProvider payloadProvider;
  final String _correctPassword = 'Oro@321';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);

    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    getUserData();
  }
  Future<void> getUserData()
  async {
    final prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      setState(() {
        // final userIdFromPref = prefs.getString('userId') ?? '';
        uName = prefs.getString('userName') ?? '';
        uMobileNo = prefs.getString('mobileNumber') ?? '';
        uEmail = prefs.getString('email') ?? '';
      });
    });
    print("uName:$uName,uMobileNo:$uMobileNo,uEmail:$uEmail,");
  }

  @override
  Widget build(BuildContext context) {
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          DrawerHeader(
            decoration: BoxDecoration(
              color: myTheme.primaryColorDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountManagement(userID: overAllPvd.customerId, callback: callbackFunction),
                        ),
                      );
                    });
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child:   Text(uName.isNotEmpty ? uName.substring(0, 1).toUpperCase() : '', // Replace with the first letter of the user's name
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Text(uName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(uMobileNo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(uEmail,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () {
          //
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.info),
          //   title: Text('App Info'),
          //   onTap: () {
          //     // Navigate to app info screen or perform related action.
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Sub User'),
            onTap: () async{
              for(var site = 0;site < widget.listOfSite.length;site++){
                setState(() {
                  widget.listOfSite[site]['overAll'] = false;
                });
                for(var master = 0;master < widget.listOfSite[site]['master'].length;master++){
                  setState(() {
                    widget.listOfSite[site]['master'][master]['selectedMaster'] = false;
                  });
                }
              }
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return SubUser(listOfSite: widget.listOfSite,);
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.design_services),
            title: Text('Service Request'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return TicketHomePage(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId);
              }));
              // Navigate to help screen or perform related action.
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.help),
          //   title: Text('Help'),
          //   onTap: () {
          //     // Navigate to help screen or perform related action.
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.send_to_mobile),
            title: Text('Sent and Received'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return SentAndReceived();
              }));
              // Navigate to help screen or perform related action.
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Help and Support'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserChatScreen(userId: overAllPvd.userId, dealerId: 0, userName: uName,)));
              // Navigate to send feedback screen or perform related action.
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Controller Info'),
            onTap: () => _showPasswordDialog(context),

          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ControllerSettings();
              }));
              // Navigate to help screen or perform related action.
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () async {
              setState(() {
                payloadProvider.selectedSiteString = '';
              });
              widget.manager.unSubscribe(
                  unSubscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
                  subscribeTopic: '',
                  publishTopic: '',
                  publishMessage: jsonEncode({"3000":[{"3001":""}]})
              );
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              await prefs.remove('userName');
              await prefs.remove('userType');
              await prefs.remove('countryCode');
              await prefs.remove('mobileNumber');
              await prefs.remove('subscribeTopic');
              if (mounted){
                Navigator.pushReplacementNamed(context, '/loginOTP');
                Future.delayed(Duration.zero, () {
                  payloadProvider.clearData();
                  overAllPvd.userId = 0;
                  overAllPvd.controllerId = 0;
                  overAllPvd.controllerType = 0;
                  overAllPvd.imeiNo = '';
                  overAllPvd.customerId = 0;
                  overAllPvd.sharedUserId = 0;
                  overAllPvd.takeSharedUserId = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
  void callbackFunction(message)
  {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final enteredPassword = _passwordController.text;

                if (enteredPassword == _correctPassword) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetVerssion()),
                  );
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  _showErrorDialog(context);
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Incorrect password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}