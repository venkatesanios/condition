import 'package:flutter/cupertino.dart';

class GlobalFertLimitProvider extends ChangeNotifier{
  int central = 0;
  int local = 0;
  int wantToSendData = 0;


  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }

  void editGlobalFert(dynamic data){
    print(data);
    globalFert = data;
    for(var i in data){
      for(var vl in i['valve']){
        if(vl['central1'].isNotEmpty){
          if(central < 1){
            central = 1;
          }
        }
        if(vl['central2'].isNotEmpty){
          print('yes it worked');
          if(central < 2){
            central = 2;
          }
        }
        if(vl['central3'].isNotEmpty){
          if(central < 3){
            central = 3;
          }
        }
        if(vl['central4'].isNotEmpty){
          if(central < 4){
            central = 4;
          }
        }
        if(vl['central5'].isNotEmpty){
          if(central < 5){
            central = 5;
          }
        }
        if(vl['central6'].isNotEmpty){
          if(central < 6){
            central = 6;
          }
        }
        if(vl['central7'].isNotEmpty){
          if(central < 7){
            central = 7;
          }
        }
        if(vl['central8'].isNotEmpty){
          if(central < 8){
            central = 8;
          }
        }
        if(vl['local1'].isNotEmpty){
          if(local < 1){
            local = 1;
          }
        }
        if(vl['local2'].isNotEmpty){
          if(local < 2){
            local = 2;
          }
        }
        if(vl['local3'].isNotEmpty){
          if(local < 3){
            local = 3;
          }
        }
        if(vl['local4'].isNotEmpty){
          if(local < 4){
            local = 4;
          }
        }
        if(vl['local5'].isNotEmpty){
          if(local < 5){
            local = 5;
          }
        }
        if(vl['local6'].isNotEmpty){
          if(local < 6){
            local = 6;
          }
        }
        if(vl['local7'].isNotEmpty){
          if(local < 7){
            local = 7;
          }
        }
        if(vl['local8'].isNotEmpty){
          if(local < 8){
            local = 8;
          }
        }
      }

    }
    notifyListeners();
  }

  List<dynamic> globalFert = [];

  dynamic hwPayload(){

    var payload = '';
    for(var i in globalFert){
      for(var val in i['valve']){
        payload += '${payload.isNotEmpty ? ';' : ''}'
            '${val['sNo']},'
            '${i['id']},'
            '${val['id']},'
            '${val['time']},'
            '${val['quantity']},'
            '${val['central1']['value'] ?? '0'}_'
            '${val['central2']['value'] ?? '0'}_'
            '${val['central3']['value'] ?? '0'}_'
            '${val['central4']['value'] ?? '0'}_'
            '${val['central5']['value'] ?? '0'}_'
            '${val['central6']['value'] ?? '0'}_'
            '${val['central7']['value'] ?? '0'}_'
            '${val['central8']['value'] ?? '0'},'
            '${val['local1']['value'] ?? '0'}_'
            '${val['local2']['value'] ?? '0'}_'
            '${val['local3']['value'] ?? '0'}_'
            '${val['local4']['value'] ?? '0'}_'
            '${val['local5']['value'] ?? '0'}_'
            '${val['local6']['value'] ?? '0'}_'
            '${val['local7']['value'] ?? '0'}_'
            '${val['local8']['value'] ?? '0'}';
      }
    }
    print(payload);

    return {'1100' : [{'1101' : payload}]};
  }

  void editGfert(String title,int lineIndex,int valveIndex,String key,String value){
    // print('title : $title');
    // print('lineIndex : $lineIndex');
    // print('valveIndex : $valveIndex');
    // print('key : $key');
    // print('value : $value');
    switch (title){
      case('central_local'):{
        globalFert[lineIndex]['valve'][valveIndex][key]['value'] = value;
        break;
      }
      case('quantity'):{
        globalFert[lineIndex]['valve'][valveIndex][key] = value;
        break;
      }
      case('time'):{
        globalFert[lineIndex]['valve'][valveIndex][key] = value;
        break;
      }
      case('date'):{
        globalFert[lineIndex]['valve'][valveIndex][key] = value;
        print(globalFert[lineIndex]['valve']);
        break;
      }
    }
    notifyListeners();
  }
}