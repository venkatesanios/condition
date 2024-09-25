import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/widget/HoursMinutesSeconds.dart';
import 'package:provider/provider.dart';
import '../../../state_management/FertilizerSetProvider.dart';
import '../../../state_management/overall_use.dart';
import 'FertilizerSet.dart';

class ListOfFertilizerInSet extends StatefulWidget {
  double screenWidth;
  double screenHeight;
  final int length;
  final int index;
  final int recipeIndex;
  ListOfFertilizerInSet({super.key, required this.index, required this.recipeIndex,required this.length,required this.screenWidth,required this.screenHeight});

  @override
  State<ListOfFertilizerInSet> createState() => _ListOfFertilizerInSetState();
}

class _ListOfFertilizerInSetState extends State<ListOfFertilizerInSet> with TickerProviderStateMixin{
  int selectedFertilizer = 0;
  late TabController myController;
  dynamic myRecipe = {};
  bool textField = false;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: false);
    for(var key in fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][widget.recipeIndex].keys){
      if(key != 'fertilizer'){
        myRecipe[key] = fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][widget.recipeIndex][key];
      }else{
        myRecipe['fertilizer'] = [];
        for(var fert = 0;fert < fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][widget.recipeIndex]['fertilizer'].length;fert++){
          myRecipe['fertilizer'].add({});
          for(var fertKey in fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][widget.recipeIndex]['fertilizer'][fert].keys){
            myRecipe['fertilizer'][fert][fertKey] = fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'][widget.recipeIndex]['fertilizer'][fert][fertKey];
          }
        }
      }
    }
    myController = TabController(length: widget.length, vsync: this);
  }


  void editTextFieldController(String value){
    setState(() {
      myRecipe['name'] = value;
    });
  }
  void editTextField(){
    setState(() {
      textField = !textField;
    });
  }

  void listOfFertilizerFunctionality(list){
    switch (list[0]){
      case ('editActive'):{
        setState(() {
          myRecipe['fertilizer'][list[1]]['active'] = list[2];
        });
        break;
      }
      case ('editDmControl'):{
        setState(() {
          if(myRecipe['fertilizer'][list[1]]['dmControl'] == true){
            myRecipe['fertilizer'][list[1]]['dmControl'] = false;
          }else{
            myRecipe['fertilizer'][list[1]]['dmControl'] = true;
          }
        });
        break;
      }
      case ('editMethod'):{
        setState(() {
          myRecipe['fertilizer'][list[1]]['method'] = list[2];
        });
        break;
      }
      case ('editTimeOrQuantity'):{
        setState(() {
          myRecipe['fertilizer'][list[1]]['quantity/time'] = list[2];
        });
        break;
      }
      case ('editTimeValue'):{
        setState(() {
          myRecipe['fertilizer'][list[1]]['timeValue'] = list[2];
        });
        break;
      }
      case ('editQuantityValue'):{
        setState(() {
          myRecipe['fertilizer'][list[1]]['quantityValue'] = list[2];
        });
        break;
      }
      case ('editEc'):{
        setState(() {
          myRecipe['Ec'] = list[1];
        });
        break;
      }
      case ('editEcActive'):{
        setState(() {
          myRecipe['ecActive'] = list[1];
        });

        break;
      }
      case ('editPh'):{
        setState(() {
          myRecipe['Ph'] = list[1];
        });

        break;
      }
      case ('editPhActive'):{
        setState(() {
          myRecipe['phActive'] = list[1];
        });
        break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      width:  widget.screenWidth,
      // height: widget.screenHeight - (widget.screenWidth < 400 ? (overAllPvd.keyBoardAppears ? 10 :  240) : 100),
      child: LayoutBuilder(builder: (context,constraints){
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: (fertSetPvd.listOfRecipe[fertSetPvd.selectedSite]['recipe'].length)%2==0 ? Color(0xffFF857D) : Color(0xff10E196),
                  ),
                  child: Center(
                    child: Text('F ${widget.index + 1}',style: TextStyle(fontSize: 14,color: Colors.white),),
                  ),
                ),
                title: textField == false ? Text('${myRecipe['name']}') : TextFormField(
                  initialValue: myRecipe['name'],
                  onChanged: (value){
                    editTextFieldController(value);
                  },
                ),
                trailing: IconButton(
                  onPressed: (){
                    editTextField();
                  },
                  icon: Icon(Icons.edit_note),
                ),
              ),
              Row(
                children: [
                  if(myRecipe['ecActive'] != null)
                    SizedBox(
                      width: 115,
                      height: 40,
                      child: Row(
                        children: [
                          Checkbox(
                              value: myRecipe['ecActive'],
                              onChanged: (value){
                                listOfFertilizerFunctionality(['editEcActive',value]);
                              }
                          ),
                          Text('Ec',style: TextStyle(fontSize: 13)),
                          SizedBox(
                            width: 50,
                            height: 40,
                            child: customTextFieldFs(
                                enabled: myRecipe['ecActive'],
                                value: myRecipe['Ec'],
                                onChanged: (value){
                                  listOfFertilizerFunctionality(['editEc',value]);
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                  if(myRecipe['phActive'] != null)
                    SizedBox(
                      width: 115,
                      height: 40,
                      child: Row(
                        children: [
                          Checkbox(
                              value: myRecipe['phActive'],
                              onChanged: (value){
                                listOfFertilizerFunctionality(['editPhActive',value]);
                              }
                          ),
                          Text('Ph',style: TextStyle(fontSize: 13)),
                          SizedBox(
                            width: 50,
                            height: 40,
                            child: customTextFieldFs(
                                enabled: myRecipe['phActive'],
                                value: myRecipe['Ph'],
                                onChanged: (value){
                                  listOfFertilizerFunctionality(['editPh',value]);
                                }
                            ),
                          ),
                        ],
                      ),
                    ),

                ],
              ),
              if(constraints.maxWidth < 660)
                SizedBox(height: 10,),
              if(constraints.maxWidth < 660)
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(0xffE6EDF5),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      children: [
                        for(var i = 0;i < myRecipe['fertilizer'].length;i++)
                          fertButtons(
                            fertSetPvd: fertSetPvd,
                            index: i,
                            verticalPadding: 8,
                            radius: 15,
                            name: '${myRecipe['fertilizer'][i]['id']}',
                            onTap: (){
                              _scrollController.animateTo((i * (selectedFertilizer > i ? (myRecipe['fertilizer'][i]['id'].length * 3) : (myRecipe['fertilizer'][i]['id'].length * 5))).toDouble(), duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                              setState(() {
                                selectedFertilizer = i;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10,),
              if(constraints.maxWidth < 660)
                Column(
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          boxShadow: customBoxShadow,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: ListTile(
                          title: Text('Name'),
                          trailing: Text('${myRecipe['fertilizer'][selectedFertilizer]['name']}')
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          boxShadow: customBoxShadow,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: ListTile(
                        title: Text('Active'),
                        trailing: SizedBox(
                          width: 50,
                          height: 30,
                          child: Checkbox(
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.all(Color(0xff03464F)),
                              value: myRecipe['fertilizer'][selectedFertilizer]['active'],
                              onChanged: (value){
                                listOfFertilizerFunctionality(['editActive',selectedFertilizer,value]);
                              }
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          boxShadow: customBoxShadow,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: ListTile(
                        title: Text('Method'),
                        trailing: SizedBox(
                          width: 100,
                          child: Transform.scale(
                            scale: 0.8,
                            child: DropdownButton(
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down_outlined,color: Colors.black,size: 18,),
                              dropdownColor: Colors.white,
                              focusColor: Colors.black87,
                              value: myRecipe['fertilizer'][selectedFertilizer]['method'],
                              underline: Container(),
                              items: ['Time','Pro.time','Quantity','Pro.quantity'].map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold),),
                                );
                              }).toList(),
                              onChanged: (value) {
                                listOfFertilizerFunctionality(['editMethod',selectedFertilizer,value]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          boxShadow: customBoxShadow,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: ListTile(
                        title: Text('Value'),
                        trailing: SizedBox(
                          width: 60,
                          height: 30,
                          child: ['Quantity','Pro.quantity','Pro.quant per 1000L'].contains(fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][selectedFertilizer]['method']) ? Focus(
                            onFocusChange: (hasFocus){
                              overAllPvd.editKeyBoardAppears(hasFocus);
                            },
                            child: TextFormField(
                              initialValue: myRecipe['fertilizer'][selectedFertilizer]['quantityValue'],
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13,color: Colors.black),
                              cursorColor: Colors.black,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              decoration: const InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.only(bottom: 5),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black)
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black)
                                  )
                              ),
                              onChanged: (value){
                                listOfFertilizerFunctionality(['editQuantityValue',selectedFertilizer,value]);
                              },
                            ),
                          ) :  InkWell(
                            onTap: (){
                              _showTimePicker(fertSetPvd,overAllPvd,selectedFertilizer,'timeValue');
                            },
                            child: SizedBox(
                              width: 80,
                              height: 30,
                              child: Center(
                                child: Text('${myRecipe['fertilizer'][selectedFertilizer]['timeValue']}',style: TextStyle(color: Colors.black),),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                )
              else//padding 20
                Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xff1C7B89),
                                Color(0xff074B55)
                              ]
                          )
                      ),
                      width: double.infinity,
                      height: 40,
                      child: Row(
                        children: [
                          columnWidget(width: 100, title: 'Active'),
                          columnWidget(width: 150, title: 'Dosing channel'),
                          columnWidget(width: 200, title: 'Method'),
                          columnWidget(width: 100, title: 'Value'),
                          columnWidget(width: 100, title: 'DM control'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: widget.screenHeight - 350,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount: myRecipe['fertilizer'].length,
                          itemBuilder: (context,index){
                            return Container(
                              decoration: BoxDecoration(
                                color: myRecipe['fertilizer'][index]['active'] == true ? Colors.white : Color(0XFFF3F3F3),
                                borderRadius: index == myRecipe['fertilizer'].length - 1 ? BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)) : null,
                              ),

                              width: double.infinity,
                              height: 45,
                              child: Row(
                                children: [
                                  rowWidget(
                                      child: Checkbox(
                                          value: myRecipe['fertilizer'][index]['active'],
                                          onChanged: (value){
                                            listOfFertilizerFunctionality(['editActive',index,value]);
                                          }
                                      )
                                  ),
                                  rowWidget(
                                    child: Text(
                                      '${myRecipe['fertilizer'][index]['name']}',style: TextStyle(color: myRecipe['fertilizer'][index]['active'] == true ? Colors.black87 : Colors.black54,fontSize: 12),
                                    ),
                                  ),
                                  rowWidget(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        focusColor: Colors.black87,
                                        value: myRecipe['fertilizer'][index]['method'],
                                        underline: Container(),
                                        items: ['Time','Pro.time','Quantity','Pro.quantity','Pro.quant per 1000L'].map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold),),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          listOfFertilizerFunctionality(['editMethod',index,value]);
                                        },
                                      )
                                  ),
                                  rowWidget(
                                    child: ['Quantity','Pro.quantity','Pro.quant per 1000L'].contains(myRecipe['fertilizer'][index]['method'])
                                        ? TextFormField(
                                      initialValue: myRecipe['fertilizer'][index]['quantityValue'],
                                      maxLength: 6,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: const InputDecoration(
                                          counterText: '',
                                          contentPadding: EdgeInsets.only(bottom: 5),
                                          enabledBorder: OutlineInputBorder(
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1,color: Colors.black)
                                          )
                                      ),
                                      onChanged: (value){
                                        listOfFertilizerFunctionality(['editQuantityValue',index,value]);
                                      },
                                    ) : InkWell(
                                      onTap: (){
                                        _showTimePicker(fertSetPvd,overAllPvd,index,'timeValue');
                                      },
                                      child: SizedBox(
                                        width: 80,
                                        height: 40,
                                        child: Center(
                                          child: Text('${myRecipe['fertilizer'][index]['timeValue']}'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  rowWidget(
                                      child: Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: myRecipe['fertilizer'][index]['dmControl'],
                                          onChanged: (bool value) {
                                            listOfFertilizerFunctionality(['editDmControl',index,value]);
                                          },
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),

              // SizedBox(height: 10,),
              SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);

                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xffFF857D)
                        ),
                        width: 70,
                        height: 40,
                        child: Center(
                          child: Text('Cancel',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          fertSetPvd.copyRecipe(index: widget.recipeIndex, recipeData: myRecipe);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff10E196)
                        ),
                        width: 70,
                        height: 40,
                        child: Center(
                          child: Text('OK'),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }


  Widget fertButtons({required String name,required void Function() onTap,double? radius,double? verticalPadding,int? index,required FertilizerSetProvider fertSetPvd}){
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 10,horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 5),
            color: index != null ? (index == selectedFertilizer ? Color(0xff1A7886) : null) : Color(0xff1A7886)
        ),
        child: Center(child: Text(name,style: TextStyle(color: index != null ? (index == selectedFertilizer ? Colors.white : Colors.black87) : Colors.white,fontSize: 13,fontWeight: FontWeight.w200),)),
      ),
    );
  }


  void _showTimePicker(FertilizerSetProvider fertSetPvd,OverAllUse overAllPvd,int index,String purpose) async {
    overAllPvd.editTimeAll();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,StateSetter stateSetter){
          return AlertDialog(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: const Column(
              children: [
                Text(
                  'Select time',style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: HoursMinutesSeconds(
              initialTime: '${myRecipe['fertilizer'][index]['timeValue']}',
              onPressed: (){
                stateSetter((){
                  listOfFertilizerFunctionality(['editTimeValue',index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                });
                // fertSetPvd.editNameOfRecipe(fertSetPvd.textFieldController.text,widget.recipeIndex);
                Navigator.pop(context);
              },
            ),
          );
        });

      },
    );
  }
}

Widget customListTile({required IconData icon,required String title,required Widget child}){
  return Container(
    padding: EdgeInsets.all(10),
    height: 50,
    width: double.infinity,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff1C7B89),
              Color(0xff074B55)
            ]
        )
    ),
    child: ListTile(
      leading: Icon(icon,color: Colors.amber,size: 15),
      title: Text(title),
      trailing: child,
    ),
  );
}

Widget columnWidget({required double width,required String title}){
  return Expanded(
    child: SizedBox(
      width: width,
      height: 60,
      child: Center(
        child: Text(
          title,style: const TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

Widget rowWidget({required Widget child}){
  return Expanded(
    child: SizedBox(
      height: 40,
      child: Center(
          child: child
      ),
    ),
  );
}

Color violetBorder = const Color(0xff8833FF);
Color liteViolet = const Color(0xffE2D5FF);
Color liteOrange = const Color(0xffFFF7E5);

List<BoxShadow> customBoxShadow = [
  BoxShadow(
      offset: const Offset(0,45),
      blurRadius: 112,
      color: Colors.black.withOpacity(0.06)
  ),
  BoxShadow(
      offset: const Offset(0,22.78),
      blurRadius: 48.83,
      color: Colors.black.withOpacity(0.04)
  ),
  BoxShadow(
      offset: const Offset(0,9),
      blurRadius: 18.2,
      color: Colors.black.withOpacity(0.03)
  ),
  BoxShadow(
      offset: const Offset(0,1.97),
      blurRadius: 6.47,
      color: Colors.black.withOpacity(0.02)
  ),
];