import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mobile_view/ListOfFertilizerInSet.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:mobile_view/screens/config/constant/general_in_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/overall_use.dart';

class SubUser extends StatefulWidget {
  List<dynamic> listOfSite;
  SubUser({super.key,required this.listOfSite});
  @override
  State<SubUser> createState() => _SubUserState();
}

class _SubUserState extends State<SubUser> {
  List<dynamic> listOfSubUser = [];
  List<dynamic> selectedSharedUserData = [];
  bool httpError = false;
  TextEditingController phnNo = TextEditingController();
  String message = '';
  dynamic customer = {};

  @override
  void initState() {
    // TODO: implement initState
    getData();
    phnNo.text = '';
    print('subuser listOfSite => ${ widget.listOfSite}');
    super.initState();

  }
  void getData()async{
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var getUserDetails = await service.postRequest('getUserSharedList  ', {'userId' : overAllPvd.userId,'controllerId' : overAllPvd.controllerId,});
      var jsonData = jsonDecode(getUserDetails.body);
      if(jsonData['code'] == 200){

        setState(() {
          listOfSubUser = jsonData['data'];
          for(var subUser in listOfSubUser){
            for(var master in subUser['masters']){
              master['alreadySelect'] = true;
            }
          }
        });
        print('getData => ${jsonData}');
      }else if(jsonData['code'] == 404){
        setState(() {
          listOfSubUser = [];
        });
      }
      setState(() {
        httpError = false;
      });
    }catch(e,stackTrace){
      setState(() {
        httpError = true;
      });
      print(' Error getUserDetails  => ${e.toString()}');
      print(' trace getUserDetails  => ${stackTrace}');
    }
  }
  

  void createUserSharedController ({required sharedUserId})async{
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var listOfControllerId = [];
      for(var site in selectedSharedUserData){
        for(var master in site['master']){
          for(var permission in master['userPermission']){
            listOfControllerId.add({
              'id' : master['controllerId'],
              'action' : master['isSharedDevice'],
              'userPermission' : master['userPermission']
            });
          }
        }
      }
      var getUserDetails = await service.postRequest('createUserSharedController', {'userId' : overAllPvd.userId,'masterList' : listOfControllerId,'sharedUser' : sharedUserId,'createUser' : overAllPvd.userId});
      var jsonData = jsonDecode(getUserDetails.body);
      print('createUserSharedController ==>   ${jsonData}');
      setState(() {
        httpError = false;
      });
    }catch(e,stackTrace){
      setState(() {
        httpError = true;
      });
      print(' Error createUserSharedController  => ${e.toString()}');
      print(' trace createUserSharedController  => ${stackTrace}');
    }
  }
  void removeUserSharedController({
    required int sharedUser
})async{
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      print('sharedUser => $sharedUser');
      HttpService service = HttpService();
      var getUserDetails = await service.postRequest('removeUserSharedController', {'userId' : overAllPvd.userId,'controllerId' : overAllPvd.controllerId,'sharedUser' : [sharedUser]});
      var jsonData = jsonDecode(getUserDetails.body);
      if(jsonData['code'] == 200){
        print('removeUserSharedController ==>   ${jsonData}');
        setState(() {
          customer = {};
          phnNo.text = '';
        });
        getData();
      }
      setState(() {
        httpError = false;
      });
    }catch(e,stackTrace){
      setState(() {
        httpError = true;
      });
      print(' Error removeUserSharedController  => ${e.toString()}');
      print(' trace removeUserSharedController  => ${stackTrace}');
    }
  }

  void getSelectedSharedUserConfigData({required int sharedUserId})async{
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var getUserDetails = await service.postRequest('getUserSharedDeviceList', {'userId' : overAllPvd.userId,'sharedUserId' : sharedUserId,});
      var jsonData = jsonDecode(getUserDetails.body);
      print(" getUserSharedDeviceListList -- ${jsonData}");
      if(jsonData['code'] == 200){
        setState(() {
          selectedSharedUserData = jsonData['data'];
        });
        sideSheet(sharedUserId: sharedUserId);
      }else if(jsonData['code'] == 404){
        setState(() {
          selectedSharedUserData = [];
        });
      }
      setState(() {
        httpError = false;
      });
    }catch(e,stackTrace){
      setState(() {
        httpError = true;
      });
      print(' Error getUserSharedDeviceListList  => ${e.toString()}');
      print(' trace getUserSharedDeviceListList  => ${stackTrace}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub User'),
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for(var i in listOfSubUser)
              Container(
                  margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: customBoxShadow
                ),
                child: ListTile(
                  title: Text('${i['userName']}'),
                  subtitle: Text('${i['mobileNumber']}'),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            // setState(() {
                            //   for(var site = 0;site < widget.listOfSite.length;site++){
                            //     for(var master = 0;master < widget.listOfSite[site]['master'].length;master++){
                            //       widget.listOfSite[site]['master'][master]['selectedMaster'] = false;
                            //       widget.listOfSite[site]['master'][master].remove('alreadySelect');
                            //       for(var m in i['masters']){
                            //         if(m['deviceId'] == widget.listOfSite[site]['master'][master]['deviceId']){
                            //           widget.listOfSite[site]['master'][master]['selectedMaster'] = true;
                            //           widget.listOfSite[site]['master'][master]['alreadySelect'] = true;
                            //         }
                            //       }
                            //     }
                            //   }
                            // });

                            getSelectedSharedUserConfigData(sharedUserId: i['userId']);
                          },
                          icon: Icon(Icons.edit_note,color: Colors.blueGrey,),
                        ),
                        // IconButton(
                        //   onPressed: (){
                        //     showDialog(context: context, builder: (context){
                        //       return AlertDialog(
                        //         title: Text('Alert Message'),
                        //         content: Text('Are you sure you want to remove all controllers for sharing...'),
                        //         actions: [
                        //           TextButton(
                        //               onPressed: (){
                        //                 Navigator.pop(context);
                        //               },
                        //               child: Text('Cancel')
                        //           ),
                        //           TextButton(
                        //               onPressed: (){
                        //                 for(var site = 0;site < widget.listOfSite.length;site++){
                        //                   for(var master = 0;master < widget.listOfSite[site]['master'].length;master++){
                        //                     widget.listOfSite[site]['master'][master]['selectedMaster'] = false;
                        //                     widget.listOfSite[site]['master'][master].remove('alreadySelect');
                        //                     for(var m in i['masters']){
                        //                       if(m['deviceId'] == widget.listOfSite[site]['master'][master]['deviceId']){
                        //                         widget.listOfSite[site]['master'][master]['selectedMaster'] = false;
                        //                         widget.listOfSite[site]['master'][master]['alreadySelect'] = true;
                        //                       }
                        //                     }
                        //                   }
                        //                 }
                        //                 createUserSharedController();
                        //                 Navigator.pop(context);
                        //               },
                        //               child: Text('OK')
                        //           ),
                        //         ],
                        //       );
                        //     });
                        //   },
                        //   icon: Icon(Icons.person_remove_alt_1,color: Colors.red,),
                        // ),
                      ],
                    ),
                  ),
                )
              )
          ],
        ),
      )
    );
  }
  void sideSheet({required sharedUserId}) {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      // barrierColor: const Color(0xff6600),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Scaffold(
                    floatingActionButton: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: customBoxShadow
                      ),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text("Cancel",style: TextStyle(color: Colors.white),),
                            color: Colors.red,
                          ),
                          MaterialButton(
                            onPressed: (){
                              createUserSharedController(sharedUserId: sharedUserId);
                              Navigator.pop(context);
                            },
                            child: Text('Submit',style: TextStyle(color: Colors.white)),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      // margin: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                      ),
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20,),
                              for(var site = 0;site < selectedSharedUserData.length;site++)
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text('${selectedSharedUserData[site]['groupName']}',style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold),),
                                      trailing: Checkbox(
                                        value: selectedSharedUserData[site]['isSharedGroup'],
                                        onChanged: (value){
                                          stateSetter((){
                                            setState(() {
                                              selectedSharedUserData[site]['isSharedGroup'] = !selectedSharedUserData[site]['isSharedGroup'];
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                    for(var master = 0;master < selectedSharedUserData[site]['master'].length;master++)
                                      Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            leading: Checkbox(
                                                value: selectedSharedUserData[site]['master'][master]['isSharedDevice'],
                                                onChanged: (value){
                                                  stateSetter((){
                                                    setState(() {
                                                      selectedSharedUserData[site]['master'][master]['isSharedDevice'] = !selectedSharedUserData[site]['master'][master]['isSharedDevice'];
                                                    });
                                                  });
                                                }
                                            ),
                                            title: Text('${selectedSharedUserData[site]['master'][master]['deviceName']}',style: TextStyle(color: primaryColorDark,fontWeight: FontWeight.bold),),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Column(
                                              children: [
                                                for(var userPermission = 0;userPermission < selectedSharedUserData[site]['master'][master]['userPermission'].length;userPermission++)
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text('${selectedSharedUserData[site]['master'][master]['userPermission'][userPermission]['name']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                                    trailing: Checkbox(
                                                      value: selectedSharedUserData[site]['master'][master]['userPermission'][userPermission]['status'],
                                                      onChanged: (value){
                                                        stateSetter((){
                                                          setState(() {
                                                            selectedSharedUserData[site]['master'][master]['userPermission'][userPermission]['status'] = !selectedSharedUserData[site]['master'][master]['userPermission'][userPermission]['status'];
                                                          });
                                                        });
                                                      },
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    Divider(
                                      height: 1,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                            SizedBox(height: 100,)
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }
}

