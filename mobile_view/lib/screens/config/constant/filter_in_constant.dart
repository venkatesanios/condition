// import 'package:flutter/material.dart';
// import 'package:oro_irrigation_new/constants/theme.dart';
// import 'package:oro_irrigation_new/constants/theme.dart';
// import 'package:oro_irrigation_new/constants/theme.dart';
// import 'package:provider/provider.dart';
//
// import '../../../state_management/constant_provider.dart';
// import '../../../state_management/overall_use.dart';
// import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
// import '../../../widgets/drop_down_button.dart';
// import '../../../widgets/table_needs.dart';
// import '../../../widgets/time_picker.dart';
//
//
// class FilterConstant extends StatefulWidget {
//   const FilterConstant({super.key});
//
//   @override
//   State<FilterConstant> createState() => _FilterConstantState();
// }
//
// class _FilterConstantState extends State<FilterConstant> {
//   @override
//   Widget build(BuildContext context) {
//     var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
//     var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
//     return LayoutBuilder(builder: (context,constraints){
//       if(constraints.maxWidth < 900){
//         return FilterConstant_M();
//       }
//       return myTable(
//           [expandedTableCell_Text('Site',''),
//             expandedTableCell_Text('Name',''),
//             expandedTableCell_Text('Used','in lines'),
//             expandedTableCell_Text('DP delay','(sec)'),
//             expandedTableCell_Text('Looping','limit'),
//             expandedTableCell_Text('While','flushing'),
//           ],
//           Expanded(
//             child: ListView.builder(
//                 itemCount: constantPvd.filterUpdated.length,
//                 itemBuilder: (BuildContext context,int index){
//                   return Container(
//                     margin: index == constantPvd.filterUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
//                     decoration: BoxDecoration(
//                       border: Border(bottom: BorderSide(width: 1)),
//                       color: Colors.white70,
//                     ),                    child: Row(
//                     children: [
//                       expandedCustomCell(Text('${constantPvd.filterUpdated[index]['id']}'),),
//                       expandedCustomCell(Text('${constantPvd.filterUpdated[index]['name']}'),),
//                       expandedCustomCell( Text('${constantPvd.filterUpdated[index]['location']}'),),
//                       expandedCustomCell(CustomTimePickerSiva(purpose: 'filter_dp_delay', index: index, value: '${constantPvd.filterUpdated[index]['dpDelay']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
//                       expandedCustomCell(CustomTimePickerSiva(purpose: 'filter_looping_limit', index: index, value: '${constantPvd.filterUpdated[index]['loopingLimit']}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: '', CustomList: [0,99], displayAM_PM: false,)),
//                       expandedCustomCell(MyDropDown(initialValue: constantPvd.filterUpdated[index]['whileFlushing'], itemList: ['Continue Irrigation','Stop Irrigation','No Fertilization'], pvdName: 'filter/flushing', index: index),),
//                     ],
//                   ),
//                   );
//                 }),
//           )
//       );
//     });
//
//   }
// }
//
// class FilterConstant_M extends StatefulWidget {
//   const FilterConstant_M({super.key});
//
//   @override
//   State<FilterConstant_M> createState() => _FilterConstant_MState();
// }
//
// class _FilterConstant_MState extends State<FilterConstant_M> {
//   int selectedSite = 0;
//   @override
//   Widget build(BuildContext context) {
//     var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
//     var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           Container(
//               margin: EdgeInsets.only(bottom: 8),
//               height: 30,
//               color: myTheme.primaryColor,
//               width : double.infinity,
//               child: Center(child: Text('Select filtration site',style: TextStyle(color: Colors.white),))
//           ),
//           Container(
//             padding: EdgeInsets.only(left: 10),
//             width: double.infinity,
//             height: 50,
//             child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: constantPvd.filter.length,
//                 itemBuilder: (BuildContext context,int index){
//                   return Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         width: 60,
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               width: 60,
//                               height: 40,
//                               child: GestureDetector(
//                                 onTap: (){
//                                   setState(() {
//                                     selectedSite = index;
//                                   });
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.filter.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
//                                     color: selectedSite == index ? myTheme.primaryColor : Colors.blue.shade100,
//                                   ),
//                                   child: Center(child: Text('${index + 1}',style: TextStyle(color: selectedSite == index ? Colors.white : null),)),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(width: 3,),
//                                 Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: Colors.black
//                                   ),
//                                 ),
//                                 Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: Colors.black
//                                   ),
//                                 ),
//                                 SizedBox(width: 3,),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                       if(constantPvd.filter.length - 1 != index)
//                         Text('-')
//                     ],
//                   );
//                 }),
//           ),
//           Container(
//               margin: EdgeInsets.only(bottom: 8),
//               height: 30,
//               color: myTheme.primaryColor,
//               width : double.infinity,
//               child: Center(child: Text('${constantPvd.filter[selectedSite][0]}',style: TextStyle(color: Colors.white),))
//           ),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 // color: Color(0XFFF3F3F3)
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   // mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     returnMyListTile('Name', Text('${constantPvd.filter[selectedSite][0]}',style: TextStyle(fontSize: 14))),
//                     returnMyListTile('Used in lines', Text('${constantPvd.filter[selectedSite][1]}',style: TextStyle(fontSize: 14))),
//                     returnMyListTile('DP delay (sec)', CustomTimePickerSiva(purpose: 'filter_dp_delay', index: selectedSite, value: '${constantPvd.filter[selectedSite][3]}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
//                     returnMyListTile('Looping limit', CustomTimePickerSiva(purpose: 'filter_looping_limit', index: selectedSite, value: '${constantPvd.filter[selectedSite][4]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: '', CustomList: [0,99], displayAM_PM: false,)),
//                     returnMyListTile('While flushing', fixedContainer(MyDropDown(initialValue: constantPvd.filter[selectedSite][5], itemList: ['Continue Irrigation','Stop Irrigation','No Fertilization'], pvdName: 'filter/flushing', index: selectedSite))),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }