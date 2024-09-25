import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:provider/provider.dart';

import '../../../../state_management/irrigation_program_main_provider.dart';

class NewAlarmScreen2 extends StatefulWidget {
  const NewAlarmScreen2({super.key});

  @override
  State<NewAlarmScreen2> createState() => _NewAlarmScreen2State();
}

class _NewAlarmScreen2State extends State<NewAlarmScreen2> {
  late IrrigationProgramMainProvider irrigationProgramMainProvider;

  @override
  void initState() {
    // TODO: implement initState
    irrigationProgramMainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramMainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: true);

    final iconList = [
      MdiIcons.gaugeLow,
      MdiIcons.gaugeFull,
      MdiIcons.gaugeEmpty,
      MdiIcons.qualityHigh,
      MdiIcons.thermometerLow,
      MdiIcons.thermometerHigh,
      MdiIcons.speedometerSlow,
      MdiIcons.speedometer,
      MdiIcons.powerPlugOff,
      MdiIcons.signalOff,
      Icons.wrong_location,
      MdiIcons.gaugeEmpty,
      MdiIcons.gaugeFull,
      MdiIcons.batteryLow,
      MdiIcons.delta,
      Icons.difference,
      MdiIcons.pumpOff,
      Icons.difference,
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MaterialButton(
              // color: Colors.greenAccent.shade100,
              // minWidth: MediaQuery.of(context).size.width - 40,
              textColor: Colors.white,
              elevation: 8,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              onPressed: () {
                print(irrigationProgramMainProvider.newAlarmList!.defaultAlarm.length);
                print(irrigationProgramMainProvider.newAlarmList!.alarmList.length);
                // setState(() {
                //   for(var i = 0; i < irrigationProgramMainProvider.newAlarmList!.alarmList.length; i++) {
                //     irrigationProgramMainProvider.newAlarmList!.alarmList[i].value = irrigationProgramMainProvider.newAlarmList!.defaultAlarm[i].value;
                //   }
                // });
              },
              child: Text("Use global alarm".toUpperCase()),
            ),
          ),
          SizedBox(height: 5,),
          Expanded(
            child: ListView.builder(
                itemCount: irrigationProgramMainProvider.newAlarmList!.alarmList.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = irrigationProgramMainProvider.newAlarmList!.alarmList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 5),
                    child: Column(
                      children: [
                        buildCustomListTile(
                            context: context,
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                            title: item.name,
                            icon: iconList[index],
                            // icon: Icons.alarm,
                            isSwitch: true,
                            switchValue: item.value,
                            onSwitchChanged: (newValue) {
                              setState(() {
                                item.value = newValue;
                              });
                            }
                        ),
                        SizedBox(height: index == irrigationProgramMainProvider.newAlarmList!.alarmList.length - 1 ? 80 : 10,)
                      ],
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
