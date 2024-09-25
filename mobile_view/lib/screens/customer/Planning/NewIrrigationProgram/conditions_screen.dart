import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../ListOfFertilizerInSet.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../conditionscreen.dart';

class ConditionsScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  final String deviceId;
  const ConditionsScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber, required this.deviceId});

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  late IrrigationProgramMainProvider irrigationProgramProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: true);
    final iconList = [Icons.start, Icons.stop, Icons.toggle_on, Icons.toggle_off];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.025),
          child: ListView(
            // padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : EdgeInsets.zero,
            children: [
              const SizedBox(height: 10,),
              const Center(child: Text('SELECT CONDITION FOR PROGRAM')),
              const SizedBox(height: 10),
              ...irrigationProgramProvider.sampleConditions!.condition.asMap().entries.map((entry) {
                final conditionTypeIndex = entry.key;
                final condition = entry.value;
                final title = condition.title;
                // final iconCode = condition.iconCodePoint;
                // final iconFontFamily = condition.iconFontFamily;
                // final value = condition.value != '' ? condition.value : false;
                final selected = condition.selected;

                return Column(
                  children: [
                    buildListTile(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                        context: context,
                        title: title,
                        subTitle: '${(irrigationProgramProvider.sampleConditions!.condition[conditionTypeIndex].value['name'] != null)
                            ? irrigationProgramProvider.sampleConditions!.condition[conditionTypeIndex].value['name']
                            : 'Tap to select condition'}',
                        textColor: selected ? Colors.black : Colors.grey,
                        icon: iconList[conditionTypeIndex],
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (newValue){
                            irrigationProgramProvider.updateConditionType(newValue, conditionTypeIndex);
                          },
                        ),
                        onTap: () {
                          if(selected) {
                            showAdaptiveDialog(
                                context: context,
                                builder: (BuildContext dialogContext) => Consumer<IrrigationProgramMainProvider>(
                                  builder: (context, conditionsProvider, child) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      content: Container(
                                        height: 350,
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: conditionsProvider.sampleConditions!.defaultData.conditionLibrary.asMap().entries.map((conditions) {
                                                final conditionName = conditions.value.name;
                                                final conditionSno = conditions.value.sNo;
                                                final subTitle =  '${conditions.value.dropdown1}, ${conditions.value.dropdown2} ,${(conditions.value.dropdown1.contains('Analog') == true || conditions.value.dropdown1.contains('Program') == true || conditions.value.dropdown1.contains('Moisture') == true || conditions.value.dropdown1.contains('Level') == true) ? '' : conditions.value.dropdown3 } ${(conditions.value.dropdown1.contains('Analog') == true || conditions.value.dropdown1.contains('Program') == true || conditions.value.dropdown1.contains('Moisture') == true || conditions.value.dropdown1.contains('Level') == true  || conditions.value.dropdown1.contains('Combined') == true) ? conditions.value.dropdownValue : ''  }';

                                                // var conditionNameIndex = conditions.key;
                                                return RadioListTile(
                                                  title: Text(conditionName),
                                                  subtitle: Text(subTitle),
                                                  value: conditionName,
                                                  groupValue: conditionsProvider.sampleConditions!.condition[conditionTypeIndex].value['name'],
                                                  onChanged: (newValue) {
                                                    // print(conditionSno);
                                                    conditionsProvider.updateConditions(title, conditionSno, newValue, conditionTypeIndex);
                                                    Future.delayed(Duration(milliseconds: 500), () {
                                                      Navigator.of(context).pop();
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        FilledButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (BuildContext context) => ConditionScreen(userId: widget.userId, controllerId: widget.controllerId, deviceID: widget.deviceId, isProgram: true, serialNumber: widget.serialNumber,))
                                              );
                                            },
                                            child: Text("Edit Conditions")
                                        )
                                      ],
                                      actionsAlignment: MainAxisAlignment.center,
                                    );
                                  },
                                )
                            );
                          }
                        }
                    ),
                    const SizedBox(height: 45,)
                  ],
                );
              })
            ],
          ),
        );
      },
    );
  }
}

Widget buildListTile({
  required BuildContext context,
  required String title,
  Color? textColor,
  FontWeight? fontWeight,
  Color? color,
  subTitle,
  IconData? icon,
  String? leading,
  Widget? trailing,
  bool showLeading = true,
  void Function()? onTap,
  EdgeInsets? padding,
  bool isNeedBoxShadow = true,
  Widget? titleChild
}) {
  return Container(
    // margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color ?? Colors.white,
        boxShadow: isNeedBoxShadow ? customBoxShadow : null
    ),
    child: ListTile(
      title: titleChild ?? Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold),),
      subtitle: subTitle != null ? Text(subTitle, style: TextStyle(color: textColor),) : null,
      horizontalTitleGap: 30,
      leading: showLeading ? CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: leading != null ? Text(leading, style: const TextStyle(color: Colors.white),) : Icon(icon, color: Colors.white,),
      ): null,
      trailing: trailing,
      onTap: onTap,
    ),
  );
}
