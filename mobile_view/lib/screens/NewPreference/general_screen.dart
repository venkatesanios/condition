import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preference_provider.dart';
import '../../ListOfFertilizerInSet.dart';
import '../../widget/SCustomWidgets/custom_list_tile.dart';
import '../customer/Planning/NewIrrigationProgram/schedule_screen.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final preferenceProvider = Provider.of<PreferenceProvider>(context, listen: true);
    final generalData = preferenceProvider.generalData;
    String tempControllerName = '';
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: [
              const SizedBox(height: 10,),
              Card(
                margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 700 ? 20 : 200, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                surfaceTintColor: cardColor,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        generalData != null ? generalData.controllerName : '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: customBoxShadow
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 700 ? 20 : 200, vertical: 10),
                child: Column(
                  children: [
                    for(var index = 0; index < 4; index++)
                      CustomTile(
                        title: ['TYPE', 'SERIAL NUMBER', 'CONTROLLER NAME', 'AFFILIATE'][index],
                        content: [Icons.type_specimen_rounded, Icons.format_list_numbered_rounded, Icons.perm_device_info, Icons.account_box_rounded,][index],
                        showSubTitle: true,
                        subtitle: [
                          generalData != null ? generalData.categoryName : '',
                          generalData != null ? generalData.deviceId.toString() : '',
                          generalData != null ? generalData.controllerName : '',
                          generalData != null ? generalData.userName : '',
                        ][index],
                        trailing: index == 2
                            ? InkWell(
                          child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                          onTap: () {
                            _textEditingController.text = generalData!.controllerName;
                            _textEditingController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _textEditingController.text.length,
                            );
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Edit Controller name"),
                                content: TextFormField(
                                  controller: _textEditingController,
                                  autofocus: true,
                                  onChanged: (newValue) => tempControllerName = newValue,
                                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      setState(() {
                                        generalData.controllerName = tempControllerName;
                                      });
                                    },
                                    child: const Text("OKAY", style: TextStyle(color: Colors.green),),
                                  ),
                                ],
                              ),
                            );
                          },
                        ) : null,
                      ),
                  ],
                ),
              ),
            ],
          );
        }
    );
  }
}
