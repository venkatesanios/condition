import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';

class GlobalAlarmInConstant extends StatefulWidget {
  const GlobalAlarmInConstant({super.key});

  @override
  State<GlobalAlarmInConstant> createState() => _GlobalAlarmInConstantState();
}

class _GlobalAlarmInConstantState extends State<GlobalAlarmInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return LayoutBuilder(
        builder: (context,constraints){
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: const Color(0xfff3f3f3),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      for(var i = 0;i < constantPvd.globalAlarmUpdated.length;i++)
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          width: constraints.maxWidth < 300 ? (constraints.maxWidth - 10) : 300,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           color: Colors.white
                         ),
                         padding: EdgeInsets.all(10),
                         child: ListTile(
                           title: Text('${constantPvd.globalAlarmUpdated[i]['name']}'),
                           trailing: IntrinsicWidth(
                             child: Switch(
                               value: constantPvd.globalAlarmUpdated[i]['value'],
                               onChanged: (value){
                                 constantPvd.globalAlarmFunctionality(i);
                               },
                             ),
                           ),
                         ),
                        )
                    ],
                  )
                ),
                SizedBox(height: 100,)
              ],
            ),
          );
        }
    );
  }
}
