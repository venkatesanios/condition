import 'dart:convert';

import 'package:flutter/cupertino.dart';

class FertilizerSetProvider extends ChangeNotifier{
  dynamic listOfRecipe = [];
  dynamic listOfSite = [];
  int selectFunction = 0;
  bool textField = false;
  TextEditingController textFieldController = TextEditingController();
  dynamic sample = [];
  int selectedSite = 0;
  int wantToSendData = 0;
  int autoIncrement = 0;
  dynamic duplicate = {};
  bool isShow = false;

  void editIsShow(int selectedRecipe,bool value){
    listOfRecipe[selectedSite]['recipe'].removeAt(selectedRecipe);
    // if(listOfRecipe[selectedSite]['recipe'][selectedRecipe]['show'] != true){
    //   listOfRecipe[selectedSite]['recipe'][selectedRecipe]['show'] = value;
    // }
    // if( listOfRecipe[selectedSite]['recipe'][selectedRecipe]['show'] == false){
    //   listOfRecipe[selectedSite]['recipe'].removeAt(selectedRecipe);
    // }
    notifyListeners();
  }

  void copyRecipe({required int index,required dynamic recipeData}){
    listOfRecipe[selectedSite]['recipe'][index] = recipeData;
    notifyListeners();
  }

  void closeIsShow(){
    isShow = false;
    notifyListeners();
  }

  int editAutoIncrement(){
    autoIncrement += 1;
    notifyListeners();
    return autoIncrement;
  }

  void editAutoDecrement(){
    autoIncrement -= 1;
    notifyListeners();
  }

  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }

  void editTextField(){
    textField = !textField;
    notifyListeners();
  }

  void editTextFieldController(String value,int index){
    listOfRecipe[selectedSite]['recipe'][index]['name'] = value;
    notifyListeners();
  }

  void getDuplicate(int index){
    duplicate = {};
    duplicate = {
      'sNo' : listOfRecipe[selectedSite]['recipe'][index]['sNo'],
      'id' : listOfRecipe[selectedSite]['recipe'][index]['id'],
      'name' : listOfRecipe[selectedSite]['recipe'][index]['name'],
      'location' : listOfRecipe[selectedSite]['recipe'][index]['location'],
      'select' : listOfRecipe[selectedSite]['recipe'][index]['select'],
      if(listOfRecipe[selectedSite]['ec'].isNotEmpty)
        'ecActive' : listOfRecipe[selectedSite]['recipe'][index]['ecActive'],
      if(listOfRecipe[selectedSite]['ec'].isNotEmpty)
        'Ec' : listOfRecipe[selectedSite]['recipe'][index]['Ec'],
      if(listOfRecipe[selectedSite]['ph'].isNotEmpty)
        'phActive' : listOfRecipe[selectedSite]['recipe'][index]['phActive'],
      if(listOfRecipe[selectedSite]['ph'].isNotEmpty)
        'Ph' : listOfRecipe[selectedSite]['recipe'][index]['Ph'],
    };
    var getFertilizer = [];
    for(var i in listOfRecipe[selectedSite]['recipe'][index]['fertilizer']){
      getFertilizer.add(i);
    }
    duplicate['fertilizer'] = getFertilizer;
    notifyListeners();
  }

  void addDuplicateRecipe(int index){
    listOfRecipe[selectedSite]['recipe'][index] = duplicate;
    notifyListeners();
  }

  void addRecipe(String name){
    listOfRecipe[selectedSite]['recipe'].add({
      'sNo' : editAutoIncrement(),
      'id' : 'CFESE${listOfRecipe[selectedSite]['recipe'].length + 1}',
      // 'name' : 'Fertilizer ${listOfRecipe[selectedSite]['recipe'].length + 1}',
      'name' : name,
      'location' : listOfRecipe[selectedSite]['id'],
      'show' : false,
      'select' : false,
      if(listOfRecipe[selectedSite]['ec'].isNotEmpty)
        'ecActive' : false,
      if(listOfRecipe[selectedSite]['ec'].isNotEmpty)
        'Ec' : '0',
      if(listOfRecipe[selectedSite]['ph'].isNotEmpty)
        'phActive' : false,
      if(listOfRecipe[selectedSite]['ph'].isNotEmpty)
        'Ph' : '0',
      'fertilizer' : editSample(listOfRecipe[selectedSite])
    });
    notifyListeners();
  }

  void editSite(int value){
    selectedSite = value;
    notifyListeners();
    print(selectedSite);
  }

  void editSelectFunction(int data){
    if(data == 0){
      for(var i in listOfRecipe[selectedSite]['recipe']){
        i['select'] = false;
      }
    }
    selectFunction = data;
    notifyListeners();
  }

  void editRecipe(dynamic data){
    listOfRecipe = [];
    listOfSite = [];
    selectFunction = 0;
    textField = false;
    sample = [];
    selectedSite = 0;
    wantToSendData = 0;
    autoIncrement = data['data']['fertilizerSet']['autoIncrement'] == null ? 0 : data['data']['fertilizerSet']['autoIncrement'];
    if(data['data']['fertilizerSet']['fertilizerSet'] == null){
      for(var i in data['data']['default']['fertilization']){
        i['recipe'] = [];
        listOfRecipe.add(i);
      }
      print('condition 1');
    }else{
      print('condition 2');
      listOfRecipe = data['data']['fertilizerSet']['fertilizerSet'];
      dynamic check = {};
      for(var site in data['data']['default']['fertilization']){
        check['${site['sNo']}'] = {};
        check['${site['sNo']}']['fertilizer'] = [];
        for(var fert in site['fertilizer']){
          check['${site['sNo']}']['fertilizer'].add(fert['sNo']);
        }
        if(site['ec'].length != 0){
          check['${site['sNo']}']['ec'] = true;
        }else{
          check['${site['sNo']}']['ec'] = false;
        }
        if(site['ph'].length != 0){
          check['${site['sNo']}']['ph'] = true;
        }else{
          check['${site['sNo']}']['ph'] = false;
        }
      }
      //   checking the site is available
      for(var site = listOfRecipe.length - 1;site > -1;site--){
        if(check['${listOfRecipe[site]['sNo']}'] == null){
          listOfRecipe.removeAt(site);
        }
        else{
          for(var fert = listOfRecipe[site]['fertilizer'].length - 1;fert > -1;fert--){
            print('new : ${check['${listOfRecipe[site]['sNo']}']['fertilizer']}');
            print('old : ${listOfRecipe[site]['fertilizer'][fert]['sNo']}');
            if(!check['${listOfRecipe[site]['sNo']}']['fertilizer'].contains(listOfRecipe[site]['fertilizer'][fert]['sNo'])){
              listOfRecipe[site]['fertilizer'].removeAt(fert);
              for(var recipe in listOfRecipe[site]['recipe']){
                recipe['fertilizer'].removeAt(fert);
              }
            }
          }
          if(check['${listOfRecipe[site]['sNo']}']['ec'] == false){
            listOfRecipe[site]['ec'] = [];
            for(var recipe in listOfRecipe[site]['recipe']){
              if(recipe['ecActive'] != null){
                recipe.remove('ecActive');
              }
              if(recipe['Ec'] != null){
                recipe.remove('Ec');
              }
            }
          }
          if(check['${listOfRecipe[site]['sNo']}']['ph'] == false){
            listOfRecipe[site]['ph'] = [];
            for(var recipe in listOfRecipe[site]['recipe']){
              if(recipe['phActive'] != null){
                recipe.remove('phActive');
              }
              if(recipe['Ph'] != null){
                recipe.remove('Ph');
              }
            }
          }
          print('after filter : ${listOfRecipe[site]}');
        }
      }
      //   adding the new site
      var newSno = [];
      for(var old in listOfRecipe){
        newSno.add(old['sNo']);
      }
      for(var i in data['data']['default']['fertilization']){
        i['recipe'] = [];
        if(!newSno.contains(i['sNo'])){
          listOfRecipe.add(i);
        }
      }
    }
    notifyListeners();
  }

  dynamic editSample(dynamic data){
    var sample = [];
    for(var fert in data['fertilizer']){
      sample.add({
        'sNo' : fert['sNo'],
        'id' : fert['id'],
        'name' : fert['name'],
        'location' : fert['location'],
        'fertilizerMeter' : fert['fertilizerMeter'],
        'active' : false,
        'method' : 'Time',
        'timeValue' : '00:00:00',
        'quantityValue' : '0',
        'dmControl' : false,
      });
    }
    return sample;
  }

  void fertilizerFunctionality(list){
    switch( list[0]){
      case ('selectFertilizer'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['select'] = list[3];
        break;
      }
      case ('selectAllFertilizer'):{
        for(var i in listOfRecipe[selectedSite]['recipe']){
          i['select'] = true;
        }
        selectFunction = 1;
        break;
      }
      case ('deleteRecipe'):{
        print('list[1] : ${list[1]}');
        print(listOfRecipe[selectedSite]['recipe']);
        listOfRecipe[selectedSite]['recipe'].removeAt(list[1]);
      }
      case ('deleteFertilizer'):{
        var deleteList = [];
        for(var i in listOfRecipe[selectedSite]['recipe']){
          if(i['select'] == true){
            deleteList.add(i);
          }
        }
        for(var i in deleteList){
          if(listOfRecipe[selectedSite]['recipe'].contains(i)){
            listOfRecipe[selectedSite]['recipe'].remove(i);
          }
        }
        selectFunction = 0;
        break;
      }
      case ('cancelFertilizer'):{
        var deleteList = [];
        for(var i in listOfRecipe[selectedSite]['recipe']){
          if(i['select'] == true){
            i['select'] = false;
          }
        }
        selectFunction = 0;
        break;
      }
    }
    notifyListeners();
  }

  void editNameOfRecipe(String name,recipeIndex,){
    listOfRecipe[selectedSite]['recipe'][recipeIndex]['name'] = name;
    notifyListeners();
  }

  void listOfFertilizerFunctionality(list){
    switch (list[0]){
      case ('editActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['active'] = list[4];
        break;
      }
      case ('editDmControl'):{
        if(listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] == true){
          listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] = false;
        }else{
          listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] = true;
        }
        break;
      }
      case ('editMethod'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['method'] = list[4];
        break;
      }
      case ('editTimeOrQuantity'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['quantity/time'] = list[4];
        break;
      }
      case ('editTimeValue'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['timeValue'] = list[4];
        break;
      }
      case ('editQuantityValue'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['quantityValue'] = list[4];
        break;
      }
      case ('editEc'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['Ec'] = list[3];
        break;
      }
      case ('editEcActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['ecActive'] = list[3];
        break;
      }
      case ('editPh'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['Ph'] = list[3];
        break;
      }
      case ('editPhActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['phActive'] = list[3];
        break;
      }
    }
    notifyListeners();
    print(sample);
  }

  int fertMethod(String name){
    if(name == 'Time'){
      return 1;
    }else if(name == 'Time Proportional'){
      return 2;
    }else if(name == 'Quantity'){
      return 3;
    }else{
      return 4;
    }
  }

  dynamic hwPayload(){
    var payload = '';
    for(var i = 0;i < listOfRecipe.length;i++){
      for(var j = 0;j < listOfRecipe[i]['recipe'].length;j++){
        for(var fert in listOfRecipe[i]['recipe'][j]['fertilizer']){
          payload += '${payload.isNotEmpty ? ';' : '' }'
              '${fert['sNo']},'
              '${listOfRecipe[i]['recipe'][j]['sNo']},'
              '${listOfRecipe[i]['recipe'][j]['name']},'
              '${listOfRecipe[i]['recipe'][j]['ecActive'] == true ? 1 : 0},'
              '${listOfRecipe[i]['recipe'][j]['Ec']},'
              '${listOfRecipe[i]['recipe'][j]['phActive'] == true ? 1 : 0},'
              '${listOfRecipe[i]['recipe'][j]['Ph']},'
              '${listOfRecipe[i]['id']},'
              '${listOfRecipe[i]['recipe'][j]['fertilizer'].indexOf(fert) + 1},'
              '${fert['active'] == true ? 1 : 0},'
              '${fertMethod(fert['method'])},'
              '${['Time','Time Proportional'].contains(fert['method']) ? fert['timeValue'] : fert['quantityValue']},'
              '${fert['dmControl'] == true ? 1 : 0}' ;
        }
      }
    }
    print(payload);
    return {'2000' : [{'2001' : payload}]};
  }

  void clearProvider(){
    listOfRecipe = [];
    listOfSite = [];
    selectFunction = 0;
    sample = [];
    selectedSite = 0;
    wantToSendData = 0;
    autoIncrement = 0;
    notifyListeners();
  }
}
