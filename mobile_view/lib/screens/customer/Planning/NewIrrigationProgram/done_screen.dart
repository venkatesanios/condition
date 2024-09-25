import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../widget/SCustomWidgets/custom_native_time_picker.dart';
import 'conditions_screen.dart';

class AdditionalDataScreen extends StatefulWidget {
  final int serialNumber;
  final bool isIrrigationProgram;
  const AdditionalDataScreen({super.key, required this.serialNumber, required this.isIrrigationProgram});

  @override
  State<AdditionalDataScreen> createState() => _AdditionalDataScreenState();
}

class _AdditionalDataScreenState extends State<AdditionalDataScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String tempProgramName = '';
  @override
  Widget build(BuildContext context) {
    final doneProvider = Provider.of<IrrigationProgramMainProvider>(context);
    String programName = doneProvider.programName == ''? "Program ${doneProvider.programCount}" : doneProvider.programName;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.025),
            child: ListView(
              children: [
                for(var index = 0; index < (widget.isIrrigationProgram ? 4 : 3); index++)
                  Column(
                    children: [
                      buildListTile(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                        context: context,
                        title: ['Program Name', 'Priority', 'Delay Between Zones', 'scale factor'][index].toUpperCase(),
                        subTitle: [tempProgramName != '' ? tempProgramName : widget.serialNumber == 0
                            ? "Program ${doneProvider.programCount}"
                            : doneProvider.programDetails!.programName.isNotEmpty ? programName : doneProvider.programDetails!.defaultProgramName,
                          'Prioritize the program to run', 'Set the delay between each zones', 'Set the value to adjust'][index],
                        textColor: Colors.black,
                        icon: [Icons.drive_file_rename_outline_rounded, Icons.priority_high, Icons.timer_outlined, Icons.safety_check][index],
                        trailing: [
                          InkWell(
                            child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                            onTap: () {
                              _textEditingController.text = widget.serialNumber == 0
                                  ? "Program ${doneProvider.programCount}"
                                  : doneProvider.programDetails!.programName.isNotEmpty ? programName : doneProvider.programDetails!.defaultProgramName;
                              _textEditingController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _textEditingController.text.length,
                              );
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Edit program name"),
                                  content: TextFormField(
                                    autofocus: true,
                                    controller: _textEditingController,
                                    onChanged: (newValue) => tempProgramName = newValue,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(20),
                                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        doneProvider.updateProgramName(tempProgramName, 'programName');
                                      },
                                      child: const Text("OKAY", style: TextStyle(color: Colors.green),),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          buildPopUpMenuButton(
                              context: context,
                              dataList: doneProvider.priorityList.map((item) => item).toList(),
                              onSelected: (newValue) => doneProvider.updateProgramName(newValue, 'priority'),
                              selected: doneProvider.priority,
                              child: Text(doneProvider.priority, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),)
                          ),
                          CustomNativeTimePicker(
                            initialValue: doneProvider.delayBetweenZones != "" ? doneProvider.delayBetweenZones : "00:00:00",
                            is24HourMode: false,
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                            onChanged: (newTime){
                              doneProvider.updateProgramName(newTime, 'delayBetweenZones');
                            },
                          ),
                          SizedBox(
                            width: 65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 50 ,
                                  child: TextFormField(
                                    initialValue: doneProvider.adjustPercentage != "" ? doneProvider.adjustPercentage : "100",
                                    decoration: const InputDecoration(
                                      hintText: '0%',
                                    ),
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    onChanged: (newValue){
                                      doneProvider.updateProgramName(newValue, 'adjustPercentage');
                                    },
                                  ),
                                ),
                                Text("%", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),)
                              ],
                            ),
                          )
                        ][index],
                      ),
                      const SizedBox(height: 45,)
                    ],
                  ),
              ],
            ),
          );
        }
    );
  }
}