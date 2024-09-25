import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/config/constant/general_in_constant.dart';
import 'package:provider/provider.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/overall_use.dart';
import 'ListOfFertilizerInSet.dart';

class Calibration extends StatefulWidget {
  final int userId;
  final int controllerId;
  final String deviceId;
  const Calibration({super.key, required this.userId, required this.controllerId, required this.deviceId});

  @override
  State<Calibration> createState() => _CalibrationState();
}
enum CalibrationTab { max, factor}

class _CalibrationState extends State<Calibration> {
  CalibrationTab selectedTab = CalibrationTab.max;
  bool httpError = false;
  int wantToSendData = 0;
  dynamic calibrationData;
  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }
  void getData()async{
    try{
      HttpService service = HttpService();
      var getCalibrationData = await service.postRequest('getUserCalibration', {'userId' : widget.userId,'controllerId' : widget.controllerId});
      var jsonData = jsonDecode(getCalibrationData.body);
      if(jsonData['code'] == 200){
        setState(() {
          calibrationData = jsonData['data'];
        });
        print('calibrationData => $calibrationData');
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calibration'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: ()async{
          showDialog(context: context, builder: (context){
            return StatefulBuilder(builder: (context,StateSetter stateSetter){
              return AlertDialog(
                title: Text(wantToSendData == 0
                    ? 'Send to server' : wantToSendData == 1
                    ?  'Sending.....' : wantToSendData == 2
                    ? 'Success...' : wantToSendData == 3
                    ? 'Server Error' : wantToSendData == 4
                    ? 'Mqtt Error' : 'Code Error',style: TextStyle(color: (wantToSendData == 3 || wantToSendData == 4) ? Colors.red : Colors.green),),
                content: wantToSendData == 0
                    ? Text('Are you sure want to send data ? ')
                    : SizedBox(
                  width: 200,
                  height: 200,
                  child: wantToSendData == 2
                      ? Image.asset('assets/images/success.png')
                      : wantToSendData == 3
                      ? Image.asset('assets/images/serverError.png')
                      : wantToSendData == 4
                      ? Image.asset('assets/images/mqttError.png')
                      :LoadingIndicator(
                    indicatorType: Indicator.pacman,
                  ),
                ),
                actions: [
                  if(wantToSendData == 0)
                    InkWell(
                      onTap: ()async{
                        stateSetter((){
                          setState(() {
                            wantToSendData = 1;
                          });
                        });

                        try{
                          HttpService service = HttpService();
                          var response = await service.postRequest('createUserCalibration', {
                            'userId' : widget.userId,
                            'controllerId' : widget.controllerId,
                            'createUser' : widget.userId,
                            'calibration' : calibrationData,
                          });
                          var jsonData = jsonDecode(response.body);
                          if(jsonData['code']  == 200){
                            setState(() {
                              wantToSendData = 2;
                            });
                          }
                          else{
                            stateSetter((){
                              setState(() {
                                wantToSendData = 3;
                              });
                            });

                          }
                          try{
                            var hwData = {
                              "4600" : [
                                {
                                  "4601" : ''
                                }
                              ]
                            };
                            var payloadWithOutWeather = '';
                            var payloadWithWeather = '';
                            for(var i in calibrationData){
                              for(var j in i['calibration']){
                                print('id => ${j['id']}   ${j['hid']}');
                                if(j['hid'].contains('.W.')){
                                  payloadWithWeather += '${payloadWithWeather.isNotEmpty ? ';' : ''}'
                                      '${j['sNo']},${j['calibrationFactor'].isEmpty ? 1.0 : j['calibrationFactor']},${j['maximumValue'].isEmpty ? 1.0 : j['maximumValue']}';
                                }else{
                                  payloadWithOutWeather += '${payloadWithOutWeather.isNotEmpty ? ';' : ''}'
                                      '${j['sNo']},${j['calibrationFactor'].isEmpty ? 1.0 : j['calibrationFactor']},${j['maximumValue'].isEmpty ? 1.0 : j['maximumValue']}';
                                }

                              }
                            }
                            // maximumValue
                            // calibrationFactor

                            MQTTManager().publish(jsonEncode({
                              "4600" : [
                                {"4601" : payloadWithOutWeather},
                                {"4602" : payloadWithWeather},
                                {"4603" : widget.userId.toString()},
                              ]
                            }),'AppToFirmware/${widget.deviceId}');
                            stateSetter((){
                              setState(() {
                                wantToSendData = 2;
                              });
                            });

                          }catch(e){
                            stateSetter((){
                              setState(() {
                                wantToSendData = 4;
                              });
                            });

                          }
                        }catch(e,stackTrace){
                          print('code error may be server : ${e.toString()}');
                          print('code error stackTrace : ${stackTrace}');
                          stateSetter((){
                            setState(() {
                              wantToSendData = 5;
                            });
                          });

                        }
                      },
                      child: Container(
                        child: Center(
                          child: Text('Yes',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    ),
                  if([2,3,4].contains(wantToSendData))
                    InkWell(
                      onTap: (){
                        setState(() {
                          wantToSendData = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Center(
                          child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    )
                ],
              );
            });


          });
        },
      ),
      body: LayoutBuilder(builder: (context,constraint){
        if(calibrationData == null){
          return Container();
        }
        return SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20,),
              SegmentedButton<CalibrationTab>(
                segments: const <ButtonSegment<CalibrationTab>>[
                  ButtonSegment<CalibrationTab>(
                      value: CalibrationTab.max,
                      label: Text('Maximum'),
                      icon: Icon(Icons.calendar_view_day)),
                  ButtonSegment<CalibrationTab>(
                      value: CalibrationTab.factor,
                      label: Text('Factor'),
                      icon: Icon(Icons.calendar_view_week)),
                ],
                selected: <CalibrationTab>{selectedTab},
                onSelectionChanged: (Set<CalibrationTab> newSelection) {
                  setState(() {
                    selectedTab = newSelection.first;
                  });
                },
              ),
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        if(selectedTab == CalibrationTab.max)
                          for(var i in calibrationData)
                            if([20,21].contains(i['nameTypeId']))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      color: primaryColorDark,
                                      width: double.infinity,
                                      height: 35,
                                      child: Center(child: Text('${i['nameDescription']}',style: TextStyle(color: Colors.white),))
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Wrap(
                                    children: [
                                      for(var j in i['calibration'])
                                        filtering(j: j),
                                    ],
                                  )
                                ],
                              ),
                        if(selectedTab == CalibrationTab.factor)
                          for(var i in calibrationData)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    color: primaryColorDark,
                                    width: double.infinity,
                                    height: 35,
                                    child: Center(child: Text('${i['nameDescription']}',style: TextStyle(color: Colors.white),))
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Wrap(
                                  children: [
                                    for(var j in i['calibration'])
                                      filtering(j: j),
                                  ],
                                ),
                              ],
                            ),
                        SizedBox(height: 50,)

                      ],
                    ),
                  )
              ),

            ],
          ),
        );
      }),
    );
  }
  Widget filtering({required j}){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20,left: 8,right: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: customBoxShadow
      ),
      child: ListTile(
        leading: Icon(Icons.device_thermostat,color: Colors.red,),
        title: Text('${j['name']}',style: TextStyle(color: primaryColorDark,fontSize: 13,fontWeight: FontWeight.bold),),
        trailing: Transform.scale(
          scale: 0.8,
          child: SizedBox(
              width: 100,
              height: 60,
              child: selectedTab == CalibrationTab.max
                  ? MaxCalibrationTextField(
                initialValue: j['maximumValue'],
                onChanged: (value){
                  setState(() {
                    j['maximumValue'] = value;
                  });
                },
              ) : FactorCalibrationTextField(
                initialValue: j['calibrationFactor'],
                onChanged: (value){
                  setState(() {
                    j['calibrationFactor'] = value;
                  });
                },
              )
          ),
        ),
      ),
    );
  }
}



class MaxCalibrationTextField extends StatefulWidget {
  String initialValue;
  final void Function(String)? onChanged;
  MaxCalibrationTextField({super.key, required this.initialValue, this.onChanged});
  @override
  State<MaxCalibrationTextField> createState() => _MaxCalibrationTextFieldState();
}

class _MaxCalibrationTextFieldState extends State<MaxCalibrationTextField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    controller.text = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 6,
      inputFormatters: regexForDecimal,
      controller: controller,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder()
      ),
      onChanged: widget.onChanged,
    );
  }
}

class FactorCalibrationTextField extends StatefulWidget {
  String initialValue;
  final void Function(String)? onChanged;
  FactorCalibrationTextField({super.key, required this.initialValue, this.onChanged});
  @override
  State<FactorCalibrationTextField> createState() => _FactorCalibrationTextFieldState();
}

class _FactorCalibrationTextFieldState extends State<FactorCalibrationTextField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    controller.text = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 6,
      inputFormatters: regexForDecimal,
      controller: controller,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder()
      ),
      onChanged: widget.onChanged,
    );
  }

}



