import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/MqttPayloadProvider.dart';

class IrrigationPumpList extends StatefulWidget {
  const IrrigationPumpList({Key? key}) : super(key: key);

  @override
  State<IrrigationPumpList> createState() => _IrrigationPumpListState();
}

class _IrrigationPumpListState extends State<IrrigationPumpList> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);

    return provider.irrigationPump.isNotEmpty? SizedBox(
      width: 70,
      height: provider.irrigationPump.length * 70,
      child: ListView.builder(
        itemCount: provider.irrigationPump.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < provider.irrigationPump.length) {
            return provider.irrigationPump[index]['OnDelayLeft'] !='00:00:00'? Stack(
              children: [
                PopupMenuButton(
                  tooltip: 'Details',
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(provider.irrigationPump[index]['Name'], style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: buildIrPumpImage(index, provider.irrigationPump[index]['Status'], provider.irrigationPump.length),
                ),
                Positioned(
                  top: 0,
                  left: 12,
                  child: CircleAvatar(radius: 23, backgroundColor: Colors.orange, child: Text(provider.irrigationPump[index]['OnDelayLeft'], style: const TextStyle(fontSize: 10),),),
                ),
              ],
            ) :
            Column(
              children: [
                PopupMenuButton(
                  tooltip: 'Details',
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(provider.irrigationPump[index]['Name'], style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: buildIrPumpImage(index, provider.irrigationPump[index]['Status'], provider.irrigationPump.length),
                ),
              ],
            );
          } else {
            return const Text(''); // or any placeholder/error message
          }
        },
      ),
    ):
    const SizedBox();
  }

  Widget buildIrPumpImage(int cIndex, int status, int irPumpLength) {
    String imageName;
    if (irPumpLength == 1) {
      imageName = 'dp_irr_pump';
    } else if (irPumpLength == 2) {
      imageName = cIndex == 0 ? 'dp_irr_pump_1' : 'dp_irr_pump_3';
    } else {
      switch (irPumpLength) {
        case 3:
          imageName = cIndex == 0 ? 'dp_irr_pump_1' : (cIndex == 1 ? 'dp_irr_pump_2' : 'dp_irr_pump_3');
          break;
        case 4:
          imageName = cIndex == 0 ? 'dp_irr_pump_1' : (cIndex == 1 ? 'dp_irr_pump_2' : (cIndex == 2 ? 'dp_irr_pump_2' : 'dp_irr_pump_3'));
          break;
        default:
          imageName = 'dp_irr_pump_3';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.gif';
        break;
      case 2:
        imageName += '_y.gif';
        break;
      default:
        imageName += '_r.gif';
    }

    if(imageName.contains('.png')){
      return Image.asset('assets/images/$imageName');
    }
    return Image.asset('assets/GifFile/$imageName');
  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.irrigationPump.length; i++) {
          if(provider.irrigationPump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.irrigationPump[i]['OnDelayLeft'].split(':');
            int hours = int.parse(parts[0]);
            int minutes = int.parse(parts[1]);
            int seconds = int.parse(parts[2]);

            if (seconds > 0) {
              seconds--;
            } else {
              if (minutes > 0) {
                minutes--;
                seconds = 59;
              } else {
                if (hours > 0) {
                  hours--;
                  minutes = 59;
                  seconds = 59;
                }
              }
            }

            String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            if(provider.irrigationPump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.irrigationPump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }
}

