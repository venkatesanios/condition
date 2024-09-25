import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:excel/excel.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/IrrigationLog/scrollingTable.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../FertilizerSet.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../Models/Customer/log/irrigation_parameter_model.dart';
import '../../../../../constants/http_service.dart';
import '../../../../../state_management/overall_use.dart';

class LogHome extends StatefulWidget {
  final dynamic serverData;
  final int userId;
  final int controllerId;
  const LogHome({super.key,required this.serverData, required this.userId, required this.controllerId});
  @override
  State<LogHome> createState() => _LogHomeState();
}

class _LogHomeState extends State<LogHome> {
  int noOfRowsPerPage = 20;
  int totalPages = 0;
  int selectedPages = 1;
  ScrollController _scrollController = ScrollController();
  dynamic dataSource = [];
  int _selectedIndex = 0;
  List<List<dynamic>> _irrigationOptionWise = [['Date',true],['Program',false],['Line',false],['Valve',false],['Status',false]];
  bool graphMode = false;
  DateRange? selectedDateRange;
  DateRange? lastSelectedDateRange;
  ScrollController _graphController = ScrollController();
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  Icon selectedIcon = const Icon(Icons.bar_chart,color: Colors.white,);
  String selectedChart = 'Bar';
  // late final Widget Function({DateRange? selectedDateRange})? dialogFooterBuilder;
  List<dynamic> program = [];
  List<dynamic> programDuplicate = [];
  List<dynamic> valve = [];
  List<dynamic> valveDuplicate = [];
  List<dynamic> line = [];
  List<dynamic> lineDuplicate = [];
  List<dynamic> date = [];
  List<dynamic> dateDuplicate = [];
  List<dynamic> status = [];
  List<dynamic> statusDuplicate = [];
  List<dynamic> parameters = [
    'Date','Status','ProgramS_No','ProgramCategory','ScheduledStartTime',
    'SequenceData','ValveFlowrate','IrrigationDurationCompleted','ProgramName',
    'IrrigationMethod','IrrigationDuration_Quantity','IrrigationQuantityCompleted','ProgramCategoryName','Pretime','PostTime'
  ];

  int httpError = 0;

  Map<String,dynamic> dataToShow = {};
  dynamic irrigationLogParameterFromServer = {
    'general' : {
      'ProgramName' : ['Program',true,1],
      'Status' : ['Status',true,1],
      'SequenceData' : ['Valve',true,1],
      // 'ZoneName' : ['Sequence',true,1],
      'Date' : ['Date',true,1],
      'ProgramCategoryName' : ['Line',true,1],
      'ScheduledStartTime' : ['Start Time',true,1],
      'Pump' : ['Pump',true,1],
      'ProgramStartStopReason' : ['Start Stop Reason',true,1],
      'ProgramPauseResumeReason' : ['Pause Resume Reason',true,1],
      'overAll' : ['over all',true,1],
    },
    'irrigation' : {
      'IrrigationMethod' : ['Method',true,2],
      'IrrigationDuration_Quantity' : ['Planned',true,2],
      'IrrigationDurationCompleted/IrrigationQuantityCompleted' : ['Actual',true,2],
      'overAll' : ['over all',true,1]
    },
    // 'filter' : {
    //   'CentralFilterName' : ['Central Filter',true,2],
    //   'LocalFilterName' : ['Local Filter',true,2],
    //   'overAll' : ['over all',true,1]
    // },
    'prePost' : {
      'PrePostMethod' : ['Method',true,2],
      'Pretime/PreQty' : ['Pre',true,2],
      'PostTime/PostQty' : ['Post',true,2],
      'overAll' : ['over all',true,1]
    },
    'centralEcPh' : {
      'CentralPhSetValue' : ['Central Ph Avg',true,3],
      'CentralEcSetValue' : ['Central Ec Avg',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH1>' : {
      'CentralFertChannelName' : ['Channel1 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH2>' : {
      'CentralFertChannelName' : ['Channel2 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH3>' : {
      'CentralFertChannelName' : ['Channel3 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH4>' : {
      'CentralFertChannelName' : ['Channel4 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH5>' : {
      'CentralFertChannelName' : ['Channel5 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH6>' : {
      'CentralFertChannelName' : ['Channel6 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH7>' : {
      'CentralFertChannelName' : ['Channel7 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
    '<C - CH8>' : {
      'CentralFertChannelName' : ['Channel8 Name',true,3],
      'CentralFertMethod' : ['Method',true,3],
      'CentralFertilizerChannelDuration/CentralFertilizerChannelQuantity' : ['Planned',true,3],
      'CentralFertilizerChannelDurationCompleted/CentralFertilizerChannelQuantityCompleted' : ['Actual',true,3],
      'overAll' : ['over all',true,1]
    },
  };
  IrrigationLog irrigationParameterArray = IrrigationLog();
  IrrigationLog irrigationParameterArrayDuplicate = IrrigationLog();
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  @override
  void initState() {
    // TODO: implement initState
    print('parameters => ${parameters}');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        irrigationLogParameterFromServer = widget.serverData['irrigationLog'];
        print('irrigationLogParameterFromServer => $irrigationLogParameterFromServer');
        for(var globalParameter in irrigationLogParameterFromServer.keys){
          print('see : ${irrigationLogParameterFromServer[globalParameter]}');
          for(var localParameter in irrigationLogParameterFromServer[globalParameter].keys){
            // print('hw : ${localParameter}  data => ${irrigationLogParameterFromServer[globalParameter][localParameter]}');
            var data = irrigationLogParameterFromServer[globalParameter][localParameter];
            var split = localParameter.split('/');
            if(data[1] == true){
              for(var key in split){
                if(key != 'overAll'){
                  if(!parameters.contains(key)){
                    parameters.add(key);
                  }
                }
              }
            }
          }
        }
        print('parameters : $parameters');
        getData();
      }
    });

    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
    super.initState();
    print('initState finished');
  }

  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (mounted) {
  //     Navigator.maybePop(context);
  //   }
  // }

  String _formatNumber(int number) {
    // Add leading zero if the number is less than 10
    return number.toString().padLeft(2, '0');
  }

  void getData()async{
    print('data request to the server.............');
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    print('_selectedDate : $_selectedDate');
    _selectedDate = _selectedDate == '' ? '$formattedDate - $formattedDate' : _selectedDate;
    String dateString1 = _selectedDate.split(' - ')[0];
    String dateString2 = _selectedDate.split(' - ')[1];

    List<String> parts1 = dateString1.split('/');
    List<String> parts2 = dateString2.split('/');

    // Create DateTime objects
    DateTime date1 = DateTime(int.parse(parts1[2]), int.parse(parts1[1]), int.parse(parts1[0]));
    DateTime date2 = DateTime(int.parse(parts2[2]), int.parse(parts2[1]), int.parse(parts2[0]));

    // Format DateTime objects into desired format
    String formattedDate1 = "${date1.year}-${_formatNumber(date1.month)}-${_formatNumber(date1.day)}";
    String formattedDate2 = "${date2.year}-${_formatNumber(date2.month)}-${_formatNumber(date2.day)}";

    irrigationParameterArray.editParameter(irrigationLogParameterFromServer);
    irrigationParameterArrayDuplicate.editParameter(irrigationLogParameterFromServer);
    HttpService service = HttpService();
    try{
      String? startMonth = selectedDateRange?.start.month.toString();
      print('startMonth : $startMonth');

      String? startday = selectedDateRange?.start.day.toString();
      String? endMonth = selectedDateRange?.end.month.toString();
      String? endday = selectedDateRange?.end.day.toString();
      print('userId : ${widget.userId}  controllerId : ${widget.controllerId}   $formattedDate1     $formattedDate2');
      var response = await service.postRequest(
          'getUserControllerLog',
          {
            "userId":widget.userId,
            "controllerId":widget.controllerId,
            "logType" : "Irrigation",
            "fromDate" : formattedDate1,
            "toDate" : formattedDate2,
            "parameters" : parameters,
          }
      );
      var jsonData = jsonDecode(response.body);
      print('jsonData $jsonData');
      print('js == > ${jsonData['data']}');
      if(jsonData['code'] == 200){
        setState(() {
          dataSource = jsonData['data'];
          dataToShow = {};
          program = [];
          programDuplicate = [];
          valve = [];
          valveDuplicate = [];
          line = [];
          lineDuplicate = [];
          date = [];
          dateDuplicate = [];
          status = [];
          statusDuplicate = [];
        });
      }
      if(dataSource != null){
        print(dataSource.length);
        for(var data in dataSource){
          if(data['irrigation'].isNotEmpty){
            if(data['irrigation']['Date'] != null){
              //Todo date
              try{
                if(data['irrigation']['Date'] != null){
                  for(var howManyDate in data['irrigation']['Date']){
                    setState(() {
                      if (!date.any((element) => element['name'] == howManyDate)) {
                        date.add({
                          'name' : howManyDate,
                          'show' : true
                        });
                        dateDuplicate.add({
                          'name' : howManyDate,
                          'show' : true
                        });
                      }
                    });
                  }
                }
              }catch(e,stackTrace){
                log('Error on Date : ${e.toString()}');
                print('Stack Trace: $stackTrace');
              }

              //Todo Status
              try{
                if(data['irrigation']['Status'] != null){
                  for(var howManyStatus in data['irrigation']['Status']){
                    setState(() {
                      if (!status.any((element) => element['name'] == howManyStatus)) {
                        status.add({
                          'name' : howManyStatus,
                          'show' : true
                        });
                        statusDuplicate.add({
                          'name' : howManyStatus,
                          'show' : true
                        });
                      }
                    });
                  }
                }
              }catch(e,stackTrace){
                log('Error on Status : ${e.toString()}');
                print('Stack Trace: $stackTrace');
              }

              //Todo ProgramS_No
              try{
                if(data['irrigation']['ProgramS_No'] != null){
                  for(var howManyProgram = 0;howManyProgram < data['irrigation']['ProgramS_No'].length;howManyProgram++){
                    setState(() {
                      if (!program.any((element) => element['name'] == data['irrigation']['ProgramS_No'][howManyProgram])) {
                        program.add({
                          'name' : data['irrigation']['ProgramS_No'][howManyProgram],
                          'show' : true,
                          'programName' : data['irrigation']['ProgramName'][howManyProgram]
                        });
                        programDuplicate.add({
                          'name' : data['irrigation']['ProgramS_No'][howManyProgram],
                          'show' : true,
                          'programName' : data['irrigation']['ProgramName'][howManyProgram]
                        });
                      }
                    });
                  }
                }
              }catch(e,stackTrace){
                log('Error on ProgramS_No : ${e.toString()}');
                print('Stack Trace: $stackTrace');
              }

              //Todo ProgramCategory  && ProgramCategoryName
              try{
                if(data['irrigation']['ProgramCategory'] != null && data['irrigation']['ProgramCategoryName'] != null){
                  for(var howManyLine = 0;howManyLine < data['irrigation']['ProgramCategory'].length;howManyLine++){
                    for(var splitLine in data['irrigation']['ProgramCategory'][howManyLine].split('_')){
                      setState(() {
                        print("data['irrigation']['ProgramCategoryName']  : ${data['irrigation']['ProgramCategoryName']}");
                        if (!line.any((element) => element['name'] == splitLine)) {
                          line.add({
                            'name' : splitLine,
                            'show' : true,
                            'lineName' : data['irrigation']['ProgramCategoryName'][howManyLine].split('_')[data['irrigation']['ProgramCategory'][howManyLine].split('_').indexOf(splitLine)]
                          });
                          lineDuplicate.add({
                            'name' : splitLine,
                            'show' : true,
                            'lineName' : data['irrigation']['ProgramCategoryName'][howManyLine].split('_')[data['irrigation']['ProgramCategory'][howManyLine].split('_').indexOf(splitLine)]
                          });
                        }
                      });
                    }
                  }
                }
              }catch(e,stackTrace){
                log('Error on ProgramCategory : ${e.toString()}');
                print('Stack Trace: $stackTrace');
              }

              //Todo SequenceData
              try{
                if(data['irrigation']['SequenceData'] != null){
                  for(var howManyValve in data['irrigation']['SequenceData']){
                    print('howManyValve = > : ${howManyValve}');
                    for(var splitValve in howManyValve.split('_')){
                      setState(() {
                        if(splitValve.contains('VL')){
                          if (!valve.any((element) => element['name'] == splitValve)) {
                            valve.add({
                              'name' : splitValve,
                              'show' : true,
                            });
                            valveDuplicate.add({
                              'name' : splitValve,
                              'show' : true,
                            });
                          }

                        }
                      });
                    }
                  }
                }
              }catch(e,stackTrace){
                log('Error on SequenceData : ${e.toString()}');
                print('Stack Trace: $stackTrace');
              }

            }
          }
        }
        print('get function doubt......');
        setState(() {
          for(var val in valve){
            print(val['name'].split('VL.'));
          }
          valve.sort((a,b)=> double.parse(a['name'].split('VL.')[1]).compareTo(double.parse(b['name'].split('VL.')[1])));
          valveDuplicate.sort((a,b)=> double.parse(a['name'].split('VL.')[1]).compareTo(double.parse(b['name'].split('VL.')[1])));
          line.sort((a,b)=> int.parse(a['name'].split('.')[1]).compareTo(int.parse(b['name'].split('.')[1])));
          lineDuplicate.sort((a,b)=> int.parse(a['name'].split('.')[1]).compareTo(int.parse(b['name'].split('.')[1])));
          program.sort((a,b)=> a['name'].compareTo(b['name']));
          programDuplicate.sort((a,b)=> a['name'].compareTo(b['name']));
        });
        print('get function ended......');
        setState(() {
          dataToShow = irrigationParameterArray.editDateWise(dataSource, date);
        });
        print('get function completed......');
      }
      setState(() {
        httpError = 0;
      });
      setState(() {
        totalPages = (dataToShow['fixedColumnData'].length ~/ noOfRowsPerPage);
        if ((totalPages * noOfRowsPerPage) < dataToShow['fixedColumnData'].length) {
          totalPages += 1;
        }
        selectedPages = 1;
      });
    }catch(e,stackTrace){
      setState(() {
        httpError = 1;
      });
      print('error in log = > ${e.toString()}');
      print('error in log stackTrace= > $stackTrace');
    }
  }

  Widget navigationItem(String name,int index,icon){
    return InkWell(
      onTap: (){
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
          width: 230,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _selectedIndex == index ? const Color(0xff2999A9) : null,
          ),
          child: ListTile(
            leading: icon,
            title: Text(name,style: TextStyle(color: _selectedIndex == index ? Colors.white : Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
          )
      ),
    );
  }

  Widget getIcon(icon,index){
    return Icon(icon,color: _selectedIndex == index ? Colors.white : Colors.white,);
  }

  String getLineName(list){
    var name = '';
    for(var i in list){
      name += '${name.length == 0 ? '' : ','}$i';
    }
    return name;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    print('args : ${args}');
    setState(() {
      if (args.value is PickerDateRange) {
        _selectedDate  = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';

        print('_selectedDate : $_selectedDate');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
      print("range: ${_range},rangecount:${_rangeCount},Select date:${_selectedDate}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraint) {
      return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text('Irrigation Log'),
                Text('${_selectedDate}',style: TextStyle(fontSize: 12),),
              ],
            ),
            actions: [
              IconButton(
                onPressed: (){
                  sideSheet(constraint);
                },
                icon: Icon(Icons.filter_list_alt,color: Colors.black,),
              ),
              PopupMenuButton<int>(
                onSelected: (value){
                  if(value == 1){
                    setState(() {
                      selectedIcon = const Icon(Icons.bar_chart,color: Colors.white,);
                      selectedChart = 'Bar';
                    });
                  }else if(value == 2){
                    setState(() {
                      selectedIcon =  const Icon(Icons.stacked_line_chart,color: Colors.white,);
                      selectedChart = 'Line';
                    });
                  }else{
                    setState(() {
                      selectedIcon = const Icon(Icons.pie_chart,color: Colors.white,);
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xff1D808E),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Checkbox(
                          checkColor: Colors.teal,
                          fillColor: MaterialStateProperty.all(const Color(0xFFF4FFFB)),
                          value: graphMode,
                          onChanged: (value){
                            getDialog(context);
                            Future.delayed(Duration(seconds: 1),(){
                              setState(() {
                                graphMode = value!;
                              });
                              Navigator.pop(context);
                            });
                          }
                      ),
                      selectedIcon,
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  // popupmenu item 1
                  // const PopupMenuItem(
                  //   value: 1,
                  //   // row has two child icon and text.
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.bar_chart),
                  //       SizedBox(
                  //         // sized box with width 10
                  //         width: 10,
                  //       ),
                  //       Text("bar chart")
                  //     ],
                  //   ),
                  // ),
                  // // popupmenu item 2
                  // const PopupMenuItem(
                  //   value: 2,
                  //   // row has two child icon and text
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.stacked_line_chart),
                  //       SizedBox(
                  //         // sized box with width 10
                  //         width: 10,
                  //       ),
                  //       Text("line chart")
                  //     ],
                  //   ),
                  // ),
                  // const PopupMenuItem(
                  //   value: 3,
                  //   // row has two child icon and text
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.pie_chart),
                  //       SizedBox(
                  //         // sized box with width 10
                  //         width: 10,
                  //       ),
                  //       Text("pie chart")
                  //     ],
                  //   ),
                  // ),
                ],
                offset: const Offset(0, 50),
                color: Colors.white,
                elevation: 2,
              ),
              const SizedBox(width: 20,),
            ],
          ),
          body: SafeArea(
            child: httpError == 0
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if((dataSource != null || dataToShow.isNotEmpty))
                  Container(
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
                          for(var i = 0;i < _irrigationOptionWise.length;i++)
                            Row(
                              children: [
                                myButtons(
                                  index: i,
                                  verticalPadding: 8,
                                  radius: 15,
                                  name: '${_irrigationOptionWise[i][0]}',
                                  onTap: (){
                                    getDialog(context);
                                    Future.delayed(Duration(seconds: 1),(){
                                      setState(() {
                                        _scrollController.animateTo(
                                          (i * (_selectedIndex > i ? 100 : 100)).toDouble(),
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                        _irrigationOptionWise[i][1] = true;
                                        _selectedIndex = i;
                                        for(var j = 0;j < _irrigationOptionWise.length;j++){
                                          if(j != i){
                                            _irrigationOptionWise[j][1] = false;
                                          }
                                        }
                                        if(_irrigationOptionWise[0][1] == true){
                                          dataToShow = irrigationParameterArray.editDateWise(dataSource, date);
                                        }else if(_irrigationOptionWise[1][1] == true){
                                          dataToShow = irrigationParameterArray.editProgramWise(dataSource, program);
                                        }else if(_irrigationOptionWise[2][1] == true){
                                          dataToShow = irrigationParameterArray.editLineWise(dataSource, line);
                                        }else if(_irrigationOptionWise[3][1] == true){
                                          dataToShow = irrigationParameterArray.editValveWise(dataSource, valve);
                                        }else if(_irrigationOptionWise[4][1] == true){
                                          dataToShow = irrigationParameterArray.editStatusWise(dataSource, status);
                                        }

                                      });
                                      Navigator.pop(context);
                                    });


                                  },
                                ),
                                const SizedBox(width: 20,)
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                if((dataSource == null || dataToShow.isEmpty))
                  Expanded(child: Center(child: Text('There is no data in ${_selectedDate}'))),
                if((dataSource != null || dataToShow.isNotEmpty))
                  if(graphMode == false)
                    Expanded(
                      child: Column(
                        children: [
                          if(dataToShow.isNotEmpty)
                            ScrollingTable(
                              fixedColumn: dataToShow['fixedColumn'],
                              fixedColumnData: filterDataByPages(data: dataToShow['fixedColumnData']),
                              generalColumn: dataToShow['generalColumn'],
                              generalColumnData: filterDataByPages(data: dataToShow['generalColumnData']),
                              waterColumn: dataToShow['waterColumn'],
                              waterColumnData: filterDataByPages(data: dataToShow['waterColumnData']),
                              filterColumn: dataToShow['filterColumn'],
                              filterColumnData: filterDataByPages(data: dataToShow['filterColumnData']),
                              prePostColumn: dataToShow['prePostColumn'],
                              prePostColumnData: filterDataByPages(data: dataToShow['prePostColumnData']),
                              centralEcPhColumn: dataToShow['centralEcPhColumn'],
                              centralEcPhColumnData: filterDataByPages(data: dataToShow['centralEcPhColumnData']),
                              centralChannel1Column: dataToShow['centralChannel1Column'],
                              centralChannel1ColumnData: filterDataByPages(data: dataToShow['centralChannel1ColumnData']),
                              centralChannel2Column: dataToShow['centralChannel2Column'],
                              centralChannel2ColumnData: filterDataByPages(data: dataToShow['centralChannel2ColumnData']),
                              centralChannel3Column: dataToShow['centralChannel3Column'],
                              centralChannel3ColumnData: filterDataByPages(data: dataToShow['centralChannel3ColumnData']),
                              centralChannel4Column: dataToShow['centralChannel4Column'],
                              centralChannel4ColumnData: filterDataByPages(data: dataToShow['centralChannel4ColumnData']),
                              centralChannel5Column: dataToShow['centralChannel5Column'],
                              centralChannel5ColumnData: filterDataByPages(data: dataToShow['centralChannel5ColumnData']),
                              centralChannel6Column: dataToShow['centralChannel6Column'],
                              centralChannel6ColumnData: filterDataByPages(data: dataToShow['centralChannel6ColumnData']),
                              centralChannel7Column: dataToShow['centralChannel7Column'],
                              centralChannel7ColumnData: filterDataByPages(data: dataToShow['centralChannel7ColumnData']),
                              centralChannel8Column: dataToShow['centralChannel8Column'],
                              centralChannel8ColumnData: filterDataByPages(data: dataToShow['centralChannel8ColumnData']),
                              localEcPhColumn: dataToShow['localEcPhColumn'],
                              localEcPhColumnData: filterDataByPages(data: dataToShow['localEcPhColumnData']),
                              localChannel1Column: dataToShow['localChannel1Column'],
                              localChannel1ColumnData: filterDataByPages(data: dataToShow['localChannel1ColumnData']),
                              localChannel2Column: dataToShow['localChannel2Column'],
                              localChannel2ColumnData: filterDataByPages(data: dataToShow['localChannel2ColumnData']),
                              localChannel3Column: dataToShow['localChannel3Column'],
                              localChannel3ColumnData: filterDataByPages(data: dataToShow['localChannel3ColumnData']),
                              localChannel4Column: dataToShow['localChannel4Column'],
                              localChannel4ColumnData: filterDataByPages(data: dataToShow['localChannel4ColumnData']),
                              localChannel5Column: dataToShow['localChannel5Column'],
                              localChannel5ColumnData: filterDataByPages(data: dataToShow['localChannel5ColumnData']),
                              localChannel6Column: dataToShow['localChannel6Column'],
                              localChannel6ColumnData: filterDataByPages(data: dataToShow['localChannel6ColumnData']),
                              localChannel7Column: dataToShow['localChannel7Column'],
                              localChannel7ColumnData: filterDataByPages(data: dataToShow['localChannel7ColumnData']),
                              localChannel8Column: dataToShow['localChannel8Column'],
                              localChannel8ColumnData: filterDataByPages(data: dataToShow['localChannel8ColumnData']),

                            ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Scrollbar(
                        controller: _graphController,
                        thickness: 20,
                        interactive: true,
                        radius: Radius.circular(50),
                        child: SingleChildScrollView(
                          controller: _graphController,
                          child: Column(
                            children: [
                              Wrap(
                                runSpacing: 10,
                                children: [
                                  if(graphMode == true)
                                    if(dataToShow.isNotEmpty)
                                      for(var i in dataToShow['graphData'])
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              boxShadow: customBoxShadow,
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                          width: MediaQuery.of(context).size.width,
                                          height: 250,
                                          child: Column(
                                            children: [
                                              Text('${i['name']}'),
                                              Expanded(
                                                  child: SfCartesianChart(
                                                    enableAxisAnimation: false,
                                                    plotAreaBackgroundColor: Colors.transparent,
                                                    borderColor: Colors.transparent,
                                                    borderWidth: 0,
                                                    // isTransposed: chartDataList!.length <= 3,
                                                    plotAreaBorderWidth: 0,
                                                    enableSideBySideSeriesPlacement: false,
                                                    onTooltipRender: (TooltipArgs args) {
                                                      // String sequence = args.pointIndex != null && args.pointIndex! < chartDataList!.length
                                                      //     ? chartDataList![args.pointIndex!.toInt()].valves
                                                      //     : '';
                                                      // double? preValue = args.pointIndex != null && args.pointIndex! < chartDataList!.length
                                                      //     ? (chartDataList![args.pointIndex!.toInt()].preValueHigh.toDouble() - chartDataList![args.pointIndex!.toInt()].preValueLow.toDouble())
                                                      //     : null;
                                                      // double? postValue = args.pointIndex != null && args.pointIndex! < chartDataList!.length
                                                      //     ? (chartDataList![args.pointIndex!.toInt()].postValueHigh.toDouble() - chartDataList![args.pointIndex!.toInt()].postValueLow.toDouble())
                                                      //     : null;
                                                      // double? waterValue = args.pointIndex != null && args.pointIndex! < chartDataList!.length
                                                      //     ? (chartDataList![args.pointIndex!.toInt()].waterValueHigh.toDouble() - chartDataList![args.pointIndex!.toInt()].waterValueLow.toDouble())
                                                      //     : null;
                                                      // args.text = 'Sequence: $sequence, \nPre value: $preValue, \nPost value: $postValue, \nWater value: $waterValue';
                                                    },
                                                    tooltipBehavior: TooltipBehavior(
                                                      enable: true,
                                                      animationDuration: 0,
                                                      canShowMarker: true,
                                                      // format: 'point.x',
                                                      textStyle: const TextStyle(color: Colors.white),
                                                      tooltipPosition: TooltipPosition.pointer,
                                                      // borderColor: Colors.red,
                                                      borderWidth: 2,
                                                      color: Colors.black,
                                                      // You can customize more tooltip settings here
                                                    ),
                                                    primaryXAxis: CategoryAxis(
                                                      isVisible: true,
                                                      // title: AxisTitle(text: "Sequence"),
                                                      rangePadding: ChartRangePadding.round,
                                                      labelPlacement: LabelPlacement.onTicks,
                                                      maximumLabels: i['data'].length,
                                                      minimum: -0.5,
                                                      maximum: (i['data']).length.toDouble(),
                                                      visibleMinimum: -0.5,
                                                      visibleMaximum: (i['data'])!.length <= 3 ? (i['data'])!.length.toDouble() - 0.5 : 3,
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                      isVisible: true,
                                                      // title: AxisTitle(text: "Dur/Qty"),
                                                      minimum: 0,
                                                    ),
                                                    zoomPanBehavior: ZoomPanBehavior(
                                                      enablePanning: true,
                                                    ),
                                                    series: <CartesianSeries>[
                                                      RangeColumnSeries<dynamic, String>(
                                                          borderRadius: BorderRadius.zero,
                                                          dataSource: (i['data']) ?? [],
                                                          width: 0.4,
                                                          color: Colors.blue.shade200,
                                                          xValueMapper: (dynamic data, _) => "${data.seqName}",
                                                          highValueMapper: (dynamic data, _) => data.preFrom,
                                                          lowValueMapper: (dynamic data, _) => data.preTo
                                                      ),
                                                      RangeColumnSeries<dynamic, String>(
                                                          borderRadius: BorderRadius.circular(0),
                                                          dataSource: (i['data']) ?? [],
                                                          width: 0.4,
                                                          color: Colors.greenAccent,
                                                          xValueMapper: (dynamic data, _) => "${data.seqName}",
                                                          highValueMapper: (dynamic data, _) => data.actualFrom,
                                                          lowValueMapper: (dynamic data, _) => data.actualTo
                                                      ),
                                                      RangeColumnSeries<dynamic, String>(
                                                          borderRadius: BorderRadius.circular(0),
                                                          dataSource: (i['data']) ?? [],
                                                          width: 0.4,
                                                          color: Colors.blue.shade400,
                                                          xValueMapper: (dynamic data, _) => "${data.seqName}",
                                                          highValueMapper: (dynamic data, _) => data.postFrom,
                                                          lowValueMapper: (dynamic data, _) => data.postTo
                                                      ),
                                                      RangeColumnSeries<dynamic, String>(
                                                          borderRadius: BorderRadius.circular(0),
                                                          dataSource: (i['data']) ?? [],
                                                          width: 0.4,
                                                          color: Colors.grey.shade300,
                                                          xValueMapper: (dynamic data, _) => "${data.seqName}",
                                                          highValueMapper: (dynamic data, _) => data.plannedFrom,
                                                          lowValueMapper: (dynamic data, _) => data.plannedTo
                                                      ),
                                                    ],
                                                  )
                                              )
                                            ],
                                          ),
                                        )
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                Container(
                  color: Color(0xff1C7C8A),
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  if(selectedPages != 1){
                                    selectedPages -= 1  ;
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.keyboard_double_arrow_left),
                              ),
                            ),
                            if(dataToShow['fixedColumnData'] != null)
                              Text(
                                '${
                                    (selectedPages * noOfRowsPerPage) - 20} - ${((selectedPages * noOfRowsPerPage) < dataToShow['fixedColumnData'].length
                                    ?  (selectedPages * noOfRowsPerPage)
                                    : dataToShow['fixedColumnData'].length)} / ${dataToShow['fixedColumnData'].length}',style: TextStyle(color: Colors.white),
                              ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  if(selectedPages != totalPages){
                                    selectedPages += 1;
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.keyboard_double_arrow_right),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MaterialButton(
                          color: Colors.white,
                          child: Text('Select Date'),
                          onPressed: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: Text('Date Picker'),
                                content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter stateSetter) {
                                    return SizedBox(
                                      width: 200,
                                      height: 250,
                                      child:SfDateRangePicker(
                                        onSelectionChanged:  _onSelectionChanged,
                                        selectionMode: DateRangePickerSelectionMode.range,
                                        initialSelectedRange: PickerDateRange(
                                          // DateTime.now().subtract(const Duration(days: 4)),
                                          // DateTime.now().add(const Duration(days: 3))
                                            DateTime.now(),
                                            DateTime.now()
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel')
                                  ),
                                  ElevatedButton(
                                      onPressed: ()async{
                                        Navigator.pop(context);
                                        getDialog(context);
                                        getData();
                                        setState(() {
                                          _irrigationOptionWise = [['Date',true],['Program',false],['Line',false],['Valve',false],['Status',false]];
                                        });
                                        if(mounted){
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Ok')
                                  )
                                ],
                              );

                            });
                          }
                      ),
                      InkWell(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (context){
                                var fileName = 'file';
                                return AlertDialog(
                                  title: Text('Give Name For Your File'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        initialValue: fileName,
                                        onChanged: (value){
                                          fileName = value;
                                        },
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder()
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: (){
                                          generateExcel(dataToShow,fileName,context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Click to download')
                                    )
                                  ],
                                );
                              }
                          );


                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white
                          ),
                          child: Icon(Icons.download),
                        ),
                      )
                    ],
                  ),
                  // child: FloatingActionButton(
                  //   backgroundColor: Colors.white,
                  //   onPressed: () {
                  //     showDialog(context: context, builder: (context){
                  //       return AlertDialog(
                  //         title: Text('Date Picker'),
                  //         content: StatefulBuilder(
                  //           builder: (BuildContext context, StateSetter stateSetter) {
                  //             return SizedBox(
                  //               width: 200,
                  //               height: 250,
                  //               child:SfDateRangePicker(
                  //                 onSelectionChanged:  _onSelectionChanged,
                  //                 selectionMode: DateRangePickerSelectionMode.range,
                  //                 initialSelectedRange: PickerDateRange(
                  //                     DateTime.now().subtract(const Duration(days: 4)),
                  //                     DateTime.now().add(const Duration(days: 3))),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //         actions: [
                  //           ElevatedButton(
                  //               onPressed: (){
                  //                 Navigator.pop(context);
                  //               },
                  //               child: Text('Cancel')
                  //           ),
                  //           ElevatedButton(
                  //               onPressed: ()async{
                  //                 Navigator.pop(context);
                  //                 getDialog(context);
                  //                 getData();
                  //                 setState(() {
                  //                   _irrigationOptionWise = [['Date',true],['Program',false],['Line',false],['Valve',false],['Status',false]];
                  //                 });
                  //                 if(mounted){
                  //                   Navigator.pop(context);
                  //                 }
                  //               },
                  //               child: Text('Ok')
                  //           )
                  //         ],
                  //       );
                  //
                  //     });
                  //   },
                  //   child: Text('Select Date'),
                  // ),
                )


              ],
            )
                : SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Network is unreachable!!'),
                  MaterialButton(
                    onPressed: ()async{
                      if(httpError != 2){
                        setState(() {
                          httpError = 2;
                        });
                        await Future.delayed(Duration(seconds: 2));
                        getData();
                      }
                    },
                    child: httpError != 2 ? Text('RETRY',style: TextStyle(color: Colors.white),) : loadingButtuon(),
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
          )
      );
    }
    );
  }

  Widget myButtons({required String name,required void Function() onTap,double? radius,double? verticalPadding,int? index}){
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 10,horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 5),
            color: index != null ? (index == _irrigationOptionWise.indexWhere((element) => element[1] == true) ? Color(0xff1A7886) : null) : Color(0xff1A7886)
        ),
        child: Text(name,style: TextStyle(color: index != null ? (index == _irrigationOptionWise.indexWhere((element) => element[1] == true) ? Colors.white : Colors.black87) : Colors.white,fontSize: 13,fontWeight: FontWeight.w200),),
      ),
    );
  }

  Widget getTableOptionSelector(List data){
    if(data[1] == true){
      return SizedBox(
        width: 100,
        height: 40,
        child: Stack(
          children: [
            SvgPicture.asset(
              'assets/images/tableOptionSelected.svg',
              // color: Color(0xffDDFFE8),
              color: Color(0xff03464F),
            ),
            // Positioned(
            //   top: 10,
            //   left: 0,
            //   child: Container(
            //     width: 15,
            //     height: 20,
            //     decoration: BoxDecoration(
            //       color: Color(0xffffffff),
            //       borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
            //     ),
            //   ),
            // ),
            Positioned(
              top: 15,
              left: 20,
              child: Text('${data[0]}',style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      );
    }else{
      return SizedBox(
        width: 150,
        height: 50,
        child: Center(
          child: Text('${data[0]}',style: TextStyle(color: Colors.black)),
        ),
      );
    }
  }

  void setOriginalToDuplicateParameter({required List<GeneralParameterModel> originalParameterList,required List<GeneralParameterModel> duplicateParameterList}){
    setState(() {
      for(var i = 0;i < originalParameterList.length;i++){
        duplicateParameterList[i].show = originalParameterList[i].show;
      }
    });
  }

  void sideSheet(constraints) {

    for(var i = 0;i < date.length;i++){
      dateDuplicate[i]['show'] = date[i]['show'];
    }
    for(var i = 0;i < line.length;i++){
      lineDuplicate[i]['show'] = line[i]['show'];
    }
    for(var i = 0;i < valve.length;i++){
      valveDuplicate[i]['show'] = valve[i]['show'];
    }
    for(var i = 0;i < program.length;i++){
      programDuplicate[i]['show'] = program[i]['show'];
    }
    for(var i = 0;i < status.length;i++){
      statusDuplicate[i]['show'] = status[i]['show'];
    }
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      // barrierColor: const Color(0xff6600),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.2,
                  child: Scaffold(
                    floatingActionButton: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: customBoxShadow
                      ),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text("Cancel",style: TextStyle(color: Colors.white),),
                            color: Colors.red,
                          ),
                          MaterialButton(
                            onPressed: (){
                              stateSetter(() {
                                // irrigationParameterArray.editParameterList(
                                //     generalParameterListDuplicate: irrigationParameterArrayDuplicate.generalParameterList,
                                //     waterParameterListDuplicate: irrigationParameterArrayDuplicate.waterParameterList,
                                //     centralEcPhParameterListDuplicate: irrigationParameterArrayDuplicate.centralEcPhParameterList,
                                //     centralChannel1ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel1ParameterList,
                                //     centralChannel2ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel2ParameterList,
                                //     centralChannel3ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel3ParameterList,
                                //     centralChannel4ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel4ParameterList,
                                //     centralChannel5ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel5ParameterList,
                                //     centralChannel6ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel6ParameterList,
                                //     centralChannel7ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel7ParameterList,
                                //     centralChannel8ParameterListDuplicate: irrigationParameterArrayDuplicate.centralChannel8ParameterList
                                // );
                                if(_irrigationOptionWise[0][1] == true){
                                  setState(() {
                                    for(var i = 0;i < dateDuplicate.length;i++){
                                      date[i]['show'] = dateDuplicate[i]['show'];
                                    }
                                    dataToShow = irrigationParameterArray.editDateWise(dataSource, date);
                                  });
                                }else if(_irrigationOptionWise[1][1] == true){
                                  setState(() {
                                    for(var i = 0;i < programDuplicate.length;i++){
                                      program[i]['show'] = programDuplicate[i]['show'];
                                    }
                                    dataToShow = irrigationParameterArray.editProgramWise(dataSource, program);
                                  });
                                }else if(_irrigationOptionWise[2][1] == true){
                                  setState(() {
                                    for(var i = 0;i < lineDuplicate.length;i++){
                                      line[i]['show'] = lineDuplicate[i]['show'];
                                    }
                                    dataToShow = irrigationParameterArray.editLineWise(dataSource, line);
                                  });
                                }else if(_irrigationOptionWise[3][1] == true){
                                  setState(() {
                                    for(var i = 0;i < valveDuplicate.length;i++){
                                      valve[i]['show'] = valveDuplicate[i]['show'];
                                    }
                                    dataToShow = irrigationParameterArray.editValveWise(dataSource, valve);
                                  });
                                }
                                else if(_irrigationOptionWise[4][1] == true){
                                  setState(() {
                                    for(var i = 0;i < statusDuplicate.length;i++){
                                      status[i]['show'] = statusDuplicate[i]['show'];
                                    }
                                    dataToShow = irrigationParameterArray.editStatusWise(dataSource, status);
                                  });
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: Text("OK",style: TextStyle(color: Colors.white)),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    body: Container(
                      padding: const EdgeInsets.all(15),
                      // margin: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                      ),
                      height: double.infinity,
                      width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(_irrigationOptionWise[0][1] == true)
                              Column(
                                children: [
                                  SizedBox(height: 40,),
                                  Text('Filter Date',style: headingStyleInSheet,),
                                  for(var i in dateDuplicate)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 250,
                                      child: ListTile(
                                        leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                        title: Text('${i['name']}',style: const TextStyle(fontSize: 12),),
                                        trailing: Checkbox(
                                          value: i['show'],
                                          onChanged: (value) {
                                            stateSetter(() {
                                              i['show'] = value!;
                                            });
                                          },

                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            if(_irrigationOptionWise[1][1] == true)
                              Column(
                                children: [
                                  Text('Filter Program',style: headingStyleInSheet),
                                  for(var i in programDuplicate)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 250,
                                      child: ListTile(
                                        leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                        title: Text('${i['programName']}',style: const TextStyle(fontSize: 12),),
                                        trailing: Checkbox(
                                          value: i['show'],
                                          onChanged: (value) {
                                            stateSetter(() {
                                              i['show'] = value!;
                                            });
                                          },

                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            if(_irrigationOptionWise[2][1] == true)
                              Column(
                                children: [
                                  Text('Filter Line',style: headingStyleInSheet),
                                  for(var i in lineDuplicate)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 250,
                                      child: ListTile(
                                        leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                        title: Text('${i['lineName']}',style: const TextStyle(fontSize: 12),),
                                        trailing: Checkbox(
                                          value: i['show'],
                                          onChanged: (value) {
                                            stateSetter(() {
                                              i['show'] = value!;
                                            });
                                          },

                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            if(_irrigationOptionWise[3][1] == true)
                              Column(
                                children: [
                                  Text('Filter Valve',style: headingStyleInSheet),
                                  for(var i in valveDuplicate)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 250,
                                      child: ListTile(
                                        leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                        title: Text('${i['name']}',style: const TextStyle(fontSize: 12),),
                                        trailing: Checkbox(
                                          value: i['show'],
                                          onChanged: (value) {
                                            stateSetter(() {
                                              i['show'] = value!;
                                            });
                                          },

                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            if(_irrigationOptionWise[4][1] == true)
                              Column(
                                children: [
                                  Text('Filter Status',style: headingStyleInSheet),
                                  for(var i in statusDuplicate)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 250,
                                      child: ListTile(
                                        leading: Icon(Icons.commit,color: Colors.blueGrey,),
                                        title: Text('${getStatus(i['name'])['status']}',style: const TextStyle(fontSize: 12),),
                                        trailing: Checkbox(
                                          value: i['show'],
                                          onChanged: (value) {
                                            stateSetter(() {
                                              i['show'] = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget getChannelFilter({required List<GeneralParameterModel> parameterList,required int channelNo}){
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter stateSetter){
          return Column(
            children: [
              SizedBox(
                width: 250,
                height: 60,
                child: ListTile(
                  title: Text('<C - CH$channelNo> Parameter',style: TextStyle(fontWeight: FontWeight.bold),),
                  leading: Checkbox(
                    value: parameterList[parameterList.length - 1].show,
                    onChanged: (bool? value) {
                      stateSetter(() {
                        parameterList[parameterList.length - 1].show = value!;
                        for(var p in parameterList){
                          p.show = value;
                        }
                      });

                    },
                  ),
                ),
              ),
              for(var i in parameterList)
                if(i.payloadKey != 'overAll')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: 250,
                    child: ListTile(
                      leading: Icon(Icons.adb_outlined,color: Colors.blueGrey,),
                      title: Text('${i.uiKey}',style: const TextStyle(fontSize: 12),),
                      trailing: Checkbox(
                        value: i.show,
                        onChanged: (value) {
                          stateSetter(() {
                            i.show = value!;
                          });
                        },

                      ),
                    ),
                  ),
              SizedBox(
                height: 10,
              ),
            ],
          );
        }
    );

  }

  List<dynamic> filterDataByPages({required data}){
    List<dynamic> slicingList = [];
    int from = (selectedPages * noOfRowsPerPage) - 20;
    int to = (selectedPages * noOfRowsPerPage);
    if(data.length < to){
      to = data.length;
    }
    for(var i = from;i < to;i++){
      slicingList.add(data[i]);
    }
    return slicingList;
  }


  Widget datePickerBuilder(
      BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
      [bool doubleMonth = true]) =>
      DateRangePickerWidget(
        maxDate: DateTime.now(),
        theme: kTheme1,
        height: 400,
        doubleMonth: false,
        maximumDateRangeLength: 100,
        quickDateRanges: [
          // QuickDateRange(dateRange: null, label: "Remove date range"),
          // QuickDateRange(
          //   label: 'Last 3 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 3)),
          //     DateTime.now(),
          //   ),
          // ),
          // QuickDateRange(
          //   label: 'Last 7 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 7)),
          //     DateTime.now(),
          //   ),
          // ),
          // QuickDateRange(
          //   label: 'Last 30 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 30)),
          //     DateTime.now(),
          //   ),
          // ),
          // QuickDateRange(
          //   label: 'Last 90 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 90)),
          //     DateTime.now(),
          //   ),
          // ),
          // QuickDateRange(
          //   label: 'Last 180 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 180)),
          //     DateTime.now(),
          //   ),
          // ),
        ],
        minimumDateRangeLength: 3,
        initialDateRange: selectedDateRange,
        initialDisplayedDate: selectedDateRange?.start ?? DateTime(2023, 11, 20),
        onDateRangeChanged: onDateRangeChanged,
      );
}



Future<void> generateExcel(data,name, context) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Logs'];
  dynamic headerRow = [
    data['fixedColumn'],
    if(data['generalColumnData'][0] != null)
      for(var j = 0;j < data['generalColumnData'][0].length;j++)
        data['generalColumn'][j],
    if(data['waterColumnData'][0] != null)
      for(var j = 0;j < data['waterColumnData'][0].length;j++)
        'Water ${data['waterColumn'][j]}',
    if(data['prePostColumnData'][0] != null)
      for(var j = 0;j < data['prePostColumnData'][0].length;j++)
        data['prePostColumn'][j],
    if(data['centralEcPhColumnData'][0] != null)
      for(var j = 0;j < data['centralEcPhColumnData'][0].length;j++)
        data['centralEcPhColumn'][j],
    for(var i = 1;i < 7;i++)
      if(data['centralChannel${i}ColumnData'][0] != null)
        for(var j = 0;j < data['centralChannel${i}ColumnData'][0].length;j++)
          'CH${i} - ${data['centralChannel${i}Column'][j]}',
    if(data['localEcPhColumnData'][0] != null)
      for(var j = 0;j < data['localEcPhColumnData'][0].length;j++)
        data['localEcPhColumn'][j],
    for(var i = 1;i < 7;i++)
      if(data['localChannel${i}ColumnData'][0] != null)
        for(var j = 0;j < data['localChannel${i}ColumnData'][0].length;j++)
          'LH${i} - ${data['localChannel${i}Column'][j]}',

  ];
  sheetObject.appendRow([for(var i in headerRow) TextCellValue(i)]);
  for(var i = 0;i < data['fixedColumnData'].length;i++){
    List<String> eachRow = [data['fixedColumnData'][i]];
    for(var columnData in ['generalColumnData','waterColumnData','prePostColumnData','centralEcPhColumnData',
      for(var i = 1;i < 7;i++)
        'centralChannel${i}ColumnData',
      'localEcPhColumnData',
      for(var i = 1;i < 7;i++)
        'localChannel${i}ColumnData',
    ]){
      if(data[columnData][0] != null){
        for(var j = 0;j < data[columnData][i].length;j++)
          eachRow.add('${data[columnData][i][j]}');
      }
    }
    sheetObject.appendRow([for(var cell in eachRow) TextCellValue(cell)]);
  }

  // Save the file
  var fileBytes = excel.encode();
  if (fileBytes != null) {
    try {
      String downloadsDirectoryPath = "/storage/emulated/0/Download";
      String filePath = "$downloadsDirectoryPath/$name.xlsx";
      File file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);
      // Check if file exists
      if (await file.exists()) {
        // Scaffold.of(context).showSnackBar()
        Navigator.pop(context);
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text('$name Download Successfully at'),
            content: Text('$filePath'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Ok')
              )
            ],
          );
        });
        print("Excel file saved successfully at $filePath");
      } else {
        Navigator.pop(context);
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text('$name Download failed..'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Ok')
              )
            ],
          );
        });
        log("Failed to save the Excel file.");
      }
    } catch (e) {
      log("Error saving the Excel file: $e");
    }
  } else {
    log("Error encoding the Excel file.");
  }
}

void getDialog(context){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Please wait......'),
          content: Text('Processing.....'),
        );
      }
  );
}

const CalendarTheme kTheme1 = CalendarTheme(
  selectedColor: Color(0xff10E196),
  dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
  inRangeColor: Color(0xFFDFFEF3),
  inRangeTextStyle: TextStyle(color: Color(0xff006943)),
  selectedTextStyle: TextStyle(color: Colors.white),
  todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
  defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
  radius: 10,
  tileSize: 40,
  disabledTextStyle: TextStyle(color: Colors.grey),
);
class _ChartData {
  _ChartData(this.x, this.y,this.z);

  final String x;
  final double y;
  final String z;
}










Widget getTableHeader(name,flex){
  return Expanded(
      flex: flex,
      child: Container(
        // color: Colors.green.shade50,
        height: 40,
        child: Center(
          child: Text('$name',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w900),),
        ),
      )
  );
}

Widget getTableRow(name,flex){
  return Expanded(
      flex: flex,
      child: Container(
        // color: Colors.green.shade50,
        height: 40,
        child: Center(
          child: Text('$name',style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500),),
        ),
      )
  );
}
Widget getTableRowLinearIndicater(seting,flex){
  return Expanded(
    flex: flex,
    child: ListTile(
      title: Text('${seting['output']}',style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
      subtitle:  LinearProgressIndicator(
        // backgroundColor: Color(0xff11E196),
        backgroundColor: Colors.grey.shade300,
        // color: Color(0xff006943),
        // color: Color(0xff00404A),
        color: const Color(0xff10E196),
        minHeight: 7,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        // value: timeToSeconds(name) as double, // Update this value to reflect loading progress
        value: timeToSeconds(seting), // Update this value to reflect loading progress
      ),
    ),
  );
}
double timeToSeconds(dynamic timeString) {
  List<String> input = timeString['input'].split(':');
  List<String> output = timeString['output'].split(':');
  int hours = int.parse(input[0]);
  int minutes = int.parse(input[1]);
  int seconds = int.parse(input[2]);
  int hours1 = int.parse(output[0]);
  int minutes1 = int.parse(output[1]);
  int seconds1 = int.parse(output[2]);
  var total = hours * 3600 + minutes * 60 + seconds;
  var total1 = hours1 * 3600 + minutes1 * 60 + seconds1;
  print('result : ${(total/total1).toStringAsFixed(2)}');
  return total1/total;
}

Widget chartColorInformation(String title,List<Color> color,textColor){
  return Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
                colors: [
                  ...color
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
            )
        ),

      ),
      const SizedBox(width: 10,),
      Text(title,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: Colors.black),),
    ],
  );
}
double convertTimeStringToHours(String timeString) {
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);

  double totalHours = hours + (minutes / 60) + (seconds / 3600);
  return totalHours;
}
TextStyle headingStyleInSheet = TextStyle(fontSize: 14,fontWeight: FontWeight.bold);

Widget loadingButtuon(){
  return SizedBox(
    width: 20,
    height: 20,
    child: LoadingIndicator(
      colors: [
        Colors.white,
        Colors.white,
      ],
      indicatorType: Indicator.ballPulse,
    ),
  );
}

