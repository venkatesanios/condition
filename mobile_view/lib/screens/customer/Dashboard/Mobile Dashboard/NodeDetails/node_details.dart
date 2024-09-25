import "dart:convert";

import "package:flutter/material.dart";
import "../../../../../constants/MQTTManager.dart";
import "../../../../../constants/app_image.dart";
import "../../../../../state_management/MqttPayloadProvider.dart";
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import "../../../Planning/NewIrrigationProgram/schedule_screen.dart";

Future<void>showNodeDetailsBottomSheet({required BuildContext context}) async{
  final payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return  SizedBox(
        height: 600,
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
              surfaceTintColor: Colors.white,
              margin: EdgeInsets.zero,
              child: ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                ),
                tileColor: Theme.of(context).primaryColor,
                textColor: Colors.white,
                title: const Text('All Node Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                trailing: Icon(Icons.view_agenda, color: Colors.white,),
                // trailing: PopupMenuButton<String>(
                //   icon: const Icon(Icons.filter_list, color: Colors.white,),
                //   onSelected: (value) {
                //     print('Filter option selected: $value');
                //   },
                //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                //     const PopupMenuItem<String>(
                //       value: 'Sort by Active relay',
                //       child: Text('Sort by Active relays'),
                //     ),
                //     const PopupMenuItem<String>(
                //       value: 'Sort by In-Active relays',
                //       child: Text('Sort by In-Active relays'),
                //     ),
                //     const PopupMenuItem<String>(
                //       value: 'Others',
                //       child: Text('Others'),
                //     ),
                //   ],
                // ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  for (int i = 0; i < payloadProvider.nodeData.length; i++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(),
                          surfaceTintColor: cardColor,
                          color: cardColor,
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 10,
                              backgroundColor: payloadProvider.nodeData[i].status == 1
                                  ? Colors.green.shade400
                                  : payloadProvider.nodeData[i].status == 2
                                  ? Colors.grey
                                  : payloadProvider.nodeData[i].status == 3
                                  ? Colors.redAccent
                                  : payloadProvider.nodeData[i].status == 4
                                  ? Colors.yellow
                                  : Colors.grey,
                            ),
                            tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            title: Text('${payloadProvider.nodeData[i].deviceName}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${payloadProvider.nodeData[i].deviceId}', style: TextStyle(fontWeight: FontWeight.w300)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.solar_power_outlined),
                                const SizedBox(width: 5,),
                                Text('${payloadProvider.nodeData[i].slrVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                const SizedBox(width: 5,),
                                const Icon(Icons.battery_3_bar_rounded),
                                Text('${payloadProvider.nodeData[i].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                const SizedBox(width: 5,),
                                IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                  String payLoadFinal = jsonEncode({
                                    "2300": [
                                      {"2301": "${payloadProvider.nodeData[i].serialNumber}"},
                                    ]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${payloadProvider.nodeData[i].deviceId}');
                                }, icon: const Icon(Icons.fact_check_outlined))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: payloadProvider.nodeData[i].rlyStatus.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                ),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: cardColor,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          // backgroundColor: Colors.transparent,
                                          child: payloadProvider.nodeData[i].rlyStatus[index].name!.contains("SP") ?
                                          Image.asset('assets/images/source_pump1.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("IP") ?
                                          Image.asset('assets/images/source_pump1.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("VL") ?
                                          Image.asset('assets/images/valve.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("MV") ?
                                          Image.asset('assets/images/m_valve.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("FL") ?
                                          Image.asset('assets/images/central_filtration_site.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("FC") ?
                                          Image.asset('assets/images/channel.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("FG") ?
                                          Image.asset('assets/images/fogger1.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("FB") ?
                                          Image.asset('assets/images/booster_pump1.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("AG") ?
                                          SvgPicture.asset('assets/images/agitator_o.svg'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("DV") ?
                                          Image.asset('assets/images/downstream_valve.svg'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("SL") ?
                                          Image.asset('assets/images/selector.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("FN") ?
                                          Image.asset('assets/images/fan.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("LI") ?
                                          Image.asset('assets/images/pressure_sensor.png'):
                                          payloadProvider.nodeData[i].rlyStatus[index].name!.contains("LO") ?
                                          Image.asset('assets/images/pressure_sensor.png'):
                                          Image.asset('assets/images/pressure_sensor.png'),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            radius: 5,
                                            backgroundColor: Colors.grey,
                                          ),
                                          const SizedBox(width: 3),
                                          Text('${payloadProvider.nodeData[i].rlyStatus[index].name!}(${payloadProvider.nodeData[i].rlyStatus[index].rlyNo})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  for(var index = 0; index < payloadProvider.nodeData[i].sensor.length; index++)
                                    Container(
                                      width: 50,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 45,
                                            child: Stack(
                                              children: [
                                                AppImages.getAsset('sensor',0, payloadProvider.nodeData[i].sensor[index].name!),
                                                Positioned(
                                                  top: 30,
                                                  left: 0,
                                                  child: Container(width: 40, height: 14,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        color: Colors.yellow,
                                                      ),
                                                      child: Center(child: Text('${payloadProvider.nodeData[i].sensor[index].value}', style: const TextStyle(color: Colors.black, fontSize: 10)))
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(payloadProvider.nodeData[i].sensor[index].name!, style: const TextStyle(color: Colors.black, fontSize: 10)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}