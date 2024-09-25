// lib/main.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Models/servicecustomermodel.dart';
import '../constants/http_service.dart';
import '../constants/snack_bar.dart';
import '../state_management/overall_use.dart';
import 'package:http/http.dart' as http;


class TicketHomePage extends StatefulWidget {
  final int userId, controllerId;
  const TicketHomePage(
      {super.key, required this.userId, required this.controllerId});

  @override
  State<TicketHomePage> createState() => _TicketHomePageState();
}

class _TicketHomePageState extends State<TicketHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController otherstextctrl = TextEditingController();
  RequestType _selectedCategory = RequestType();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeformat = DateFormat("HH:mm:ss");
  DateFormat ExceptdateFormat = DateFormat("yyyy-MM-dd");
  ServicecustomerModel _servicecustomerModel = ServicecustomerModel();
  String dropdownvalue = 'Controller Issue';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final response =
    await HttpService().postRequest("getUserServiceRequest", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsonData1 = jsonDecode(response.body);
        _servicecustomerModel = ServicecustomerModel.fromJson(jsonData1);
      });
    } else {
      // _showSnackBar(response.body);
    }
  }

  Future<void> updateData(
      int requestTypeId,
      String requestDate,
      String requestDescription,
      String requestTime,
      int responsibleUser,
      String estimatedDate) async {
    otherstextctrl.clear();

    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "requestTypeId": requestTypeId,
      "requestDescription": requestDescription,
      "requestDate": requestDate,
      "requestTime": requestTime,
      "responsibleUser": responsibleUser,
      "estimatedDate": estimatedDate,
      "siteLocation": '',
      "createUser": overAllPvd.userId
    };
    final response =
    await HttpService().postRequest("createUserServiceRequest", body);
    print('response    ${response.body}');
    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        GlobalSnackBar.show(context, jsonData['message'], response.statusCode);
        fetchData();
      });
    } else {
      GlobalSnackBar.show(context, jsonData['message'], response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_servicecustomerModel.data == null) {
      return Scaffold(
        body: const Center(
            child: Text(
              'Currently no service Request available ',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
      );
    } else if (_servicecustomerModel.data!.dataDefault!.requestType!.length <=
        0) {
      return Scaffold(
        body: const Center(
            child: Text(
              'Currently service Request Not available our Account',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
      );
    } else {
      // _categories =   _servicecustomerModel.data?.dataDefault!.requestType!.where(e) -> value

      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: AppBar(

          title: Text("Service Request"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    DropdownButton(
                      iconSize: 32,
                      dropdownColor: Colors.teal.shade100,
                      // Initial Value
                      value: dropdownvalue,
                      // Down Arrow Icon
                      icon: const Icon(Icons.arrow_drop_down_sharp),
                      // Array list of items
                      items: _servicecustomerModel
                          .data!.dataDefault!.requestType!
                          .map((items) {
                        return DropdownMenuItem(
                          value: items.requestType,
                          child: Text(items.requestType!),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          _selectedCategory = _servicecustomerModel
                              .data!.dataDefault!.requestType!
                              .firstWhere((e) => e.requestType == newValue);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      width: 400,
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 5) {
                            return 'Please Enter a Valid Reason';
                          }
                          return null;
                        },
                        maxLength: 200,
                        controller: otherstextctrl,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _selectedCategory.requestType,
                          hintText: 'Explain here',
                        ),
                        autofocus: true,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print(
                            '_selectedCategory.requestTypeId ----->${_selectedCategory.requestTypeId}');
                        try {
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              updateData(
                                  _selectedCategory.requestTypeId ?? 3,
                                  dateFormat.format(DateTime.now()),
                                  otherstextctrl.text,
                                  timeformat.format(DateTime.now()),
                                  _servicecustomerModel
                                      .data!.dataDefault!.dealer![0].userId!,
                                  ExceptdateFormat.format(
                                      DateTime.now().add(Duration(days: 2))));
                            }
                          }
                        } catch (error, stackTrace) {}
                      },
                      child: const Text('Raise Ticket'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                    child: Center(
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          for (var index = 0;
                          index <
                              _servicecustomerModel
                                  .data!.serviceRequest!.length;
                          index++)
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: customBoxShadow),
                                height: 250,
                                width: 250,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IntrinsicHeight(
                                        child: Center(
                                            child: Text(
                                              '${_servicecustomerModel.data!.serviceRequest![index].requestType}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21),
                                            ))),
                                    Container(
                                        height: 60,
                                        width: double.infinity,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Text(
                                                '${_servicecustomerModel.data!.serviceRequest![index].requestDescription}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.normal)))),
                                    Text(
                                      '${_servicecustomerModel.data!.serviceRequest![index].requestDate} ${_servicecustomerModel.data!.serviceRequest![index].requestTime}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Exceptation Date:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: const Color(0xff15C0E6),
                                      ),
                                    ),
                                    Text(
                                      '${_servicecustomerModel.data!.serviceRequest![index].estimatedDate}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Responsiplity:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: const Color(0xff15C0E6),
                                      ),
                                    ),
                                    Text(
                                      '${_servicecustomerModel.data!.serviceRequest![index].responsibleUserName}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${_servicecustomerModel.data!.serviceRequest![index].status}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 21,
                                            color: '${_servicecustomerModel.data!.serviceRequest![index].responsibleUserName}' ==
                                                'Waiting'
                                                ? Color(0xfff3bf21)
                                                : '${_servicecustomerModel.data!.serviceRequest![index].responsibleUserName}' ==
                                                'Completed'
                                                ? Color(0xff21f33d)
                                                : Color(0xff1c7b89))),
                                  ],
                                ))
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      );
    }
  }
}

List<BoxShadow> customBoxShadow = [
  BoxShadow(
      offset: const Offset(0, 45),
      blurRadius: 112,
      color: Colors.black.withOpacity(0.06)),
  BoxShadow(
      offset: const Offset(0, 22.78),
      blurRadius: 48.83,
      color: Colors.black.withOpacity(0.0405)),
  BoxShadow(
      offset: const Offset(0, 9),
      blurRadius: 18.2,
      color: Colors.black.withOpacity(0.03)),
  BoxShadow(
      offset: const Offset(0, 1.97),
      blurRadius: 6.47,
      color: Colors.black.withOpacity(0.0195)),
];