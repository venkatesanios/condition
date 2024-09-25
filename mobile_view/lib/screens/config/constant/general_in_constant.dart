import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../FertilizerSet.dart';
import '../../../ListOfFertilizerInSet.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/HoursMinutesSeconds.dart';
import '../../../widget/drop_down_button.dart';
import '../../../widget/text_form_field_constant.dart';

class GeneralInConst extends StatefulWidget {
  const GeneralInConst({super.key});

  @override
  State<GeneralInConst> createState() => _GeneralInConstState();
}

class _GeneralInConstState extends State<GeneralInConst> {
  dynamic generalHideShow = {
    'Reset Time' : false,
    'Fertilizer Leakage Limit' : false,
    'Run List Limit' : false,
    'No Pressure Delay' : false,
    'Water pulse before dosing' : false,
    'Common dosing coefficient' : false,
    'Lora Key 1' : true,
    'Lora Key 2' : true,
  };

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(
        builder: (context,constraints){
          return Container(
            color: const Color(0xfff3f3f3),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: const EdgeInsets.all(8),
            child: customizeGridView(
                maxWith: 280,
                maxheight: 60,
                screenWidth: constraints.maxWidth - 20,
                listOfWidget: [
                  for(var i = 0;i < constantPvd.generalUpdated.length;i++)
                    if(generalHideShow[constantPvd.generalUpdated[i]['name']])
                      getYourWidgetGeneral(context: context, index: i, type: constantPvd.generalUpdated[i]['type'])
                ]
            ),
          );
        }
    );
  }
}

String getHmsFormat(OverAllUse overAllPvd){
  return '${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}';
}

Widget getCardWidget({
  required BuildContext context,
  required Widget child,
}){
  return Container(
    width: 250,
    height: 60,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: customBoxShadow,
        color: Colors.white
    ),
    child: child,
  );
}

void alertBoxForTimer({
  required BuildContext context,
  required String initialTime,
  required Function() onTap,
}){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('Select Time'),
          content: HoursMinutesSeconds(
            initialTime: initialTime,
            onPressed: onTap,
          ),
        );
      }
  );
}

Widget getYourWidgetGeneral({
  required BuildContext context,
  required int index,
  required int type
}){
  var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  if(type == 1){
    return getCardWidget(
      context: context,
      child: ListTile(
          leading: const Icon(Icons.adb_outlined),
          title: Text(constantPvd.generalUpdated[index]['name'],style: cardTitle,),
          trailing: SizedBox(
              width: 50,
              height: 40,
              child: TextFieldForConstant(
                initialValue: constantPvd.generalUpdated[index]['value'],
                inputFormatters: regexForNumbers,
                onChanged: (value){
                  constantPvd.generalUpdatedFunctionality(index, value);
                },
              )
          )
      ),
    );
  }else if(type == 2){
    return getCardWidget(
      context: context,
      child: ListTile(
          leading: const Icon(Icons.adb_outlined),
          title: Text(constantPvd.generalUpdated[index]['name'],style: cardTitle),
          trailing: MyDropDown(
            initialValue: constantPvd.generalUpdated[index]['value'],
            itemList: yesNoList,
            onItemSelected: (value){
              constantPvd.generalUpdatedFunctionality(index, value);
            },
          )
      ),
    );
  }else if(type == 3){
    return getCardWidget(
      context: context,
      child: InkWell(
        onTap: (){
          alertBoxForTimer(
              context: context,
              initialTime: constantPvd.generalUpdated[index]['value'],
              onTap: (){
                constantPvd.generalUpdatedFunctionality(index, getHmsFormat(overAllPvd));
                Navigator.pop(context);
              }
          );
        },
        child: ListTile(
            leading: const Icon(Icons.adb_outlined),
            title: Text(constantPvd.generalUpdated[index]['name'],style: cardTitle),
            trailing: Text(constantPvd.generalUpdated[index]['value'])
        ),
      ),
    );
  }else{
    return const Text('Empty Widget');
  }

}

dynamic regexForNumbers = [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
dynamic regexForDecimal = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),];
TextStyle cardTitle = const TextStyle(fontSize: 13);
List<String> yesNoList = ['Yes','No'];