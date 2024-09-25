import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:provider/provider.dart';

import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/FertilizerSetProvider.dart';
import 'ListOfFertilizerInSet.dart';
class FertilizerSetScreen extends StatefulWidget {
  const FertilizerSetScreen({super.key, required this.userId, required this.customerID, required this.controllerId, required this.deviceId});
  final int userId, controllerId, customerID;
  final String deviceId;

  @override
  State<FertilizerSetScreen> createState() => _FertilizerSetScreenState();
}

class _FertilizerSetScreenState extends State<FertilizerSetScreen> {
  ScrollController _scrollController = ScrollController();
  // TextEditingController name = TextEditingController();
  String name = 'Recipe Name';
  String message = '';
  int selectedRecipe = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getData();

      });
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getData()async{
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: false);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserPlanningFertilizerSet', {'userId' : overAllPvd.userId, 'controllerId' : overAllPvd.controllerId});
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      print(response.body);
      fertSetPvd.editRecipe(jsonData);

    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.send),
        onPressed: (){
          showDialog(context: context, builder: (context){
            return Consumer<FertilizerSetProvider>(builder: (context,fertSetPvd,child){
              return AlertDialog(
                title: Text(fertSetPvd.wantToSendData == 0 ? 'Send to server' : fertSetPvd.wantToSendData == 1 ?  'Sending.....' : fertSetPvd.wantToSendData == 2 ? 'Success...' : 'Oopss!!!',style: TextStyle(color: fertSetPvd.wantToSendData == 3 ? Colors.red : Colors.green),),
                content: fertSetPvd.wantToSendData == 0 ? Text('Are you sure want to send data ? ') : SizedBox(
                  width: 200,
                  height: 200,
                  child: fertSetPvd.wantToSendData == 2 ? Image.asset(fertSetPvd.wantToSendData == 3 ? 'assets/images/serverError.png' : 'assets/images/success.png') :LoadingIndicator(
                    indicatorType: Indicator.pacman,
                  ),
                ),
                actions: [
                  if(fertSetPvd.wantToSendData == 0)
                    InkWell(
                      onTap: ()async{
                        fertSetPvd.hwPayload();
                        fertSetPvd.editWantToSendData(1);
                        HttpService service = HttpService();
                        try{
                          var response = await service.postRequest('createUserPlanningFertilizerSet', {
                            'userId' : overAllPvd.userId,
                            'controllerId' : overAllPvd.controllerId,
                            'createUser' : overAllPvd.userId,
                            'fertilizerSet' : {
                              'autoIncrement' : fertSetPvd.autoIncrement,
                              'fertilizerSet' : fertSetPvd.listOfRecipe,
                            },
                          });
                          var jsonData = jsonDecode(response.body);
                          if(jsonData['code'] == 200){
                            Future.delayed(Duration(seconds: 1), () {
                              fertSetPvd.editWantToSendData(2);
                            });
                          }else{
                            fertSetPvd.editWantToSendData(3);
                          }
                          print('jsonData : ${jsonData['code']}');
                        }catch(e){
                          print(e.toString());
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
                  if([2,3].contains(fertSetPvd.wantToSendData))
                    InkWell(
                      onTap: (){
                        fertSetPvd.editWantToSendData(0);
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
      body: LayoutBuilder(builder: (context,constraints){
        return  CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fertilizer Library'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PopupMenuButton(
                            offset: Offset(10,50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.check_box_outline_blank,size: 20,),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                    onTap: (){
                                      fertSetPvd.editSelectFunction(1);
                                    },
                                    child: Text('Select')
                                ),
                                PopupMenuItem(
                                  child: Text('Select All'),
                                  onTap: (){
                                    fertSetPvd.fertilizerFunctionality(['selectAllFertilizer']);
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text('Remove Selection'),
                                  onTap: (){
                                    fertSetPvd.editSelectFunction(0);
                                  },
                                ),
                              ];
                            },

                          ),
                          if(fertSetPvd.selectFunction != 0 )
                            SizedBox(
                              width: 100,
                              height: 40,
                              child: Center(
                                child: myButtons(
                                    name: 'Delete',
                                    onTap: (){
                                      fertSetPvd.fertilizerFunctionality(['deleteFertilizer']);
                                    },
                                    fertSetPvd: fertSetPvd
                                ),
                              ),
                            ),
                          if(fertSetPvd.selectFunction == 0 )
                            SizedBox(
                              width: 100,
                              height: 40,
                              child: myButtons(
                                  name: 'Add',
                                  fertSetPvd: fertSetPvd,
                                  onTap: (){
                                    setState(() {
                                      name = 'Recipe Name';
                                      message = '';
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return StatefulBuilder(
                                            builder: (BuildContext context, StateSetter stateSetter) {
                                              return AlertDialog(
                                                title: Text('Create Reciepe'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextFormField(
                                                      initialValue: name,
                                                      decoration: InputDecoration(
                                                          border: OutlineInputBorder()
                                                      ),
                                                      onChanged: (value){
                                                        stateSetter((){
                                                          setState(() {
                                                            name = value;
                                                          });
                                                        });

                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(message,style: TextStyle(color: Colors.red,fontSize: 12),)
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: (){
                                                        bool create = true;
                                                        if(name == ''){
                                                          stateSetter((){
                                                            setState(() {
                                                              message = 'Name should not be empty';
                                                              create = false;
                                                            });
                                                          });

                                                        }
                                                        for(var i in fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe']){
                                                          print('name : ${i['name']}');
                                                          if(i['name'] == name){
                                                            stateSetter((){
                                                              setState(() {
                                                                message = 'Already the name is used. Try another name';
                                                                create = false;
                                                              });
                                                            });

                                                            break;
                                                          }
                                                        }
                                                        if(create == true){
                                                          fertSetPvd.addRecipe(name);
                                                          Navigator.pop(context);
                                                        }

                                                      },
                                                      child: Text('Create')
                                                  )
                                                ],
                                                // content: ListOfFertilizerInSet(
                                                //   index: fertSetPvd.selectedSite,
                                                //   recipeIndex: (fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length) - 1,
                                                //   length: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length,
                                                //   screenWidth: MediaQuery.of(context).size.width,
                                                //   screenHeight: MediaQuery.of(context).size.height,
                                                // ),
                                              );
                                            },
                                          );
                                        }
                                    );

                                  }
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                child: Text('List of Fertilizer Site',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 5,),
            ),
            if(fertSetPvd.listOfRecipe.length != 0)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(8),
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xffE6EDF5),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0;i < fertSetPvd.listOfRecipe.length;i++)
                          Row(
                            children: [
                              myButtons(
                                fertSetPvd: fertSetPvd,
                                index: i,
                                verticalPadding: 8,
                                radius: 15,
                                name: '${fertSetPvd.listOfRecipe[i]['name']}',
                                onTap: (){
                                  _scrollController.animateTo((i * (fertSetPvd.selectedSite > i ? (fertSetPvd.listOfRecipe[i]['name'].length * 3) : (fertSetPvd.listOfRecipe[i]['name'].length * 7))).toDouble(), duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                  fertSetPvd.editSite(i);
                                },
                              ),
                              const SizedBox(width: 20,)
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            if(fertSetPvd.listOfRecipe.length != 0)
              SliverToBoxAdapter(
                child: Container(
                  child: SingleChildScrollView(
                    child: constraints.maxWidth < 400 ? Column(
                      children: [
                        for(var i = 0;i < fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length;i++)
                          Container(
                            margin: EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            width: constraints.maxWidth - 40,
                            height: 240,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white
                            ),
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      content: ListOfFertilizerInSet(
                                        index: fertSetPvd.selectedSite,
                                        recipeIndex: i,
                                        length: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length,
                                        screenWidth: constraints.maxWidth,
                                        screenHeight: constraints.maxHeight,
                                      ),
                                    );
                                  });

                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: i%2==0 ? const Color(0xffFFF1D2) : const Color(0xffCCFDEC)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      leading: fertSetPvd.selectFunction == 0 ? Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: i%2==0 ? Color(0xffFF857D) : Color(0xff10E196),
                                        ),
                                        child: Center(
                                          child: Text('F ${i+1}',style: TextStyle(fontSize: 14,color: Colors.white),),
                                        ),
                                      ) : Checkbox(
                                          value: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['select'],
                                          onChanged: (value){
                                            fertSetPvd.fertilizerFunctionality(['selectFertilizer',fertSetPvd.selectedSite,i,value]);
                                          }),
                                      title: Text('${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['name']}',style: TextStyle(fontSize: 14),),
                                    ),
                                    customListTileFs(icon: Icons.location_pin, title: 'Location', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['location']}', i: i),
                                    customListTileFs(icon: Icons.account_tree_sharp, title: 'No Of Channel', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['fertilizer'].length}', i: i),
                                    Row(
                                      children: [
                                        if(fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['ecActive'] != null)
                                          Expanded(child: customListTileFs(title: 'Ec', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['Ec']}', i: i)),
                                        if(fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['phActive'] != null)
                                          Expanded(child: customListTileFs(title: 'Ph', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['Ph']}', i: i)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ) : customizeGridView(
                        maxheight: 240,
                        maxWith: 205, screenWidth: constraints.maxWidth,
                        listOfWidget: [
                          for(var i = 0;i < fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length;i++)
                            Container(
                              padding: const EdgeInsets.all(6),
                              width: 185,
                              height: 220,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white
                              ),
                              child: InkWell(
                                onTap: (){
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      content: ListOfFertilizerInSet(
                                        index: fertSetPvd.selectedSite,
                                        recipeIndex: i,
                                        length: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length,
                                        screenWidth: constraints.maxWidth,
                                        screenHeight: constraints.maxHeight,
                                      ),
                                    );
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: i%2==0 ? const Color(0xffFFF1D2) : const Color(0xffCCFDEC)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                        leading: fertSetPvd.selectFunction == 0 ? Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: i%2==0 ? Color(0xffFF857D) : Color(0xff10E196),
                                          ),
                                          child: Center(
                                            child: Text('F ${i+1}',style: TextStyle(fontSize: 14,color: Colors.white),),
                                          ),
                                        ) : Checkbox(
                                            value: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['select'],
                                            onChanged: (value){
                                              fertSetPvd.fertilizerFunctionality(['selectFertilizer',fertSetPvd.selectedSite,i,value]);
                                            }),
                                        title: Text('${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['name']}',style: TextStyle(fontSize: 14),),
                                      ),
                                      customListTileFs(icon: Icons.location_pin, title: 'Location', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['location']}', i: i),
                                      customListTileFs(icon: Icons.account_tree_sharp, title: 'No Of Channel', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['fertilizer'].length}', i: i),
                                      Row(
                                        children: [
                                          if(fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['ecActive'] != null)
                                            Expanded(child: customListTileFs(title: 'Ec', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['Ec']}', i: i)),
                                          if(fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['phActive'] != null)
                                            Expanded(child: customListTileFs(title: 'Ph', value: '${fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][i]['Ph']}', i: i)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ]
                    ),
                  ),
                ),
              )
          ],
        );
      }),
    );
  }


}

Widget myButtons({required String name,required void Function() onTap,double? radius,double? verticalPadding,int? index,required FertilizerSetProvider fertSetPvd}){
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 10,horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 5),
          color: index != null ? (index == fertSetPvd.selectedSite ? Color(0xff1A7886) : null) : Color(0xff1A7886)
      ),
      child: Text(name,style: TextStyle(color: index != null ? (index == fertSetPvd.selectedSite ? Colors.white : Colors.black87) : Colors.white,fontSize: 13,fontWeight: FontWeight.w200),),
    ),
  );
}
Widget customizeGridView({required double maxWith,required double maxheight,required double screenWidth,required List<Widget> listOfWidget}){
  var eachRowCount = (((screenWidth - 20)/(maxWith+10))).toInt();
  List<List<Widget>> gridWidgetRow = [];
  for(var i = 0;i < listOfWidget.length;i +=(listOfWidget.length - i) < eachRowCount ? (listOfWidget.length - i) : eachRowCount){
    List<Widget> rows = [];
    for(var j = 0;j < ((listOfWidget.length - i) < eachRowCount ? (listOfWidget.length - i) : eachRowCount);j++){
      rows.add(listOfWidget[i + j]);
    }
    gridWidgetRow.add(rows);
  }
  return Column(
    children: [
      for(var row in gridWidgetRow)
        SizedBox(
          width: screenWidth,
          height: maxheight+20,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: screenWidth,
                height: maxheight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for(var widget = 0;widget < row.length;widget++)
                      Row(
                        mainAxisAlignment: eachRowCount == 1 ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: (((screenWidth - 20) - (eachRowCount * maxWith))/eachRowCount)/2.toInt().toDouble(),
                          ),
                          SizedBox(
                              width: maxWith,
                              height: maxheight,
                              child: row[widget]
                          ),
                          SizedBox(
                            width: (((screenWidth - 20) - (eachRowCount * maxWith))/eachRowCount)/2.toInt().toDouble(),
                          ),
                        ],
                      )
                  ],
                ),
              ),

              // SizedBox(height: 10,)
            ],
          ),
        ),
    ],
  );
}

// void showDialogBox(FertilizerSetProvider fertSetPvd,bool doingAdd,context,index,OverlayPortalController){
//   showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context){
//     return Consumer<FertilizerSetProvider>(builder: (context,fertSetPvd,child){
//       return AlertDialog(
//         content: ListOfFertilizerInSet(
//           index: fertSetPvd.selectedSite,
//           recipeIndex: index ?? fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length - 1,
//           doingAdd: doingAdd,
//           length: fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length, tooltipController: t,
//         ),
//       );
//     });
//
//   });
// }

Widget customListTileFs({IconData? icon,required String title,required String value,required int i}){
  return ListTile(
    leading: icon != null ? Icon(icon,size: 16,) : null,
    title: Text(title,style: TextStyle(fontSize: 13),),
    trailing: Text(value,style: TextStyle(color: i%2==0 ? Color(0xffFF857D) : Color(0xff04D88C),fontWeight: FontWeight.w200,fontSize: 13),),
  );
}

Widget customTextFieldFs({required bool enabled,required String value,required Function(String)? onChanged}){
  return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      maxLength: 3,
      cursorHeight: 20,
      textAlign: TextAlign.center,
      textAlignVertical:  TextAlignVertical.top,
      enabled: enabled,
      initialValue: value,
      decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.only(bottom: 20),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black, // You can set the color of the bottom border here
              width: 1.0, // You can adjust the width of the bottom border here
            ),
          )
      ),
      onChanged: onChanged
  );
}



