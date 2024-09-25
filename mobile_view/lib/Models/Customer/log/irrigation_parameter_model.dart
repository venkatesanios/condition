
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../constants/data_convertion.dart';
class GeneralParameterModel {
  final String payloadKey;
  final String uiKey;
  bool show;
  GeneralParameterModel({
    required this.payloadKey,
    required this.uiKey,
    required this.show,
  });
}

class waterParameterModel {
  final String payloadKey;
  final String uiKey;
  bool show;
  waterParameterModel({
    required this.payloadKey,
    required this.uiKey,
    required this.show,
  });
}

class IrrigationLog {
  List<GeneralParameterModel> generalParameterList = [];
  List<GeneralParameterModel> waterParameterList = [];
  List<GeneralParameterModel> prePostParameterList = [];
  List<GeneralParameterModel> filterParameterList = [];
  List<GeneralParameterModel> centralEcPhParameterList = [];
  List<GeneralParameterModel> centralChannel1ParameterList = [];
  List<GeneralParameterModel> centralChannel2ParameterList = [];
  List<GeneralParameterModel> centralChannel3ParameterList = [];
  List<GeneralParameterModel> centralChannel4ParameterList = [];
  List<GeneralParameterModel> centralChannel5ParameterList = [];
  List<GeneralParameterModel> centralChannel6ParameterList = [];
  List<GeneralParameterModel> centralChannel7ParameterList = [];
  List<GeneralParameterModel> centralChannel8ParameterList = [];
  List<GeneralParameterModel> localEcPhParameterList = [];
  List<GeneralParameterModel> localChannel1ParameterList = [];
  List<GeneralParameterModel> localChannel2ParameterList = [];
  List<GeneralParameterModel> localChannel3ParameterList = [];
  List<GeneralParameterModel> localChannel4ParameterList = [];
  List<GeneralParameterModel> localChannel5ParameterList = [];
  List<GeneralParameterModel> localChannel6ParameterList = [];
  List<GeneralParameterModel> localChannel7ParameterList = [];
  List<GeneralParameterModel> localChannel8ParameterList = [];

  IrrigationLog();

  List<GeneralParameterModel> getListOfGeneralParameterModel({required name,required keyList,required data}){
    List<GeneralParameterModel> list = [];
    for(var i in keyList){
      list.add(
          GeneralParameterModel(
              payloadKey: '$i',
              uiKey: '${data[name]['$i'][0]}',
              show: data[name]['$i'][1]
          )
      );
    }
    return list;
  }

  void editParameter(Map<String,dynamic>data){
    if(data.isNotEmpty){
      generalParameterList = getListOfGeneralParameterModel(name: 'general', keyList: data['general'].keys.toList(), data: data);
      waterParameterList = getListOfGeneralParameterModel(name: 'irrigation', keyList: data['irrigation'].keys.toList(), data: data);
      prePostParameterList = getListOfGeneralParameterModel(name: 'prePost', keyList: data['prePost'].keys.toList(), data: data);
      filterParameterList = getListOfGeneralParameterModel(name: 'filter', keyList: data['filter'].keys.toList(), data: data);
      centralEcPhParameterList = getListOfGeneralParameterModel(name: 'centralEcPh', keyList: data['centralEcPh'].keys.toList(), data: data);
      centralChannel1ParameterList = getListOfGeneralParameterModel(name: '<C - CH1>', keyList: data['<C - CH1>'].keys.toList(), data: data);
      centralChannel2ParameterList = getListOfGeneralParameterModel(name: '<C - CH2>', keyList: data['<C - CH2>'].keys.toList(), data: data);
      centralChannel3ParameterList = getListOfGeneralParameterModel(name: '<C - CH3>', keyList: data['<C - CH3>'].keys.toList(), data: data);
      centralChannel4ParameterList = getListOfGeneralParameterModel(name: '<C - CH4>', keyList: data['<C - CH4>'].keys.toList(), data: data);
      centralChannel5ParameterList = getListOfGeneralParameterModel(name: '<C - CH5>', keyList: data['<C - CH5>'].keys.toList(), data: data);
      centralChannel6ParameterList = getListOfGeneralParameterModel(name: '<C - CH6>', keyList: data['<C - CH6>'].keys.toList(), data: data);
      centralChannel7ParameterList = getListOfGeneralParameterModel(name: '<C - CH7>', keyList: data['<C - CH7>'].keys.toList(), data: data);
      centralChannel8ParameterList = getListOfGeneralParameterModel(name: '<C - CH8>', keyList: data['<C - CH8>'].keys.toList(), data: data);
      localEcPhParameterList = getListOfGeneralParameterModel(name: 'localEcPh', keyList: data['localEcPh'].keys.toList(), data: data);
      localChannel1ParameterList = getListOfGeneralParameterModel(name: '<L - CH1>', keyList: data['<L - CH1>'].keys.toList(), data: data);
      localChannel2ParameterList = getListOfGeneralParameterModel(name: '<L - CH2>', keyList: data['<L - CH2>'].keys.toList(), data: data);
      localChannel3ParameterList = getListOfGeneralParameterModel(name: '<L - CH3>', keyList: data['<L - CH3>'].keys.toList(), data: data);
      localChannel4ParameterList = getListOfGeneralParameterModel(name: '<L - CH4>', keyList: data['<L - CH4>'].keys.toList(), data: data);
      localChannel5ParameterList = getListOfGeneralParameterModel(name: '<L - CH5>', keyList: data['<L - CH5>'].keys.toList(), data: data);
      localChannel6ParameterList = getListOfGeneralParameterModel(name: '<L - CH6>', keyList: data['<L - CH6>'].keys.toList(), data: data);
      localChannel7ParameterList = getListOfGeneralParameterModel(name: '<L - CH7>', keyList: data['<L - CH7>'].keys.toList(), data: data);
      localChannel8ParameterList = getListOfGeneralParameterModel(name: '<L - CH8>', keyList: data['<L - CH8>'].keys.toList(), data: data);
    }
  }

  dynamic toJson(){
    dynamic serverData = {
      'general' : {},
      'irrigation' : {},
      'filter' : {},
      'prePost' : {},
      'centralEcPh' : {},
      '<C - CH1>' : {},
      '<C - CH2>' : {},
      '<C - CH3>' : {},
      '<C - CH4>' : {},
      '<C - CH5>' : {},
      '<C - CH6>' : {},
      '<C - CH7>' : {},
      '<C - CH8>' : {},
      'localEcPh' : {},
      '<L - CH1>' : {},
      '<L - CH2>' : {},
      '<L - CH3>' : {},
      '<L - CH4>' : {},
      '<L - CH5>' : {},
      '<L - CH6>' : {},
      '<L - CH7>' : {},
      '<L - CH8>' : {},
    };

    for(var i in generalParameterList!){
      serverData['general']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in waterParameterList!){
      serverData['irrigation']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in filterParameterList!){
      serverData['filter']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in prePostParameterList!){
      serverData['prePost']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralEcPhParameterList!){
      serverData['centralEcPh']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel1ParameterList!){
      serverData['<C - CH1>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel2ParameterList!){
      serverData['<C - CH2>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel3ParameterList!){
      serverData['<C - CH3>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel4ParameterList!){
      serverData['<C - CH4>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel5ParameterList!){
      serverData['<C - CH5>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel6ParameterList!){
      serverData['<C - CH6>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel7ParameterList!){
      serverData['<C - CH7>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in centralChannel8ParameterList!){
      serverData['<C - CH8>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localEcPhParameterList!){
      serverData['localEcPh']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel1ParameterList!){
      serverData['<L - CH1>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel2ParameterList!){
      serverData['<L - CH2>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel3ParameterList!){
      serverData['<L - CH3>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel4ParameterList!){
      serverData['<L - CH4>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel5ParameterList!){
      serverData['<L - CH5>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel6ParameterList!){
      serverData['<L - CH6>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel7ParameterList!){
      serverData['<L - CH7>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    for(var i in localChannel8ParameterList!){
      serverData['<L - CH8>']['${i.payloadKey}'] = [i.uiKey,i.show];
    }
    print('serverData => $serverData');
    return serverData;
  }


  Map<String,dynamic> editValveWise(dynamic dataSource,List<dynamic> noOfValve){
    var generalColumn = [...getColumn(generalParameterList)];
    var generalColumnData = [];
    var fixedColumnData = [];
    var waterColumn = [...getColumn(waterParameterList)];
    var waterColumnData = [];
    var prePostColumn = [...getColumn(prePostParameterList)];
    var prePostColumnData = [];
    var filterColumn = [...getColumn(filterParameterList)];
    var filterColumnData = [];
    var centralEcPhColumn = [...getColumn(centralEcPhParameterList)];
    var centralEcPhColumnData = [];
    var centralChannel1Column = [...getColumn(centralChannel1ParameterList)];
    var centralChannel1ColumnData = [];
    var centralChannel2Column = [...getColumn(centralChannel2ParameterList)];
    var centralChannel2ColumnData = [];
    var centralChannel3Column = [...getColumn(centralChannel3ParameterList)];
    var centralChannel3ColumnData = [];
    var centralChannel4Column = [...getColumn(centralChannel4ParameterList)];
    var centralChannel4ColumnData = [];
    var centralChannel5Column = [...getColumn(centralChannel5ParameterList)];
    var centralChannel5ColumnData = [];
    var centralChannel6Column = [...getColumn(centralChannel6ParameterList)];
    var centralChannel6ColumnData = [];
    var centralChannel7Column = [...getColumn(centralChannel7ParameterList)];
    var centralChannel7ColumnData = [];
    var centralChannel8Column = [...getColumn(centralChannel8ParameterList)];
    var centralChannel8ColumnData = [];
    var localEcPhColumn = [...getColumn(localEcPhParameterList)];
    var localEcPhColumnData = [];
    var localChannel1Column = [...getColumn(localChannel1ParameterList)];
    var localChannel1ColumnData = [];
    var localChannel2Column = [...getColumn(localChannel2ParameterList)];
    var localChannel2ColumnData = [];
    var localChannel3Column = [...getColumn(localChannel3ParameterList)];
    var localChannel3ColumnData = [];
    var localChannel4Column = [...getColumn(localChannel4ParameterList)];
    var localChannel4ColumnData = [];
    var localChannel5Column = [...getColumn(localChannel5ParameterList)];
    var localChannel5ColumnData = [];
    var localChannel6Column = [...getColumn(localChannel6ParameterList)];
    var localChannel6ColumnData = [];
    var localChannel7Column = [...getColumn(localChannel7ParameterList)];
    var localChannel7ColumnData = [];
    var localChannel8Column = [...getColumn(localChannel8ParameterList)];
    var localChannel8ColumnData = [];
    var graphData = [];
    var fixedColumn = 'Valve';
    generalColumn.remove('Valve');
    generalColumn.remove('Sequence');
    for(var findValve in noOfValve){
      if(findValve['show'] == true){
        graphData.add({
          'name' : findValve['name'],
          'data' : []
        });
        var indexOfDataToAdd = graphData.length - 1;
        for(var date in dataSource){
          if(date['irrigation'].isNotEmpty){
            for(var howManyValve = 0;howManyValve < date['irrigation']['SequenceData'].length;howManyValve++){
              if(date['irrigation']['SequenceData'][howManyValve].contains(findValve['name'])){
                fixedColumnData.add(findValve['name']);
                var myList = [];
                var waterList = [];
                var prePostList = [];
                var centralEcPhList = [];
                var localEcPhList = [];
                var filterList = [];
                generalParameterLoop : for(var parameter in generalParameterList){
                  if(parameter.payloadKey == 'ProgramName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramName'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'Status') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Status'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'Date') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Date'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramCategoryName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramCategoryName'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'ScheduledStartTime') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ScheduledStartTime'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'Pump') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Pump'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramStartStopReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramStartStopReason'].length > howManyValve){
                        myList.add(date['irrigation']['ProgramStartStopReason'][howManyValve]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                  if(parameter.payloadKey == 'ProgramPauseResumeReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramPauseResumeReason'].length > howManyValve){
                        myList.add(date['irrigation']['ProgramPauseResumeReason'][howManyValve]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                }
                waterParameterLoop : for(var parameter in waterParameterList){
                  if(parameter.payloadKey == 'IrrigationMethod') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationMethod'][howManyValve] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDuration_Quantity') {
                    graphData[indexOfDataToAdd]['data'].add(
                        getGraphData(
                            method: date['irrigation']['IrrigationMethod'][howManyValve],
                            planned: date['irrigation']['IrrigationDuration_Quantity'][howManyValve],
                            actualDuration: date['irrigation']['IrrigationDurationCompleted'][howManyValve],
                            actualLiters: date['irrigation']['IrrigationQuantityCompleted'][howManyValve],
                            flowRate: date['irrigation']['ValveFlowrate'][howManyValve],
                            name: '${date['irrigation']['Date'][howManyValve]}\n${date['irrigation']['ScheduledStartTime'][howManyValve]}'
                        )
                    );

                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationDuration_Quantity'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDurationCompleted/IrrigationQuantityCompleted') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation'][date['irrigation']['IrrigationMethod'][howManyValve] == 1 ? parameter.payloadKey.split('/')[0] : parameter.payloadKey.split('/')[1]][howManyValve]);
                    }
                  }
                }
                prePostParameterLoop : for(var parameter in prePostParameterList){
                  if(parameter.payloadKey == 'PrePostMethod') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation']['PrePostMethod'][howManyValve] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'Pretime/PreQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyValve] == 1 ? 'Pretime' : 'PreQty'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'PostTime/PostQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyValve] == 1 ? 'PostTime' : 'PostQty'][howManyValve]);
                    }
                  }
                }
                filterParameterLoop : for(var parameter in filterParameterList){
                  if(parameter.payloadKey == 'CentralFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['CentralFilterName'][howManyValve];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                  if(parameter.payloadKey == 'LocalFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['LocalFilterName'][howManyValve];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                }
                centralEcPhParameterLoop : for(var parameter in centralEcPhParameterList){
                  if(parameter.payloadKey == 'CentralEcSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralEcSetValue'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralPhSetValue'][howManyValve]);
                    }
                  }
                }
                localEcPhParameterLoop : for(var parameter in localEcPhParameterList){
                  if(parameter.payloadKey == 'LocalEcSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalEcSetValue'][howManyValve]);
                    }
                  }
                  if(parameter.payloadKey == 'LocalPhSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalPhSetValue'][howManyValve]);
                    }
                  }
                }
                generalColumnData.add(myList);
                waterColumnData.add(waterList);
                prePostColumnData.add(prePostList);
                filterColumnData.add(filterList);
                centralEcPhColumnData.add(centralEcPhList);
                centralChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: centralChannel1ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: centralChannel2ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: centralChannel3ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: centralChannel4ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: centralChannel5ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: centralChannel6ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: centralChannel7ParameterList, date: date, howMany: howManyValve, central: true));
                centralChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: centralChannel8ParameterList, date: date, howMany: howManyValve, central: true));
                localEcPhColumnData.add(localEcPhList);
                localChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: localChannel1ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: localChannel2ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: localChannel3ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: localChannel4ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: localChannel5ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: localChannel6ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: localChannel7ParameterList, date: date, howMany: howManyValve, central: false));
                localChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: localChannel8ParameterList, date: date, howMany: howManyValve, central: false));
              }
            }
          }
        }
      }
    }

    return {
      'fixedColumn' : fixedColumn,
      'fixedColumnData': fixedColumnData,
      'generalColumn' : generalColumn,
      'generalColumnData' : generalColumnData,
      'waterColumn' : waterColumn,
      'waterColumnData' : waterColumnData,
      'prePostColumn' : prePostColumn,
      'prePostColumnData' : prePostColumnData,
      'filterColumn' : filterColumn,
      'filterColumnData' : filterColumnData,
      'centralEcPhColumn' : centralEcPhColumn,
      'centralEcPhColumnData' : centralEcPhColumnData,
      'centralChannel1Column' : centralChannel1Column,
      'centralChannel1ColumnData' : centralChannel1ColumnData,
      'centralChannel2Column' : centralChannel2Column,
      'centralChannel2ColumnData' : centralChannel2ColumnData,
      'centralChannel3Column' : centralChannel3Column,
      'centralChannel3ColumnData' : centralChannel3ColumnData,
      'centralChannel4Column' : centralChannel4Column,
      'centralChannel4ColumnData' : centralChannel4ColumnData,
      'centralChannel5Column' : centralChannel5Column,
      'centralChannel5ColumnData' : centralChannel5ColumnData,
      'centralChannel6Column' : centralChannel6Column,
      'centralChannel6ColumnData' : centralChannel6ColumnData,
      'centralChannel7Column' : centralChannel7Column,
      'centralChannel7ColumnData' : centralChannel7ColumnData,
      'centralChannel8Column' : centralChannel8Column,
      'centralChannel8ColumnData' : centralChannel8ColumnData,
      'localEcPhColumn' : localEcPhColumn,
      'localEcPhColumnData' : localEcPhColumnData,
      'localChannel1Column' : localChannel1Column,
      'localChannel1ColumnData' : localChannel1ColumnData,
      'localChannel2Column' : localChannel2Column,
      'localChannel2ColumnData' : localChannel2ColumnData,
      'localChannel3Column' : localChannel3Column,
      'localChannel3ColumnData' : localChannel3ColumnData,
      'localChannel4Column' : localChannel4Column,
      'localChannel4ColumnData' : localChannel4ColumnData,
      'localChannel5Column' : localChannel5Column,
      'localChannel5ColumnData' : localChannel5ColumnData,
      'localChannel6Column' : localChannel6Column,
      'localChannel6ColumnData' : localChannel6ColumnData,
      'localChannel7Column' : localChannel7Column,
      'localChannel7ColumnData' : localChannel7ColumnData,
      'localChannel8Column' : localChannel8Column,
      'localChannel8ColumnData' : localChannel8ColumnData,
      'graphData' : graphData
    };
  }

  Map<String,dynamic> editLineWise(dynamic dataSource,List<dynamic> noOfLine){
    var generalColumn = [...getColumn(generalParameterList)];
    var generalColumnData = [];
    var fixedColumnData = [];
    var waterColumn = [...getColumn(waterParameterList)];
    var waterColumnData = [];
    var prePostColumn = [...getColumn(prePostParameterList)];
    var prePostColumnData = [];
    var filterColumn = [...getColumn(filterParameterList)];
    var filterColumnData = [];
    var centralEcPhColumn = [...getColumn(centralEcPhParameterList)];
    var centralEcPhColumnData = [];
    var centralChannel1Column = [...getColumn(centralChannel1ParameterList)];
    var centralChannel1ColumnData = [];
    var centralChannel2Column = [...getColumn(centralChannel2ParameterList)];
    var centralChannel2ColumnData = [];
    var centralChannel3Column = [...getColumn(centralChannel3ParameterList)];
    var centralChannel3ColumnData = [];
    var centralChannel4Column = [...getColumn(centralChannel4ParameterList)];
    var centralChannel4ColumnData = [];
    var centralChannel5Column = [...getColumn(centralChannel5ParameterList)];
    var centralChannel5ColumnData = [];
    var centralChannel6Column = [...getColumn(centralChannel6ParameterList)];
    var centralChannel6ColumnData = [];
    var centralChannel7Column = [...getColumn(centralChannel7ParameterList)];
    var centralChannel7ColumnData = [];
    var centralChannel8Column = [...getColumn(centralChannel8ParameterList)];
    var centralChannel8ColumnData = [];
    var localEcPhColumn = [...getColumn(localEcPhParameterList)];
    var localEcPhColumnData = [];
    var localChannel1Column = [...getColumn(localChannel1ParameterList)];
    var localChannel1ColumnData = [];
    var localChannel2Column = [...getColumn(localChannel2ParameterList)];
    var localChannel2ColumnData = [];
    var localChannel3Column = [...getColumn(localChannel3ParameterList)];
    var localChannel3ColumnData = [];
    var localChannel4Column = [...getColumn(localChannel4ParameterList)];
    var localChannel4ColumnData = [];
    var localChannel5Column = [...getColumn(localChannel5ParameterList)];
    var localChannel5ColumnData = [];
    var localChannel6Column = [...getColumn(localChannel6ParameterList)];
    var localChannel6ColumnData = [];
    var localChannel7Column = [...getColumn(localChannel7ParameterList)];
    var localChannel7ColumnData = [];
    var localChannel8Column = [...getColumn(localChannel8ParameterList)];
    var localChannel8ColumnData = [];
    var graphData = [];
    var fixedColumn = 'Line';
    generalColumn.remove('Line');
    generalColumn.remove('Valve');
    for(var findLine in noOfLine){
      if(findLine['show'] == true){
        graphData.add({
          'name' : findLine['name'],
          'data' : []
        });
        var indexOfDataToAdd = graphData.length - 1;
        for(var date in dataSource){
          if(date['irrigation'].isNotEmpty){
            for(var howManyLine = 0;howManyLine < date['irrigation']['ProgramCategory'].length;howManyLine++){
              if(date['irrigation']['ProgramCategory'][howManyLine].contains(findLine['name'])){
                fixedColumnData.add(findLine['lineName']);
                var myList = [];
                var waterList = [];
                var prePostList = [];
                var centralEcPhList = [];
                var localEcPhList = [];
                var filterList = [];
                generalParameterLoop : for(var parameter in generalParameterList){
                  if(parameter.payloadKey == 'ProgramName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramName'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'Status') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Status'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'SequenceData') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['SequenceData'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'Date') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Date'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'ScheduledStartTime') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ScheduledStartTime'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'Pump') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Pump'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramStartStopReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramStartStopReason'].length > howManyLine){
                        myList.add(date['irrigation']['ProgramStartStopReason'][howManyLine]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                  if(parameter.payloadKey == 'ProgramPauseResumeReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramPauseResumeReason'].length > howManyLine){
                        myList.add(date['irrigation']['ProgramPauseResumeReason'][howManyLine]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                }
                waterParameterLoop : for(var parameter in waterParameterList){
                  if(parameter.payloadKey == 'IrrigationMethod') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationMethod'][howManyLine] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDuration_Quantity') {
                    graphData[indexOfDataToAdd]['data'].add(
                        getGraphData(
                            method: date['irrigation']['IrrigationMethod'][howManyLine],
                            planned: date['irrigation']['IrrigationDuration_Quantity'][howManyLine],
                            actualDuration: date['irrigation']['IrrigationDurationCompleted'][howManyLine],
                            actualLiters: date['irrigation']['IrrigationQuantityCompleted'][howManyLine],
                            flowRate: date['irrigation']['ValveFlowrate'][howManyLine],
                            name: '${date['irrigation']['Date'][howManyLine]}\n${date['irrigation']['ScheduledStartTime'][howManyLine]}'
                        )
                    );
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationDuration_Quantity'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDurationCompleted/IrrigationQuantityCompleted') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation'][date['irrigation']['IrrigationMethod'][howManyLine] == 1 ? parameter.payloadKey.split('/')[0] : parameter.payloadKey.split('/')[1]][howManyLine]);
                    }
                  }
                }
                prePostParameterLoop : for(var parameter in prePostParameterList){
                  if(parameter.payloadKey == 'PrePostMethod') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation']['PrePostMethod'][howManyLine] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'Pretime/PreQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyLine] == 1 ? 'Pretime' : 'PreQty'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'PostTime/PostQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyLine] == 1 ? 'PostTime' : 'PostQty'][howManyLine]);
                    }
                  }
                }
                filterParameterLoop : for(var parameter in filterParameterList){
                  if(parameter.payloadKey == 'CentralFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['CentralFilterName'][howManyLine];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                  if(parameter.payloadKey == 'LocalFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['LocalFilterName'][howManyLine];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                }
                centralEcPhParameterLoop : for(var parameter in centralEcPhParameterList){
                  if(parameter.payloadKey == 'CentralEcSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralEcSetValue'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralPhSetValue'][howManyLine]);
                    }
                  }
                }
                localEcPhParameterLoop : for(var parameter in localEcPhParameterList){
                  if(parameter.payloadKey == 'LocalEcSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalEcSetValue'][howManyLine]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalPhSetValue'][howManyLine]);
                    }
                  }
                }
                generalColumnData.add(myList);
                waterColumnData.add(waterList);
                prePostColumnData.add(prePostList);
                filterColumnData.add(filterList);
                centralEcPhColumnData.add(centralEcPhList);
                centralChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: centralChannel1ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: centralChannel2ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: centralChannel3ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: centralChannel4ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: centralChannel5ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: centralChannel6ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: centralChannel7ParameterList, date: date, howMany: howManyLine, central: true));
                centralChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: centralChannel8ParameterList, date: date, howMany: howManyLine, central: true));
                localEcPhColumnData.add(localEcPhList);
                localChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: localChannel1ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: localChannel2ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: localChannel3ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: localChannel4ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: localChannel5ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: localChannel6ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: localChannel7ParameterList, date: date, howMany: howManyLine, central: false));
                localChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: localChannel8ParameterList, date: date, howMany: howManyLine, central: false));

              }

            }
          }

        }
      }
    }
    return {
      'fixedColumn' : fixedColumn,
      'fixedColumnData': fixedColumnData,
      'generalColumn' : generalColumn,
      'generalColumnData' : generalColumnData,
      'waterColumn' : waterColumn,
      'waterColumnData' : waterColumnData,
      'prePostColumn' : prePostColumn,
      'prePostColumnData' : prePostColumnData,
      'filterColumn' : filterColumn,
      'filterColumnData' : filterColumnData,
      'centralEcPhColumn' : centralEcPhColumn,
      'centralEcPhColumnData' : centralEcPhColumnData,
      'centralChannel1Column' : centralChannel1Column,
      'centralChannel1ColumnData' : centralChannel1ColumnData,
      'centralChannel2Column' : centralChannel2Column,
      'centralChannel2ColumnData' : centralChannel2ColumnData,
      'centralChannel3Column' : centralChannel3Column,
      'centralChannel3ColumnData' : centralChannel3ColumnData,
      'centralChannel4Column' : centralChannel4Column,
      'centralChannel4ColumnData' : centralChannel4ColumnData,
      'centralChannel5Column' : centralChannel5Column,
      'centralChannel5ColumnData' : centralChannel5ColumnData,
      'centralChannel6Column' : centralChannel6Column,
      'centralChannel6ColumnData' : centralChannel6ColumnData,
      'centralChannel7Column' : centralChannel7Column,
      'centralChannel7ColumnData' : centralChannel7ColumnData,
      'centralChannel8Column' : centralChannel8Column,
      'centralChannel8ColumnData' : centralChannel8ColumnData,
      'localEcPhColumn' : localEcPhColumn,
      'localEcPhColumnData' : localEcPhColumnData,
      'localChannel1Column' : localChannel1Column,
      'localChannel1ColumnData' : localChannel1ColumnData,
      'localChannel2Column' : localChannel2Column,
      'localChannel2ColumnData' : localChannel2ColumnData,
      'localChannel3Column' : localChannel3Column,
      'localChannel3ColumnData' : localChannel3ColumnData,
      'localChannel4Column' : localChannel4Column,
      'localChannel4ColumnData' : localChannel4ColumnData,
      'localChannel5Column' : localChannel5Column,
      'localChannel5ColumnData' : localChannel5ColumnData,
      'localChannel6Column' : localChannel6Column,
      'localChannel6ColumnData' : localChannel6ColumnData,
      'localChannel7Column' : localChannel7Column,
      'localChannel7ColumnData' : localChannel7ColumnData,
      'localChannel8Column' : localChannel8Column,
      'localChannel8ColumnData' : localChannel8ColumnData,
      'graphData' : graphData
    };

  }

  Map<String,dynamic> editProgramWise(dynamic dataSource,List<dynamic> noOfProgram){
    var generalColumn = [...getColumn(generalParameterList)];
    var generalColumnData = [];
    var fixedColumnData = [];
    var waterColumn = [...getColumn(waterParameterList)];
    var waterColumnData = [];
    var prePostColumn = [...getColumn(prePostParameterList)];
    var prePostColumnData = [];
    var filterColumn = [...getColumn(filterParameterList)];
    var filterColumnData = [];
    var centralEcPhColumn = [...getColumn(centralEcPhParameterList)];
    var centralEcPhColumnData = [];
    var centralChannel1Column = [...getColumn(centralChannel1ParameterList)];
    var centralChannel1ColumnData = [];
    var centralChannel2Column = [...getColumn(centralChannel2ParameterList)];
    var centralChannel2ColumnData = [];
    var centralChannel3Column = [...getColumn(centralChannel3ParameterList)];
    var centralChannel3ColumnData = [];
    var centralChannel4Column = [...getColumn(centralChannel4ParameterList)];
    var centralChannel4ColumnData = [];
    var centralChannel5Column = [...getColumn(centralChannel5ParameterList)];
    var centralChannel5ColumnData = [];
    var centralChannel6Column = [...getColumn(centralChannel6ParameterList)];
    var centralChannel6ColumnData = [];
    var centralChannel7Column = [...getColumn(centralChannel7ParameterList)];
    var centralChannel7ColumnData = [];
    var centralChannel8Column = [...getColumn(centralChannel8ParameterList)];
    var centralChannel8ColumnData = [];
    var localEcPhColumn = [...getColumn(localEcPhParameterList)];
    var localEcPhColumnData = [];
    var localChannel1Column = [...getColumn(localChannel1ParameterList)];
    var localChannel1ColumnData = [];
    var localChannel2Column = [...getColumn(localChannel2ParameterList)];
    var localChannel2ColumnData = [];
    var localChannel3Column = [...getColumn(localChannel3ParameterList)];
    var localChannel3ColumnData = [];
    var localChannel4Column = [...getColumn(localChannel4ParameterList)];
    var localChannel4ColumnData = [];
    var localChannel5Column = [...getColumn(localChannel5ParameterList)];
    var localChannel5ColumnData = [];
    var localChannel6Column = [...getColumn(localChannel6ParameterList)];
    var localChannel6ColumnData = [];
    var localChannel7Column = [...getColumn(localChannel7ParameterList)];
    var localChannel7ColumnData = [];
    var localChannel8Column = [...getColumn(localChannel8ParameterList)];
    var localChannel8ColumnData = [];
    var graphData = [];

    var fixedColumn = 'Program';
    generalColumn.remove('Program');
    generalColumn.remove('Valve');
    for(var findProgram in noOfProgram){
      if(findProgram['show'] == true){
        graphData.add({
          'name' : 'Program ${findProgram['name']}',
          'data' : []
        });
        var indexOfDataToAdd = graphData.length - 1;
        for(var date in dataSource){
          if(date['irrigation'].isNotEmpty){
            for(var howManyProgram = 0;howManyProgram < date['irrigation']['ProgramS_No'].length;howManyProgram++){
              if(date['irrigation']['ProgramS_No'][howManyProgram] == findProgram['name']){
                fixedColumnData.add(date['irrigation']['ProgramName'][howManyProgram]);
                var myList = [];
                var waterList = [];
                var prePostList = [];
                var centralEcPhList = [];
                var localEcPhList = [];
                var filterList = [];
                generalParameterLoop : for(var parameter in generalParameterList){
                  if(parameter.payloadKey == 'Status') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Status'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'SequenceData') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['SequenceData'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'Date') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Date'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramCategoryName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramCategoryName'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'ScheduledStartTime') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ScheduledStartTime'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'Pump') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Pump'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramStartStopReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramStartStopReason'].length > howManyProgram){
                        myList.add(date['irrigation']['ProgramStartStopReason'][howManyProgram]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                  if(parameter.payloadKey == 'ProgramPauseResumeReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramPauseResumeReason'].length > howManyProgram){
                        myList.add(date['irrigation']['ProgramPauseResumeReason'][howManyProgram]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                }
                waterParameterLoop : for(var parameter in waterParameterList){
                  if(parameter.payloadKey == 'IrrigationMethod') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationMethod'][howManyProgram] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDuration_Quantity') {
                    graphData[indexOfDataToAdd]['data'].add(
                        getGraphData(
                            preValue: date['irrigation']['Pretime'][howManyProgram],
                            postValue: date['irrigation']['PostTime'][howManyProgram],
                            method: date['irrigation']['IrrigationMethod'][howManyProgram],
                            planned: date['irrigation']['IrrigationDuration_Quantity'][howManyProgram],
                            actualDuration: date['irrigation']['IrrigationDurationCompleted'][howManyProgram],
                            actualLiters: date['irrigation']['IrrigationQuantityCompleted'][howManyProgram],
                            flowRate: date['irrigation']['ValveFlowrate'][howManyProgram],
                            name: '${date['irrigation']['Date'][howManyProgram]}\n${date['irrigation']['ScheduledStartTime'][howManyProgram]}'
                        )
                    );
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationDuration_Quantity'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDurationCompleted/IrrigationQuantityCompleted') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation'][date['irrigation']['IrrigationMethod'][howManyProgram] == 1 ? parameter.payloadKey.split('/')[0] : parameter.payloadKey.split('/')[1]][howManyProgram]);
                    }
                  }
                }
                prePostParameterLoop : for(var parameter in prePostParameterList){
                  if(parameter.payloadKey == 'PrePostMethod') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation']['PrePostMethod'][howManyProgram] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'Pretime/PreQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyProgram] == 1 ? 'Pretime' : 'PreQty'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'PostTime/PostQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyProgram] == 1 ? 'PostTime' : 'PostQty'][howManyProgram]);
                    }
                  }
                }
                filterParameterLoop : for(var parameter in filterParameterList){
                  if(parameter.payloadKey == 'CentralFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['CentralFilterName'][howManyProgram];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                  if(parameter.payloadKey == 'LocalFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['LocalFilterName'][howManyProgram];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                }
                centralEcPhParameterLoop : for(var parameter in centralEcPhParameterList){
                  if(parameter.payloadKey == 'CentralEcSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralEcSetValue'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralPhSetValue'][howManyProgram]);
                    }
                  }
                }
                localEcPhParameterLoop : for(var parameter in localEcPhParameterList){
                  if(parameter.payloadKey == 'LocalEcSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalEcSetValue'][howManyProgram]);
                    }
                  }
                  if(parameter.payloadKey == 'LocalPhSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalPhSetValue'][howManyProgram]);
                    }
                  }
                }
                generalColumnData.add(myList);
                waterColumnData.add(waterList);
                prePostColumnData.add(prePostList);
                filterColumnData.add(filterList);
                centralEcPhColumnData.add(centralEcPhList);
                centralChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: centralChannel1ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: centralChannel2ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: centralChannel3ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: centralChannel4ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: centralChannel5ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: centralChannel6ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: centralChannel7ParameterList, date: date, howMany: howManyProgram, central: true));
                centralChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: centralChannel8ParameterList, date: date, howMany: howManyProgram, central: true));
                localEcPhColumnData.add(localEcPhList);
                localChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: localChannel1ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: localChannel2ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: localChannel3ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: localChannel4ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: localChannel5ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: localChannel6ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: localChannel7ParameterList, date: date, howMany: howManyProgram, central: false));
                localChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: localChannel8ParameterList, date: date, howMany: howManyProgram, central: false));
              }
            }
          }
        }
      }
    }
    return {
      'fixedColumn' : fixedColumn,
      'fixedColumnData': fixedColumnData,
      'generalColumn' : generalColumn,
      'generalColumnData' : generalColumnData,
      'waterColumn' : waterColumn,
      'waterColumnData' : waterColumnData,
      'prePostColumn' : prePostColumn,
      'prePostColumnData' : prePostColumnData,
      'filterColumn' : filterColumn,
      'filterColumnData' : filterColumnData,
      'centralEcPhColumn' : centralEcPhColumn,
      'centralEcPhColumnData' : centralEcPhColumnData,
      'centralChannel1Column' : centralChannel1Column,
      'centralChannel1ColumnData' : centralChannel1ColumnData,
      'centralChannel2Column' : centralChannel2Column,
      'centralChannel2ColumnData' : centralChannel2ColumnData,
      'centralChannel3Column' : centralChannel3Column,
      'centralChannel3ColumnData' : centralChannel3ColumnData,
      'centralChannel4Column' : centralChannel4Column,
      'centralChannel4ColumnData' : centralChannel4ColumnData,
      'centralChannel5Column' : centralChannel5Column,
      'centralChannel5ColumnData' : centralChannel5ColumnData,
      'centralChannel6Column' : centralChannel6Column,
      'centralChannel6ColumnData' : centralChannel6ColumnData,
      'centralChannel7Column' : centralChannel7Column,
      'centralChannel7ColumnData' : centralChannel7ColumnData,
      'centralChannel8Column' : centralChannel8Column,
      'centralChannel8ColumnData' : centralChannel8ColumnData,
      'localEcPhColumn' : localEcPhColumn,
      'localEcPhColumnData' : localEcPhColumnData,
      'localChannel1Column' : localChannel1Column,
      'localChannel1ColumnData' : localChannel1ColumnData,
      'localChannel2Column' : localChannel2Column,
      'localChannel2ColumnData' : localChannel2ColumnData,
      'localChannel3Column' : localChannel3Column,
      'localChannel3ColumnData' : localChannel3ColumnData,
      'localChannel4Column' : localChannel4Column,
      'localChannel4ColumnData' : localChannel4ColumnData,
      'localChannel5Column' : localChannel5Column,
      'localChannel5ColumnData' : localChannel5ColumnData,
      'localChannel6Column' : localChannel6Column,
      'localChannel6ColumnData' : localChannel6ColumnData,
      'localChannel7Column' : localChannel7Column,
      'localChannel7ColumnData' : localChannel7ColumnData,
      'localChannel8Column' : localChannel8Column,
      'localChannel8ColumnData' : localChannel8ColumnData,
      'graphData' : graphData
    };
  }

  Map<String,dynamic> editDateWise(dynamic dataSource,List<dynamic> noOfDate){
    var generalColumn = [...getColumn(generalParameterList)];
    var generalColumnData = [];
    var fixedColumnData = [];
    var waterColumn = [...getColumn(waterParameterList)];
    var waterColumnData = [];
    var prePostColumn = [...getColumn(prePostParameterList)];
    var prePostColumnData = [];
    var filterColumn = [...getColumn(filterParameterList)];
    var filterColumnData = [];
    var centralEcPhColumn = [...getColumn(centralEcPhParameterList)];
    var centralEcPhColumnData = [];
    var centralChannel1Column = [...getColumn(centralChannel1ParameterList)];
    var centralChannel1ColumnData = [];
    var centralChannel2Column = [...getColumn(centralChannel2ParameterList)];
    var centralChannel2ColumnData = [];
    var centralChannel3Column = [...getColumn(centralChannel3ParameterList)];
    var centralChannel3ColumnData = [];
    var centralChannel4Column = [...getColumn(centralChannel4ParameterList)];
    var centralChannel4ColumnData = [];
    var centralChannel5Column = [...getColumn(centralChannel5ParameterList)];
    var centralChannel5ColumnData = [];
    var centralChannel6Column = [...getColumn(centralChannel6ParameterList)];
    var centralChannel6ColumnData = [];
    var centralChannel7Column = [...getColumn(centralChannel7ParameterList)];
    var centralChannel7ColumnData = [];
    var centralChannel8Column = [...getColumn(centralChannel8ParameterList)];
    var centralChannel8ColumnData = [];
    var localEcPhColumn = [...getColumn(localEcPhParameterList)];
    var localEcPhColumnData = [];
    var localChannel1Column = [...getColumn(localChannel1ParameterList)];
    var localChannel1ColumnData = [];
    var localChannel2Column = [...getColumn(localChannel2ParameterList)];
    var localChannel2ColumnData = [];
    var localChannel3Column = [...getColumn(localChannel3ParameterList)];
    var localChannel3ColumnData = [];
    var localChannel4Column = [...getColumn(localChannel4ParameterList)];
    var localChannel4ColumnData = [];
    var localChannel5Column = [...getColumn(localChannel5ParameterList)];
    var localChannel5ColumnData = [];
    var localChannel6Column = [...getColumn(localChannel6ParameterList)];
    var localChannel6ColumnData = [];
    var localChannel7Column = [...getColumn(localChannel7ParameterList)];
    var localChannel7ColumnData = [];
    var localChannel8Column = [...getColumn(localChannel8ParameterList)];
    var localChannel8ColumnData = [];
    var graphData = [];
    var fixedColumn = 'Date';
    generalColumn.remove('Date');
    generalColumn.remove('Valve');

    for(var findDate in noOfDate){
      if(findDate['show'] == true){
        graphData.add({
          'name' : findDate['name'],
          'data' : []
        });
        var indexOfDataToAdd = graphData.length - 1;
        for(var date in dataSource){
          if(date['irrigation'].isNotEmpty){
            for(var howManyDate = 0;howManyDate < date['irrigation']['Date'].length;howManyDate++){
              if(date['irrigation']['Date'][howManyDate].contains(findDate['name'])){
                fixedColumnData.add(findDate['name']);
                var myList = [];
                var waterList = [];
                var filterList = [];
                var prePostList = [];
                var centralEcPhList = [];
                var localEcPhList = [];
                generalParameterLoop : for(var parameter in generalParameterList){
                  if(parameter.payloadKey == 'ProgramName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramName'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'Status') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Status'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'SequenceData') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['SequenceData'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramCategoryName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramCategoryName'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'ScheduledStartTime') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ScheduledStartTime'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'Pump') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Pump'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramStartStopReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramStartStopReason'].length > howManyDate){
                        myList.add(date['irrigation']['ProgramStartStopReason'][howManyDate]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                  if(parameter.payloadKey == 'ProgramPauseResumeReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramPauseResumeReason'].length > howManyDate){
                        myList.add(date['irrigation']['ProgramPauseResumeReason'][howManyDate]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                }
                waterParameterLoop : for(var parameter in waterParameterList){
                  if(parameter.payloadKey == 'IrrigationMethod') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationMethod'][howManyDate] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  print('IrrigationMethod---');
                  if(parameter.payloadKey == 'IrrigationDuration_Quantity') {
                    graphData[indexOfDataToAdd]['data'].add(
                        getGraphData(
                            preValue: date['irrigation']['Pretime'][howManyDate],
                            postValue: date['irrigation']['PostTime'][howManyDate],
                            method: date['irrigation']['IrrigationMethod'][howManyDate],
                            planned: date['irrigation']['IrrigationDuration_Quantity'][howManyDate],
                            actualDuration: date['irrigation']['IrrigationDurationCompleted'][howManyDate],
                            actualLiters: date['irrigation']['IrrigationQuantityCompleted'][howManyDate],
                            flowRate: date['irrigation']['ValveFlowrate'][howManyDate],
                            name: '${date['irrigation']['Date'][howManyDate]}\n${date['irrigation']['ScheduledStartTime'][howManyDate]}'
                        )
                    );
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationDuration_Quantity'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDurationCompleted/IrrigationQuantityCompleted') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation'][date['irrigation']['IrrigationMethod'][howManyDate] == 1 ? parameter.payloadKey.split('/')[0] : parameter.payloadKey.split('/')[1]][howManyDate]);
                    }
                  }
                }
                prePostParameterLoop : for(var parameter in prePostParameterList){
                  if(parameter.payloadKey == 'PrePostMethod') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation']['PrePostMethod'][howManyDate] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'Pretime/PreQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyDate] == 1 ? 'Pretime' : 'PreQty'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'PostTime/PostQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyDate] == 1 ? 'PostTime' : 'PostQty'][howManyDate]);
                    }
                  }
                }
                filterParameterLoop : for(var parameter in filterParameterList){
                  if(parameter.payloadKey == 'CentralFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['CentralFilterName'][howManyDate];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                  if(parameter.payloadKey == 'LocalFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['LocalFilterName'][howManyDate];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                }
                centralEcPhParameterLoop : for(var parameter in centralEcPhParameterList){
                  if(parameter.payloadKey == 'CentralEcSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralEcSetValue'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralPhSetValue'][howManyDate]);
                    }
                  }
                }
                localEcPhParameterLoop : for(var parameter in localEcPhParameterList){
                  if(parameter.payloadKey == 'LocalEcSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalEcSetValue'][howManyDate]);
                    }
                  }
                  if(parameter.payloadKey == 'LocalPhSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalPhSetValue'][howManyDate]);
                    }
                  }
                }
                generalColumnData.add(myList);
                waterColumnData.add(waterList);
                filterColumnData.add(filterList);
                prePostColumnData.add(prePostList);
                centralEcPhColumnData.add(centralEcPhList);
                centralChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: centralChannel1ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: centralChannel2ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: centralChannel3ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: centralChannel4ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: centralChannel5ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: centralChannel6ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: centralChannel7ParameterList, date: date, howMany: howManyDate, central: true));
                centralChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: centralChannel8ParameterList, date: date, howMany: howManyDate, central: true));
                localEcPhColumnData.add(localEcPhList);
                localChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: localChannel1ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: localChannel2ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: localChannel3ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: localChannel4ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: localChannel5ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: localChannel6ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: localChannel7ParameterList, date: date, howMany: howManyDate, central: false));
                localChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: localChannel8ParameterList, date: date, howMany: howManyDate, central: false));

              }
            }
          }
        }
      }
    }
    var sendingData = {
      'fixedColumn' : fixedColumn,
      'fixedColumnData': fixedColumnData,
      'generalColumn' : generalColumn,
      'generalColumnData' : generalColumnData,
      'waterColumn' : waterColumn,
      'waterColumnData' : waterColumnData,
      'filterColumn' : filterColumn,
      'filterColumnData' : filterColumnData,
      'prePostColumn' : prePostColumn,
      'prePostColumnData' : prePostColumnData,
      'centralEcPhColumn' : centralEcPhColumn,
      'centralEcPhColumnData' : centralEcPhColumnData,
      'centralChannel1Column' : centralChannel1Column,
      'centralChannel1ColumnData' : centralChannel1ColumnData,
      'centralChannel2Column' : centralChannel2Column,
      'centralChannel2ColumnData' : centralChannel2ColumnData,
      'centralChannel3Column' : centralChannel3Column,
      'centralChannel3ColumnData' : centralChannel3ColumnData,
      'centralChannel4Column' : centralChannel4Column,
      'centralChannel4ColumnData' : centralChannel4ColumnData,
      'centralChannel5Column' : centralChannel5Column,
      'centralChannel5ColumnData' : centralChannel5ColumnData,
      'centralChannel6Column' : centralChannel6Column,
      'centralChannel6ColumnData' : centralChannel6ColumnData,
      'centralChannel7Column' : centralChannel7Column,
      'centralChannel7ColumnData' : centralChannel7ColumnData,
      'centralChannel8Column' : centralChannel8Column,
      'centralChannel8ColumnData' : centralChannel8ColumnData,
      'localEcPhColumn' : localEcPhColumn,
      'localEcPhColumnData' : localEcPhColumnData,
      'localChannel1Column' : localChannel1Column,
      'localChannel1ColumnData' : localChannel1ColumnData,
      'localChannel2Column' : localChannel2Column,
      'localChannel2ColumnData' : localChannel2ColumnData,
      'localChannel3Column' : localChannel3Column,
      'localChannel3ColumnData' : localChannel3ColumnData,
      'localChannel4Column' : localChannel4Column,
      'localChannel4ColumnData' : localChannel4ColumnData,
      'localChannel5Column' : localChannel5Column,
      'localChannel5ColumnData' : localChannel5ColumnData,
      'localChannel6Column' : localChannel6Column,
      'localChannel6ColumnData' : localChannel6ColumnData,
      'localChannel7Column' : localChannel7Column,
      'localChannel7ColumnData' : localChannel7ColumnData,
      'localChannel8Column' : localChannel8Column,
      'localChannel8ColumnData' : localChannel8ColumnData,
      'graphData' : graphData
    };
    return sendingData;
  }

  Map<String,dynamic> editStatusWise(dynamic dataSource,List<dynamic> noOfStatus){
    var generalColumn = [...getColumn(generalParameterList)];
    var generalColumnData = [];
    var fixedColumnData = [];
    var waterColumn = [...getColumn(waterParameterList)];
    var waterColumnData = [];
    var filterColumn = [...getColumn(filterParameterList)];
    var filterColumnData = [];
    var prePostColumn = [...getColumn(prePostParameterList)];
    var prePostColumnData = [];
    var centralEcPhColumn = [...getColumn(centralEcPhParameterList)];
    var centralEcPhColumnData = [];
    var centralChannel1Column = [...getColumn(centralChannel1ParameterList)];
    var centralChannel1ColumnData = [];
    var centralChannel2Column = [...getColumn(centralChannel2ParameterList)];
    var centralChannel2ColumnData = [];
    var centralChannel3Column = [...getColumn(centralChannel3ParameterList)];
    var centralChannel3ColumnData = [];
    var centralChannel4Column = [...getColumn(centralChannel4ParameterList)];
    var centralChannel4ColumnData = [];
    var centralChannel5Column = [...getColumn(centralChannel5ParameterList)];
    var centralChannel5ColumnData = [];
    var centralChannel6Column = [...getColumn(centralChannel6ParameterList)];
    var centralChannel6ColumnData = [];
    var centralChannel7Column = [...getColumn(centralChannel7ParameterList)];
    var centralChannel7ColumnData = [];
    var centralChannel8Column = [...getColumn(centralChannel8ParameterList)];
    var centralChannel8ColumnData = [];
    var localEcPhColumn = [...getColumn(localEcPhParameterList)];
    var localEcPhColumnData = [];
    var localChannel1Column = [...getColumn(localChannel1ParameterList)];
    var localChannel1ColumnData = [];
    var localChannel2Column = [...getColumn(localChannel2ParameterList)];
    var localChannel2ColumnData = [];
    var localChannel3Column = [...getColumn(localChannel3ParameterList)];
    var localChannel3ColumnData = [];
    var localChannel4Column = [...getColumn(localChannel4ParameterList)];
    var localChannel4ColumnData = [];
    var localChannel5Column = [...getColumn(localChannel5ParameterList)];
    var localChannel5ColumnData = [];
    var localChannel6Column = [...getColumn(localChannel6ParameterList)];
    var localChannel6ColumnData = [];
    var localChannel7Column = [...getColumn(localChannel7ParameterList)];
    var localChannel7ColumnData = [];
    var localChannel8Column = [...getColumn(localChannel8ParameterList)];
    var localChannel8ColumnData = [];
    var graphData = [];
    var fixedColumn = 'Status';
    generalColumn.remove('Status');
    generalColumn.remove('Valve');

    for(var findStatus in noOfStatus){
      if(findStatus['show'] == true){
        graphData.add({
          'name' : getStatus(findStatus['name'].toString())['status'],
          'data' : []
        });
        var indexOfDataToAdd = graphData.length - 1;
        for(var date in dataSource){
          if(date['irrigation'].isNotEmpty){
            for(var howManyStatus = 0;howManyStatus < date['irrigation']['Status'].length;howManyStatus++){
              if(date['irrigation']['Status'][howManyStatus] == findStatus['name']){
                fixedColumnData.add(getStatus(findStatus['name'])['status']);
                var myList = [];
                var waterList = [];
                var prePostList = [];
                var centralEcPhList = [];
                var localEcPhList = [];
                var filterList = [];
                generalParameterLoop : for(var parameter in generalParameterList){
                  if(parameter.payloadKey == 'ProgramName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramName'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'SequenceData') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['SequenceData'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'Date') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Date'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramCategoryName') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ProgramCategoryName'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'ScheduledStartTime') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['ScheduledStartTime'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'Pump') {
                    if(parameter.show == true){
                      myList.add(date['irrigation']['Pump'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'ProgramStartStopReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramStartStopReason'].length > howManyStatus){
                        myList.add(date['irrigation']['ProgramStartStopReason'][howManyStatus]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                  if(parameter.payloadKey == 'ProgramPauseResumeReason') {
                    if(parameter.show == true){
                      if(date['irrigation']['ProgramPauseResumeReason'].length > howManyStatus){
                        myList.add(date['irrigation']['ProgramPauseResumeReason'][howManyStatus]);
                      }else{
                        myList.add('-');
                      }
                    }
                  }
                }
                waterParameterLoop : for(var parameter in waterParameterList){
                  if(parameter.payloadKey == 'IrrigationMethod') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationMethod'][howManyStatus] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDuration_Quantity') {
                    graphData[indexOfDataToAdd]['data'].add(
                        getGraphData(
                            preValue: date['irrigation']['Pretime'][howManyStatus],
                            postValue: date['irrigation']['PostTime'][howManyStatus],
                            method: date['irrigation']['IrrigationMethod'][howManyStatus],
                            planned: date['irrigation']['IrrigationDuration_Quantity'][howManyStatus],
                            actualDuration: date['irrigation']['IrrigationDurationCompleted'][howManyStatus],
                            actualLiters: date['irrigation']['IrrigationQuantityCompleted'][howManyStatus],
                            flowRate: date['irrigation']['ValveFlowrate'][howManyStatus],
                            name: '${date['irrigation']['Date'][howManyStatus]}\n${date['irrigation']['ScheduledStartTime'][howManyStatus]}'
                        )
                    );
                    if(parameter.show == true){
                      waterList.add(date['irrigation']['IrrigationDuration_Quantity'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'IrrigationDurationCompleted/IrrigationQuantityCompleted') {
                    if(parameter.show == true){
                      waterList.add(date['irrigation'][date['irrigation']['IrrigationMethod'][howManyStatus] == 1 ? parameter.payloadKey.split('/')[0] : parameter.payloadKey.split('/')[1]][howManyStatus]);
                    }
                  }
                }
                prePostParameterLoop : for(var parameter in prePostParameterList){
                  if(parameter.payloadKey == 'PrePostMethod') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation']['PrePostMethod'][howManyStatus] == 1 ? 'Time' : 'Quantity');
                    }
                  }
                  if(parameter.payloadKey == 'Pretime/PreQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyStatus] == 1 ? 'Pretime' : 'PreQty'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'PostTime/PostQty') {
                    if(parameter.show == true){
                      prePostList.add(date['irrigation'][date['irrigation']['PrePostMethod'][howManyStatus] == 1 ? 'PostTime' : 'PostQty'][howManyStatus]);
                    }
                  }
                }
                filterParameterLoop : for(var parameter in filterParameterList){
                  if(parameter.payloadKey == 'CentralFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['CentralFilterName'][howManyStatus];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                  if(parameter.payloadKey == 'LocalFilterName') {
                    if(parameter.show == true){
                      var data = date['irrigation']['LocalFilterName'][howManyStatus];
                      data = data.split('_').join('\n');
                      filterList.add(data);
                    }
                  }
                }
                centralEcPhParameterLoop : for(var parameter in centralEcPhParameterList){
                  if(parameter.payloadKey == 'CentralEcSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralEcSetValue'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'CentralPhSetValue') {
                    if(parameter.show == true){
                      centralEcPhList.add(date['irrigation']['CentralPhSetValue'][howManyStatus]);
                    }
                  }
                }
                localEcPhParameterLoop : for(var parameter in localEcPhParameterList){
                  if(parameter.payloadKey == 'LocalEcSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalEcSetValue'][howManyStatus]);
                    }
                  }
                  if(parameter.payloadKey == 'LocalPhSetValue') {
                    if(parameter.show == true){
                      localEcPhList.add(date['irrigation']['LocalPhSetValue'][howManyStatus]);
                    }
                  }
                }
                generalColumnData.add(myList);
                waterColumnData.add(waterList);
                prePostColumnData.add(prePostList);
                filterColumnData.add(filterList);
                centralEcPhColumnData.add(centralEcPhList);
                centralChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: centralChannel1ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: centralChannel2ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: centralChannel3ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: centralChannel4ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: centralChannel5ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: centralChannel6ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: centralChannel7ParameterList, date: date, howMany: howManyStatus, central: true));
                centralChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: centralChannel8ParameterList, date: date, howMany: howManyStatus, central: true));
                localEcPhColumnData.add(localEcPhList);
                localChannel1ColumnData.add(getChannelData(channelNo: 0, channelParameterList: localChannel1ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel2ColumnData.add(getChannelData(channelNo: 1, channelParameterList: localChannel2ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel3ColumnData.add(getChannelData(channelNo: 2, channelParameterList: localChannel3ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel4ColumnData.add(getChannelData(channelNo: 3, channelParameterList: localChannel4ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel5ColumnData.add(getChannelData(channelNo: 4, channelParameterList: localChannel5ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel6ColumnData.add(getChannelData(channelNo: 5, channelParameterList: localChannel6ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel7ColumnData.add(getChannelData(channelNo: 6, channelParameterList: localChannel7ParameterList, date: date, howMany: howManyStatus, central: false));
                localChannel8ColumnData.add(getChannelData(channelNo: 7, channelParameterList: localChannel8ParameterList, date: date, howMany: howManyStatus, central: false));
              }

            }
          }

        }
      }
    }
    var sendingData = {
      'fixedColumn' : fixedColumn,
      'fixedColumnData': fixedColumnData,
      'generalColumn' : generalColumn,
      'generalColumnData' : generalColumnData,
      'waterColumn' : waterColumn,
      'waterColumnData' : waterColumnData,
      'prePostColumn' : prePostColumn,
      'prePostColumnData' : prePostColumnData,
      'filterColumn' : filterColumn,
      'filterColumnData' : filterColumnData,
      'centralEcPhColumn' : centralEcPhColumn,
      'centralEcPhColumnData' : centralEcPhColumnData,
      'centralChannel1Column' : centralChannel1Column,
      'centralChannel1ColumnData' : centralChannel1ColumnData,
      'centralChannel2Column' : centralChannel2Column,
      'centralChannel2ColumnData' : centralChannel2ColumnData,
      'centralChannel3Column' : centralChannel3Column,
      'centralChannel3ColumnData' : centralChannel3ColumnData,
      'centralChannel4Column' : centralChannel4Column,
      'centralChannel4ColumnData' : centralChannel4ColumnData,
      'centralChannel5Column' : centralChannel5Column,
      'centralChannel5ColumnData' : centralChannel5ColumnData,
      'centralChannel6Column' : centralChannel6Column,
      'centralChannel6ColumnData' : centralChannel6ColumnData,
      'centralChannel7Column' : centralChannel7Column,
      'centralChannel7ColumnData' : centralChannel7ColumnData,
      'centralChannel8Column' : centralChannel8Column,
      'centralChannel8ColumnData' : centralChannel8ColumnData,
      'localEcPhColumn' : localEcPhColumn,
      'localEcPhColumnData' : localEcPhColumnData,
      'localChannel1Column' : localChannel1Column,
      'localChannel1ColumnData' : localChannel1ColumnData,
      'localChannel2Column' : localChannel2Column,
      'localChannel2ColumnData' : localChannel2ColumnData,
      'localChannel3Column' : localChannel3Column,
      'localChannel3ColumnData' : localChannel3ColumnData,
      'localChannel4Column' : localChannel4Column,
      'localChannel4ColumnData' : localChannel4ColumnData,
      'localChannel5Column' : localChannel5Column,
      'localChannel5ColumnData' : localChannel5ColumnData,
      'localChannel6Column' : localChannel6Column,
      'localChannel6ColumnData' : localChannel6ColumnData,
      'localChannel7Column' : localChannel7Column,
      'localChannel7ColumnData' : localChannel7ColumnData,
      'localChannel8Column' : localChannel8Column,
      'localChannel8ColumnData' : localChannel8ColumnData,
      'graphData' : graphData
    };
    return sendingData;
  }

  List<dynamic> getChannelData({required channelNo,required List<GeneralParameterModel> channelParameterList,required dynamic date,required int howMany,required bool central}){
    List<dynamic> list = [];
    try{

      for(var parameter in channelParameterList){
        if(parameter.payloadKey == '${central ? 'Central' : 'Local'}FertChannelName') {
          if(parameter.show == true){
            var data = date['irrigation']['${central ? 'Central' : 'Local'}FertChannelName'][howMany];
            if(data == null || data == ''){
              list.add(null);
            }else{
              if(data.contains('_')){
                var splitData = data.split('_');
                print("splitData : $splitData  channelNo : $channelNo");
                if(splitData.length <= channelNo){
                  list.add(null);
                }else{
                  print("${splitData.length} ==== $channelNo");
                  list.add(splitData[channelNo]);
                }
                print('liiii : $list  ');
              }else{
                list.add(null);
              }
            }
          }
        }
        if(parameter.payloadKey == '${central ? 'Central' : 'Local'}FertMethod') {
          if(parameter.show == true){
            var data = date['irrigation']['${central ? 'Central' : 'Local'}FertMethod'][howMany];
            list.add([null,''].contains(data) ? data : (data.split('_')[channelNo] == '1' ? 'Time' : data.split('_')[channelNo] == '0' ? null :'Quantity'));
          }
        }
        if(parameter.payloadKey == '${central ? 'Central' : 'Local'}FertilizerChannelDuration/${central ? 'Central' : 'Local'}FertilizerChannelQuantity') {
          if(parameter.show == true){
            list.add([null,''].contains(list[0]) ? '-' : list[0] == 'Time' ? date['irrigation']['${central ? 'Central' : 'Local'}FertilizerChannelDuration'][howMany].split('_')[channelNo] : date['irrigation']['${central ? 'Central' : 'Local'}FertilizerChannelQuantity'][howMany].split('_')[channelNo]);
          }
        }
        if(parameter.payloadKey == '${central ? 'Central' : 'Local'}FertilizerChannelDurationCompleted/${central ? 'Central' : 'Local'}FertilizerChannelQuantityCompleted') {
          if(parameter.show == true){
            list.add([null,''].contains(list[0]) ? '-' : list[0] == 'Time' ? date['irrigation']['${central ? 'Central' : 'Local'}FertilizerChannelDurationCompleted'][howMany].split('_')[channelNo] : date['irrigation']['${central ? 'Central' : 'Local'}FertilizerChannelDurationCompleted'][howMany].split('_')[channelNo]);
          }
        }

      }
    }catch(e,stackTrace){
      print('getChannelData error => ${e.toString()}');
      print('getChannelData stackTrac => ${stackTrace}');
    }
    print('listto : $list');
    return list;
  }

  List<dynamic> getColumn(List<GeneralParameterModel> parameterList){
    var list = [];
    for(var parameter in parameterList){
      if(parameter.show == true){
        if(parameter.payloadKey != 'overAll'){
          list.add(parameter.uiKey);
        }
      }
    }
    return list;
  }


}

class GraphData{
  final dynamic preFrom;
  final dynamic preTo;
  final dynamic postFrom;
  final dynamic postTo;
  final dynamic plannedFrom;
  final dynamic plannedTo;
  final dynamic actualFrom;
  final dynamic actualTo;
  final String seqName;
  GraphData({required this.actualFrom,required this.actualTo,required this.plannedFrom,required this.plannedTo,required this.seqName,required this.preFrom,required this.preTo,required this.postFrom,required this.postTo,});
}


GraphData getGraphData({required method,required planned,required actualDuration,required actualLiters,required flowRate,required String name,preValue,postValue}){
  print({
    'method' : method,
    'planned' : planned,
    'actualDuration' : actualDuration,
    'flowRate' : flowRate,
    'name' : name,
    'preValue' : preValue,
    'postValue' : postValue,
  });
  var preValueInSec = DataConvert().parseTimeString(preValue ?? '00:00:00');
  var postValueInSec = DataConvert().parseTimeString(postValue ?? '00:00:00');
  var plannedSeconds = method == 1 ? DataConvert().parseTimeString(planned) : 0;
  var actualSeconds = method == 1 ? DataConvert().parseTimeString(actualDuration) : 0;
  var flowRateForPerSec = flowRate/3600;
  var preInLiters = preValueInSec * flowRateForPerSec;
  var postInLiters = postValueInSec * flowRateForPerSec;
  var plannedInLiters = method == 1 ? (plannedSeconds * flowRateForPerSec) : planned;
  var actualInLiters =  method == 1 ? (actualSeconds * flowRateForPerSec) : actualLiters;
  if(plannedInLiters is String){
    plannedInLiters = int.parse(plannedInLiters);
  }
  if(actualInLiters is String){
    actualInLiters = int.parse(actualInLiters);
  }
  dynamic preFrom = 0;
  dynamic preTo = 0;
  dynamic actualFrom = 0;
  dynamic actualTo = 0;
  dynamic postFrom = 0;
  dynamic postTo = 0;
  dynamic plannedFrom = 0;
  dynamic plannedTo = 0;
  if(actualInLiters > preInLiters){
    print('$name : first if');
    preTo = preInLiters;
    actualFrom = preTo;
    print('preTo = ${preTo.runtimeType} | actualFrom = ${actualFrom.runtimeType} | preInLiters = ${preInLiters.runtimeType} | plannedInLiters = ${plannedInLiters.runtimeType} | postInLiters = ${postInLiters.runtimeType} | actualInLiters = ${actualInLiters.runtimeType} |  ');
    if((plannedInLiters - postInLiters) > actualInLiters){
      print('$name : second if');
      actualTo = actualInLiters;
      postFrom = actualTo;
      postTo = postFrom;
      plannedFrom = postTo;
      plannedTo = plannedInLiters;
    }else{
      print('$name : second else');
      actualTo = plannedInLiters - postInLiters;
      postFrom = actualTo;
      postTo = plannedInLiters - (plannedInLiters - actualInLiters);
      plannedFrom = postTo;
      plannedTo = plannedInLiters;
    }
  }else{
    print('$name : first else');
    preTo = actualInLiters;
    actualFrom = preTo;
    actualTo = actualFrom;
    postFrom = actualTo;
    postTo = postFrom;
    plannedFrom = postTo;
    plannedTo = plannedInLiters;
  }
  print({
    'preFrom': preFrom,
    'preTo': preTo,
    'actualFrom': actualFrom,
    'actualTo': actualTo,
    'postFrom': postFrom,
    'postTo': postTo,
    'plannedFrom': plannedFrom,
    'plannedTo': plannedTo,
    'seqName': name
  });
  return GraphData(
      preFrom: preFrom,
      preTo: preTo,
      actualFrom: actualFrom,
      actualTo: actualTo,
      postFrom: postFrom,
      postTo: postTo,
      plannedFrom: plannedFrom,
      plannedTo: plannedTo,
      seqName: name
  );
}

dynamic getStatus(code){
  String statusString = '';
  Color innerCircleColor = Colors.grey;
  switch (code.toString()) {
    case "0":
      innerCircleColor = Colors.grey;
      statusString = "Pending";
      break;
    case "1":
      innerCircleColor = Colors.orange;
      statusString = "Running";
      break;
    case "2":
      innerCircleColor = Colors.green;
      statusString = "Completed";
      break;
    case "3":
      innerCircleColor = Colors.yellow;
      statusString = "Skipped by user";
      break;
    case "4":
      innerCircleColor = Colors.orangeAccent;
      statusString = "Day schedule pending";
      break;
    case "5":
      innerCircleColor = const Color(0xFF0D5D9A);
      statusString = "Day schedule running";
      break;
    case "6":
      innerCircleColor = Colors.yellowAccent;
      statusString = "Day schedule completed";
      break;
    case "7":
      innerCircleColor = Colors.red;
      statusString = "Day schedule skipped";
      break;
    case "8":
      innerCircleColor = Colors.redAccent;
      statusString = "Postponed partially to tomorrow";
      break;
    case "9":
      innerCircleColor = Colors.green;
      statusString = "Postponed fully to tomorrow";
      break;
    case "10":
      innerCircleColor = Colors.amberAccent;
      statusString = "RTC off time reached";
      break;
    case "11":
      innerCircleColor = Colors.blueGrey;
      statusString = "RTC max time reached";
      break;
    case "12":
      innerCircleColor = Colors.redAccent;
      statusString = "High Flow";
      break;
    case "13":
      innerCircleColor = Colors.orangeAccent;
      statusString = "Low Flow";
      break;
    case "14":
      innerCircleColor = Colors.purple;
      statusString = "No Flow";
      break;
    case "15":
      innerCircleColor = Colors.blue;
      statusString = "Skipped by Global Limit";
      break;
    case "16":
      innerCircleColor = Colors.black;
      statusString = "Stopped Manually";
      break;
    default:
      innerCircleColor = Colors.amber;
      statusString = "RTC max time reached";
      break;
  }
  return {'status' : statusString,'color':innerCircleColor};
}

