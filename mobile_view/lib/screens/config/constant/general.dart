// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:oro_irrigation_new/constants/theme.dart';
// import 'package:provider/provider.dart';
// import '../../../state_management/constant_provider.dart';
// import '../../../state_management/overall_use.dart';
// import '../../../widgets/drop_down_button.dart';
// import '../../../widgets/time_picker.dart';
//
//
// class GeneralInConstant extends StatefulWidget {
//   @override
//   State<GeneralInConstant> createState() => _GeneralInConstantState();
// }
//
// class _GeneralInConstantState extends State<GeneralInConstant> {
//   int selected = -1;
//   String? selectedTime;
//
//   Future<void> _show() async {
//     final TimeOfDay? result =
//     await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (result != null) {
//       setState(() {
//         selectedTime = result.format(context);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
//     var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
//     return LayoutBuilder(builder: (BuildContext context,BoxConstraints constrainsts){
//       return Container(
//         color: Colors.white,
//         padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
//         child: GridView.custom(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: gridAlignment(constrainsts.maxWidth),
//               childAspectRatio: gridAlignment(constrainsts.maxWidth) == 1 ? MediaQuery.sizeOf(context).width/80 : MediaQuery.sizeOf(context).width/200,
//               mainAxisSpacing: 20,
//               crossAxisSpacing: 20
//           ),
//           childrenDelegate: SliverChildBuilderDelegate(
//                 (BuildContext context, int index) {
//               return Container(
//                 // margin: index == 0 ? EdgeInsets.only(top: 10) : null,
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: constantPvd.selected == index ? Border(left: BorderSide(width: 7,color: myTheme.primaryColor),right: BorderSide(width: 1,color: myTheme.primaryColor),top: BorderSide(width: 1,color: myTheme.primaryColor),bottom: BorderSide(width: 1,color: myTheme.primaryColor)) : Border.all(width: 0.5),
//                 ),
//                 child: Center(
//                   child: ListTile(
//                     focusColor: Colors.white,
//                     selectedColor: Colors.white,
//                     // tileColor: Colors.white,
//                     onTap: (){
//                       constantPvd.generalSelected(index);
//                       overAllPvd.editTimeAll();
//                     },
//                     leading: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                           color: constantPvd.selected == index ? Colors.blue.shade100 : Colors.black12,
//                           borderRadius: BorderRadius.circular(10.0)
//                       ),
//                       child: Center(
//                         child: constantPvd.general[index][2],
//                       ),
//                     ),
//                     contentPadding: EdgeInsets.all(0),
//                     title: Text('${constantPvd.general[index][0]}',style: constantPvd.selected == index ? TextStyle(fontWeight: FontWeight.w600) : null,),
//                     trailing: constantPvd.selected == index ? forGeneral(index, constantPvd) : Text('${constantPvd.general[index][1]}'),
//                   ),
//                 ),
//               );
//             },
//             childCount: constantPvd.general.length,
//           ),),
//       );
//     },);
//
//   }
//   Widget forGeneral(int index,ConstantProvider constantPvd){
//     switch(index){
//       case (0):{
//         return CustomTimePickerSiva(purpose: 'general/resetTime', index: index, value: '${constantPvd.general[index][1]}', displayHours: true, displayMins: true, displaySecs: false, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,
//         );
//       }
//       case (1):{
//         return CustomTimePickerSiva(purpose: 'general/leakageLimit', index: index, value: '${constantPvd.general[index][1]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: 'pulse', CustomList: [1,10], displayAM_PM: false,
//         );
//       }
//       case (2):{
//         return CustomTimePickerSiva(purpose: 'general/runList', index: index, value: '${constantPvd.general[index][1]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: 'days', CustomList: [1,20], displayAM_PM: false,
//         );
//       }
//       case (3):{
//         return CustomTimePickerSiva(purpose: 'general/currentDay', index: index, value: '${constantPvd.general[index][1]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: 'days', CustomList: [1,20], displayAM_PM: false,
//         );
//       }
//       case (4):{
//         return CustomTimePickerSiva(purpose: 'general/noPressureDelay', index: index, value: '${constantPvd.general[index][1]}', displayHours: true, displayMins: true, displaySecs: false, displayCustom: false, CustomString: '', CustomList: [0,20], displayAM_PM: false,
//         );
//       }
//       case (5):{
//         return SizedBox(width: 100,child: MyDropDown(initialValue: constantPvd.general[index][1], itemList: ['Yes','NO'], pvdName: 'constant-general-waterPulse', index: index));
//       }
//       case (6):{
//         return CustomTimePickerSiva(purpose: 'general/dosingCoefficient', index: index, value: '${constantPvd.general[index][1]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: '%', CustomList: [0,100], displayAM_PM: false,
//         );
//       }
//       case (7):{
//         return SizedBox(
//           width: 100,
//         height: 50,
//         child: TextFormField(
//           initialValue: constantPvd.general[index][1],
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//           ],
//           onChanged: (value){
//             constantPvd.generalFunctionality(index, value);
//           },
//         )
//         );
//       }
//       case (8):{
//         return SizedBox(
//             width: 100,
//             height: 50,
//             child: TextFormField(
//               initialValue: constantPvd.general[index][1],
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//               ],
//               onChanged: (value){
//                 constantPvd.generalFunctionality(index, value);
//               },
//             )
//         );
//       }
//       default:{
//         return Text('${constantPvd.general[index][1]}');
//       }
//
//     }
//   }
//   int gridAlignment(double width){
//     if(width < 850 && width > 500){
//       return 2;
//     }else if(width < 500){
//       return 1;
//     }
//     else{
//       return 3;
//     }
//   }
// }
