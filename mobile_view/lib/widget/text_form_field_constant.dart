import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state_management/constant_provider.dart';

class TextFieldForConstant extends StatefulWidget {
  final List<TextInputFormatter> inputFormatters;
  String initialValue;
  int? index;
  ConstantProvider? constantPvd;
  String? purpose;
  Function(String)? onChanged;
  TextFieldForConstant({super.key,this.index,required this.initialValue,this.constantPvd, this.purpose, required this.inputFormatters,this.onChanged});

  @override
  State<TextFieldForConstant> createState() => _TextFieldForConstantState();
}

class _TextFieldForConstantState extends State<TextFieldForConstant> {
  late TextEditingController myController;
  FocusNode myFocus = FocusNode();
  bool isEditing = false;
  void initState() {
    // TODO: implement initState
    print("widget.initialValue : ${widget.initialValue}");
    myController = TextEditingController();
    myController.text = widget.initialValue;
    myFocus.addListener(() {
      if(myFocus.hasFocus == false){
        if(widget.purpose != null){
          var split = widget.purpose!.split('/');
          if(split[0] == 'valve_area'){
            if(myController.text.contains('.')){
              String format = '';
              bool dot = false;
              int afterDot = 1;
              for(var i in myController.text.split('')){
                if(dot == false){
                  format += i;
                  if(i == '.'){
                    dot = true;
                  }
                }
                if(dot == true){
                  if(afterDot == 2){
                    format += '0';
                    break;
                  }else{
                    if(i != '.'){
                      afterDot += 1;
                      format += i;
                    }
                  }
                }
              }
              setState(() {
                myController.text = format;
              });
              widget.constantPvd!.valveFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),format]);
            }else{
              widget.constantPvd!.valveFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),'${myController.text != '' ? '${myController.text}.00' : myController.text}']);
              myController.text = '${myController.text}.00';
            }
          }
        }

        toggleEditing();
      }
    });
    super.initState();

  }
  void toggleEditing() {
    setState(() {
      myController.text = widget.initialValue;
      isEditing = !isEditing;
      if (isEditing) {
        myFocus.requestFocus();
      }
      print('isEditing : $isEditing');
    });
  }

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return GestureDetector(
      onTap: toggleEditing,
      child: isEditing
          ? Container(
        width: 90,
        child: TextFormField(
          style: TextStyle(fontSize: 12),
          controller: myController,
          autofocus: true,
          focusNode: myFocus,
          inputFormatters: widget.inputFormatters,
          maxLength: 7,
          onChanged: widget.onChanged ?? (value){
            var split = widget.purpose!.split('/');
            if(split[0] == 'valve_nominal_flow'){
              constantPvd.valveFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'valve_minimum_flow'){
              constantPvd.valveFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'pumpRange'){
              constantPvd.pumpFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'topTankFeet'){
              constantPvd.pumpFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'valve_maximum_flow'){
              constantPvd.valveFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'valve_crop_factor'){
              constantPvd.valveFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'wm_ratio'){
              constantPvd.waterMeterFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'maximum_flow'){
              constantPvd.waterMeterFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'fertilizer_ratio'){
              constantPvd.fertilizerFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'fertilizer_nominalFlow'){
              constantPvd.fertilizerFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'ecPh_nominal_flow'){
              constantPvd.ecPhFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'analogSensor_minimum_v'){
              constantPvd.analogSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'analogSensor_maximum_v'){
              constantPvd.analogSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'moistureSensor_value'){
              constantPvd.moistureSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'moistureSensor_minimum_v'){
              constantPvd.moistureSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'moistureSensor_maximum_v'){
              constantPvd.moistureSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'levelSensor_value'){
              constantPvd.levelSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'levelSensor_minimum_v'){
              constantPvd.levelSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'levelSensor_maximum_v'){
              constantPvd.levelSensorFunctionality([split[0],int.parse(split[1]),value]);
            }else if(split[0] == 'alarm_threshold'){
              constantPvd.alarmFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'critical_alarm_threshold'){
              constantPvd.criticalAlarmFunctionality([split[0],int.parse(split[1]),int.parse(split[2]),value]);
            }else if(split[0] == 'ecPhDelta'){
              constantPvd.ecPhFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'ecPhFineTunning'){
              constantPvd.ecPhFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'ecPhCoarseTunning'){
              constantPvd.ecPhFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }else if(split[0] == 'ecPhDeadBand'){
              constantPvd.ecPhFunctionality([split[0],int.parse(split[1]),split[2],int.parse(split[3]),value]);
            }
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
        ),
      )
          : Container(
          margin: EdgeInsets.all(2),
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          height: double.infinity,
          child: Center(child: Text(widget.initialValue,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),))
      ),
    );
  }
}