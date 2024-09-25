import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../FertilizerSet.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../Models/Customer/log/irrigation_parameter_model.dart';
import '../../../../../constants/http_service.dart';
import '../../../../../constants/theme.dart';
import '../../../../../state_management/overall_use.dart';
import 'log_home.dart';

class ListOfLogConfig extends StatefulWidget {
  const ListOfLogConfig({super.key,});

  @override
  State<ListOfLogConfig> createState() => _ListOfLogConfigState();
}

class _ListOfLogConfigState extends State<ListOfLogConfig> {

  Map<String,dynamic> irrigationLogParameterFromServer = {
    'general' : {
      'ProgramName' : ['Program',true],
      'Status' : ['Status',true],
      'SequenceData' : ['Valve',true],
      // 'ZoneName' : ['Sequence',true],
      'Date' : ['Date',true],
      'ProgramCategoryName' : ['Line',true],
      'ScheduledStartTime' : ['Start Time',true],
      'overAll' : ['over all',true]
    },
    'irrigation' : {
      'IrrigationMethod' : ['Method',true],
      'IrrigationDuration_Quantity' : ['Planned',true],
      'IrrigationDurationCompleted/IrrigationQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    'centralEcPh' : {
      'CentralPhSetValue' : ['Central Ph Avg',true],
      'CentralEcSetValue' : ['Central Ec Avg',true],
      'overAll' : ['over all',true]
    },
    '<C - CH1>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH2>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH3>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH4>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH5>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH6>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH7>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },
    '<C - CH8>' : {
      'CentralFertMethod' : ['Method',true],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true],
      'overAll' : ['over all',true]
    },

  };
  dynamic serverData;
  IrrigationLog irrigationParameterArray = IrrigationLog();
  IrrigationLog irrigationParameterArrayDuplicate = IrrigationLog();

  IrrigationLog selectedIrrigationParameterArray = IrrigationLog();
  String errorMessage = '';
  String logName = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    getUserLogConfig();

    super.initState();
  }

  void createUserLogConfig({required String name,required dynamic configDetails})async{
    print('createUserLogConfig called...............');
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var response = await service.postRequest(
          'createUserLogConfig',
          {
            'userId' : overAllPvd.userId,
            'controllerId' : overAllPvd.controllerId,
            'logName': logName,
            'irrigationLog': configDetails,
            'createUser': overAllPvd.userId,
          });
      var jsonData = response.body;
      var myData = jsonDecode(jsonData);
      print('myData => ${myData}');
      if(myData['code'] == 200){
        getUserLogConfig();
      }

    }catch(e){
      log(e.toString());
    }
  }

  void updateUserLogConfig({required int id,required dynamic configDetails})async{
    print('updateUserLogConfig called...............');
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var response = await service.putRequest(
          'updateUserLogConfig',
          {
            'userId' : overAllPvd.userId,
            'controllerId' : overAllPvd.controllerId,
            'logName': logName,
            'irrigationLog': configDetails,
            'modifyUser': overAllPvd.userId,
            'logConfigId' : id,
          });
      var jsonData = response.body;
      var myData = jsonDecode(jsonData);
      print('myData => ${myData}');
      if(myData['code'] == 200){
        getUserLogConfig();
      }
    }catch(e){
      log(e.toString());
    }
  }

  void getUserLogConfig()async{
    print('getUserLogConfig called...............');
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      print('getUserLogConfig => ${overAllPvd.userId}  ${overAllPvd.controllerId}');
      HttpService service = HttpService();
      var response = await service.postRequest(
          'getUserLogConfig',
          {
            'userId' : overAllPvd.userId,
            'controllerId' : overAllPvd.controllerId,
          });
      var jsonData = response.body;
      var myData = jsonDecode(jsonData);
      print('getUserLogConfig myData => ${myData}');
      if(myData['code'] == 200){
        setState(() {
          serverData = myData['data'];
        });
        print('serverData => $serverData');
        setState(() {
          irrigationLogParameterFromServer = serverData['default'];
        });
        irrigationParameterArray.editParameter(irrigationLogParameterFromServer);
        irrigationParameterArrayDuplicate.editParameter(irrigationLogParameterFromServer);
      }
    }catch(e){
      log(e.toString());
    }
  }

  void deleteUserLogConfig({required id})async{
    print('deleteUserLogConfig called...............');

    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    try{
      HttpService service = HttpService();
      var response = await service.deleteRequest(
          'deleteUserLogConfig',
          {
            'userId' : overAllPvd.userId,
            'controllerId' : overAllPvd.controllerId,
            'logConfigId' : id,
          });
      var jsonData = response.body;
      var myData = jsonDecode(jsonData);
      print('delete response =>${myData}');
      if(myData['code'] == 200){
        getUserLogConfig();
      }
    }catch(e){
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);

    return LayoutBuilder(builder: (context,constraint){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                width: double.infinity,
                child: ListTile(
                  title: Text('List Of Irrigation Log',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  trailing: MaterialButton(
                    onPressed: (){
                      setState(() {
                        errorMessage = '';
                        logName = '';
                      });
                      sideSheet(constraints: constraint, mode: 1);
                    },
                    color: Colors.green,
                    child: Text('Add',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if(constraint.maxWidth > 300)
                customizeGridView(
                    maxWith: 300,
                    maxheight: 200,
                    screenWidth: constraint.maxWidth,
                    listOfWidget: [
                      if(serverData != null)
                        if(serverData['logConfig'].isNotEmpty)
                          for(var i = 0;i < serverData['logConfig'].length;i++)
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color:  Colors.white,
                                  boxShadow: customBoxShadow,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xff2B565B),
                                      radius: 20,
                                      child: Center(
                                        child: Text('${i+1}',style: TextStyle(color: Colors.white),),
                                      ),
                                    ),
                                    title: Text('${serverData['logConfig'][i]['logName']}'),
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Color(0xffFFF0E5))
                                          ),
                                          onPressed: ()async{
                                            setState(() {
                                              selectedIrrigationParameterArray.editParameter(serverData['logConfig'][i]['irrigationLog']);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.generalParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.generalParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.waterParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.waterParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.prePostParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.prePostParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralEcPhParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel1ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel2ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel3ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel4ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel5ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel6ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel7ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel8ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localEcPhParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel1ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel2ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel3ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel4ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel5ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel6ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel7ParameterList);
                                              setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel8ParameterList);
                                              errorMessage = '';
                                              logName = serverData['logConfig'][i]['logName'];
                                            });
                                            sideSheet(constraints: constraint, mode: 2,configId: serverData['logConfig'][i]['logConfigId']);

                                          },
                                          icon: Icon(Icons.edit_note,color: Colors.orange,)
                                      ),
                                      IconButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Color(0xffFFDEDC))
                                          ),
                                          onPressed: (){
                                            deleteUserLogConfig(id: serverData['logConfig'][i]['logConfigId']);
                                          },
                                          icon: Icon(Icons.delete,color: Colors.red,)
                                      ),
                                      IconButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Color(0xffEFFFFB))
                                          ),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return LogHome(serverData: serverData['logConfig'][i], userId: overAllPvd.userId,controllerId: overAllPvd.controllerId,);
                                            }));
                                          },
                                          icon: Icon(Icons.visibility,color: Colors.green,)
                                      ),
                                      // MaterialButton(
                                      //   color: Colors.green,
                                      //   onPressed: () {
                                      //     Navigator.push(context, MaterialPageRoute(builder: (context){
                                      //       return LogHome(serverData: serverData['logConfig'][i]);
                                      //       // return HomePage();
                                      //     }));
                                      //   },
                                      //   child: Text('View Report',style: TextStyle(color: Colors.white),),
                                      // ),
                                    ],
                                  )
                                ],
                              ),
                            )
                    ]
                )
              else
                if(serverData != null)
                  if(serverData['logConfig'].isNotEmpty)
                    for(var i = 0;i < serverData['logConfig'].length;i++)
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color:  Colors.white,
                            boxShadow: customBoxShadow,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xff2B565B),
                                radius: 20,
                                child: Center(
                                  child: Text('${i+1}',style: TextStyle(color: Colors.white),),
                                ),
                              ),
                              title: Text('${serverData['logConfig'][i]['logName']}'),
                              trailing: IntrinsicWidth(
                                child: Row(
                                  children: [
                                    IconButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Color(0xffFFF0E5))
                                        ),
                                        onPressed: ()async{
                                          setState(() {
                                            selectedIrrigationParameterArray.editParameter(serverData['logConfig'][i]['irrigationLog']);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.generalParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.generalParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.waterParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.waterParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.prePostParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.prePostParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralEcPhParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel1ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel2ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel3ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel4ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel5ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel6ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel7ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.centralChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel8ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localEcPhParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel1ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel2ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel3ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel4ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel5ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel6ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel7ParameterList);
                                            setOriginalToDuplicateParameter(originalParameterList: selectedIrrigationParameterArray.localChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel8ParameterList);
                                            errorMessage = '';
                                            logName = serverData['logConfig'][i]['logName'];
                                          });
                                          sideSheet(constraints: constraint, mode: 2,configId: serverData['logConfig'][i]['logConfigId']);
                                        },
                                        icon: Icon(Icons.edit_note,color: Colors.orange,)
                                    ),
                                    IconButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Color(0xffFFDEDC))
                                        ),
                                        onPressed: (){
                                          deleteUserLogConfig(id: serverData['logConfig'][i]['logConfigId']);
                                        },
                                        icon: Icon(Icons.delete,color: Colors.red,)
                                    ),
                                    IconButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Color(0xffEFFFFB))
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context){
                                            return LogHome(serverData: serverData['logConfig'][i], userId: overAllPvd.userId,controllerId: overAllPvd.controllerId,);
                                          }));
                                        },
                                        icon: Icon(Icons.visibility,color: Colors.green,)
                                    ),
                                    // MaterialButton(
                                    //   color: Colors.green,
                                    //   onPressed: () {
                                    //     Navigator.push(context, MaterialPageRoute(builder: (context){
                                    //       return LogHome(serverData: serverData['logConfig'][i]);
                                    //       // return HomePage();
                                    //     }));
                                    //   },
                                    //   child: Text('View Report',style: TextStyle(color: Colors.white),),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [


                              ],
                            )
                          ],
                        ),
                      )

            ],
          ),
        ),
      );
    });
  }


  void setOriginalToDuplicateParameter({required List<GeneralParameterModel> originalParameterList,required List<GeneralParameterModel> duplicateParameterList}){
    setState(() {
      for(var i = 0;i < originalParameterList.length;i++){
        duplicateParameterList[i].show = originalParameterList[i].show;
      }
    });
  }
  Widget getChannelFilter({required List<GeneralParameterModel> parameterList,required int channelNo,required bool central}){
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter stateSetter){
          return Column(
            children: [
              SizedBox(
                width: 250,
                height: 60,
                child: ListTile(
                  title: Text('<${central ? 'C' : 'L'} - CH$channelNo>',style: TextStyle(fontWeight: FontWeight.bold),),
                  leading: Checkbox(
                    value: parameterList[parameterList.length - 1].show,
                    onChanged: (bool? value) {
                      stateSetter(() {
                        parameterList[parameterList.length - 1].show = value!;
                        for(var p in parameterList){
                          p.show = value;
                        }
                      });

                    },
                  ),
                ),
              ),
              // for(var i in parameterList)
              //   if(i.payloadKey != 'overAll')
              //     Container(
              //       margin: EdgeInsets.symmetric(horizontal: 5),
              //       width: 250,
              //       child: ListTile(
              //         leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
              //         title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
              //         trailing: Checkbox(
              //           value: i.show,
              //           onChanged: (value) {
              //             stateSetter(() {
              //               i.show = value!;
              //             });
              //           },
              //
              //         ),
              //       ),
              //     ),
              SizedBox(
                height: 10,
              ),
            ],
          );
        }
    );

  }
  void sideSheet({required constraints,required mode,configId}) {
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.generalParameterList : selectedIrrigationParameterArray.generalParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.generalParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.waterParameterList : selectedIrrigationParameterArray.waterParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.waterParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.filterParameterList : selectedIrrigationParameterArray.filterParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.filterParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.prePostParameterList : selectedIrrigationParameterArray.prePostParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.prePostParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralEcPhParameterList : selectedIrrigationParameterArray.centralEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralEcPhParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel1ParameterList : selectedIrrigationParameterArray.centralChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel1ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel2ParameterList : selectedIrrigationParameterArray.centralChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel2ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel3ParameterList : selectedIrrigationParameterArray.centralChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel3ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel4ParameterList : selectedIrrigationParameterArray.centralChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel4ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel5ParameterList : selectedIrrigationParameterArray.centralChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel5ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel6ParameterList : selectedIrrigationParameterArray.centralChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel6ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel7ParameterList : selectedIrrigationParameterArray.centralChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel7ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.centralChannel8ParameterList : selectedIrrigationParameterArray.centralChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.centralChannel8ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localEcPhParameterList : selectedIrrigationParameterArray.localEcPhParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localEcPhParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel1ParameterList : selectedIrrigationParameterArray.localChannel1ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel1ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel2ParameterList : selectedIrrigationParameterArray.localChannel2ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel2ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel3ParameterList : selectedIrrigationParameterArray.localChannel3ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel3ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel4ParameterList : selectedIrrigationParameterArray.localChannel4ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel4ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel5ParameterList : selectedIrrigationParameterArray.localChannel5ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel5ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel6ParameterList : selectedIrrigationParameterArray.localChannel6ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel6ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel7ParameterList : selectedIrrigationParameterArray.localChannel7ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel7ParameterList);
    setOriginalToDuplicateParameter(originalParameterList: mode == 1 ? irrigationParameterArray.localChannel8ParameterList : selectedIrrigationParameterArray.localChannel8ParameterList, duplicateParameterList: irrigationParameterArrayDuplicate.localChannel8ParameterList);

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
                  width: constraints.maxWidth,
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
                              if(logName.isEmpty){
                                stateSetter((){
                                  setState(() {
                                    errorMessage = 'Name should not be empty';
                                  });
                                });
                              }else{
                                stateSetter((){
                                  setState(() {
                                    errorMessage = '';
                                  });
                                });
                              }
                              if(errorMessage == ''){
                                if(mode == 1){
                                  createUserLogConfig(name: logName, configDetails: irrigationParameterArrayDuplicate.toJson());
                                }else if(mode == 2){
                                  updateUserLogConfig(id: configId, configDetails: irrigationParameterArrayDuplicate.toJson());
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Text("OK",style: TextStyle(color: Colors.white)),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    body: Form(
                      key: _formKey,
                      child: Container(
                        width: constraints.maxWidth,
                        padding: const EdgeInsets.all(15),
                        // margin: EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.zero,
                        ),
                        height: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 25),
                              Text('Give Log Config Name'),
                              SizedBox(
                                width: 250,
                                height: 40,
                                child: TextFormField(
                                  initialValue: logName,
                                  style: TextStyle(fontSize: 12),
                                  maxLength: 20,
                                  onChanged: (value){
                                    print('value => $value');
                                    stateSetter((){
                                      setState(() {
                                        logName = value;
                                      });
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      counterText: '',
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // You can set the color of the bottom border here
                                          width: 1.0, // You can adjust the width of the bottom border here
                                        ),
                                      )
                                  ),
                                ),
                              ),
                              Text(errorMessage,style: TextStyle(color: Colors.red),),
                              //General ---------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: Text('Genral Parameter',style: TextStyle(fontWeight: FontWeight.bold,color: primaryColorDark,fontSize: 20),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.generalParameterList[irrigationParameterArrayDuplicate.generalParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.generalParameterList[irrigationParameterArrayDuplicate.generalParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.generalParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.generalParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },

                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              //Water -----------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: Text('Water Parameter',style: TextStyle(fontWeight: FontWeight.bold),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.waterParameterList[irrigationParameterArrayDuplicate.waterParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.waterParameterList[irrigationParameterArrayDuplicate.waterParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.waterParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.waterParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },

                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              //filter -----------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: Text('Filter Parameter',style: TextStyle(fontWeight: FontWeight.bold),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.filterParameterList[irrigationParameterArrayDuplicate.filterParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.filterParameterList[irrigationParameterArrayDuplicate.filterParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.filterParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.filterParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },

                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              //Pre Post -----------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: Text('Pre Post Parameter',style: TextStyle(fontWeight: FontWeight.bold),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.prePostParameterList[irrigationParameterArrayDuplicate.prePostParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.prePostParameterList[irrigationParameterArrayDuplicate.prePostParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.prePostParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.prePostParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },

                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              //Central-----------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: const Text('Central Parameters',style: TextStyle(fontWeight: FontWeight.bold),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.centralEcPhParameterList[irrigationParameterArrayDuplicate.centralEcPhParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.centralEcPhParameterList[irrigationParameterArrayDuplicate.centralEcPhParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.centralEcPhParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.centralEcPhParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },

                                              ),
                                            ),
                                          ),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel1ParameterList, channelNo: 1,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel2ParameterList, channelNo: 2,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel3ParameterList, channelNo: 3,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel4ParameterList, channelNo: 4,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel5ParameterList, channelNo: 5,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel6ParameterList, channelNo: 6,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel7ParameterList, channelNo: 7,central: true),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.centralChannel8ParameterList, channelNo: 8,central: true),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              //Local-----------------------------
                              Column(
                                children: [
                                  ListTile(
                                    title: const Text('Local Parameters',style: TextStyle(fontWeight: FontWeight.bold),),
                                    leading: Checkbox(
                                      value: irrigationParameterArrayDuplicate.localEcPhParameterList[irrigationParameterArrayDuplicate.localEcPhParameterList.length - 1].show,
                                      onChanged: (bool? value) {
                                        stateSetter(() {
                                          irrigationParameterArrayDuplicate.localEcPhParameterList[irrigationParameterArrayDuplicate.localEcPhParameterList.length - 1].show = value!;
                                          for(var p in irrigationParameterArrayDuplicate.localEcPhParameterList){
                                            p.show = value;
                                          }
                                        });

                                      },
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      for(var i in irrigationParameterArrayDuplicate.localEcPhParameterList)
                                        if(i.payloadKey != 'overAll')
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            width: 250,
                                            child: ListTile(
                                              leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                                              title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                                              trailing: Checkbox(
                                                value: i.show,
                                                onChanged: (value) {
                                                  stateSetter(() {
                                                    i.show = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel1ParameterList, channelNo: 1,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel2ParameterList, channelNo: 2,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel3ParameterList, channelNo: 3,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel4ParameterList, channelNo: 4,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel5ParameterList, channelNo: 5,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel6ParameterList, channelNo: 6,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel7ParameterList, channelNo: 7,central: false),
                                      getChannelFilter( parameterList: irrigationParameterArrayDuplicate.localChannel8ParameterList, channelNo: 8,central: false),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: Divider(
                                      thickness: 0.5,
                                      color: primaryColorDark,
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(
                                height: 50,
                              ),

                            ],
                          ),
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
