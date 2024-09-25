import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Dealer/CountryListMDL.dart';
import '../../Models/Dealer/StateListMDL.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key, required this.callback, required this.subUsrAccount, required this.customerId, required this.from,}) : super(key: key);
  final void Function(String) callback;
  final bool subUsrAccount;
  final int customerId;
  final String from;

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  String userID = '0';
  String userType = '0';
  String userMobileNo = '0';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cusNameController = TextEditingController();
  final TextEditingController _cusMobileNoController = TextEditingController();
  final TextEditingController _cusEmailController = TextEditingController();
  final TextEditingController _cusCityController = TextEditingController();
  final TextEditingController _cusAdd1Controller = TextEditingController();
  final TextEditingController _cusAdd2Controller = TextEditingController();
  final TextEditingController _cusAdd3Controller = TextEditingController();
  final TextEditingController _cusPinCodeController = TextEditingController();

  final TextEditingController ddCountryList = TextEditingController();
  late List<DropdownMenuEntry<CountryListMDL>> selectedCountry;
  List<CountryListMDL> countryList = <CountryListMDL>[];
  int sldCountryID = 0;
  bool showConError = false;

  final TextEditingController ddStateList = TextEditingController();
  late List<DropdownMenuEntry<StateListMDL>> selectedState;
  List<StateListMDL> stateList = <StateListMDL>[];
  int sldStateID = 0;
  bool showStateError = false;

  String dialCode = '91';

  String message = "No message yet";
  void updateMessage(String newMessage) {
    setState(() {
      message = newMessage;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedCountry =  <DropdownMenuEntry<CountryListMDL>>[];
    selectedState =  <DropdownMenuEntry<StateListMDL>>[];
    getUserInfo();
    getCountryList();
  }

  Future<void> getUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    userID = (prefs.getString('userId') ?? "");
    userType = (prefs.getString('userType') ?? "");
    userMobileNo = (prefs.getString('mobileNumber') ?? "");

    print(userID);
    print(widget.customerId);

  }

  Future<void> getCountryList() async
  {
    Map<String, Object> body = {};
    final response = await HttpService().postRequest("getCountry", body);
    if (response.statusCode == 200)
    {
      countryList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        countryList.add(CountryListMDL.fromJson(cntList[i]));
      }

      selectedCountry =  <DropdownMenuEntry<CountryListMDL>>[];
      for (final CountryListMDL index in countryList) {
        selectedCountry.add(DropdownMenuEntry<CountryListMDL>(value: index, label: index.countryName));
      }

      setState(() {
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getStateList(String countryId) async
  {
    Map<String, Object> body = {
      "countryId": countryId,
    };

    final response = await HttpService().postRequest("getState", body);
    if (response.statusCode == 200)
    {
      stateList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        stateList.add(StateListMDL.fromJson(cntList[i]));
      }

      selectedState =  <DropdownMenuEntry<StateListMDL>>[];
      for (final StateListMDL index in stateList) {
        selectedState.add(DropdownMenuEntry<StateListMDL>(value: index, label: index.stateName));
      }
      setState(() {
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 0),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFormContent(),
              ],
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return ListTile(
      title: Text(widget.from=='Admin'? "Create Dealer account      " : widget.from=='Dealer'? "Create customer account": "Create SubUser account", style: myTheme.textTheme.titleLarge),
      subtitle: Text("Please fill out all details correctly.", style: myTheme.textTheme.titleSmall),
    );
  }

  Widget _buildFormContent() {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _cusNameController,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: widget.from=='Admin'? 'Dealer Name':widget.from=='Dealer'?'Customer Name':'SubUser Name',
                    icon: Icon(Icons.person_outline, color: myTheme.primaryColor,),
                  ),
                  inputFormatters: [
                    CapitalizeFirstLetterFormatter(),
                  ],
                ),
                const SizedBox(height: 13,),
                // InternationalPhoneNumberInput(
                //   validator: (value){
                //     if(value==null ||value.isEmpty){
                //       return 'Please fill out this field';
                //     }
                //     return null;
                //   },
                //   inputDecoration: InputDecoration(
                //     contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                //     border: const OutlineInputBorder(),
                //     icon:  Icon(Icons.phone_outlined, color: myTheme.primaryColor,),
                //     labelText: 'Phone Number',
                //     suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.redAccent),
                //         onPressed: () {
                //           _cusMobileNoController.clear();
                //         }),
                //   ),
                //   onInputChanged: (PhoneNumber number) {
                //   },
                //
                //   selectorConfig: const SelectorConfig(
                //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                //     setSelectorButtonAsPrefixIcon: true,
                //     leadingPadding: 10,
                //     useEmoji: true,
                //   ),
                //   ignoreBlank: false,
                //   autoValidateMode: AutovalidateMode.disabled,
                //   selectorTextStyle: myTheme.textTheme.titleMedium,
                //   initialValue: PhoneNumber(isoCode: 'IN'),
                //   textFieldController: _cusMobileNoController,
                //   formatInput: false,
                //   keyboardType:
                //   const TextInputType.numberWithOptions(signed: true, decimal: true),
                //   onSaved: (PhoneNumber number) {
                //     dialCode = number.dialCode.toString();
                //   },
                // ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusEmailController,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: widget.from=='Admin'? 'Dealer Email':widget.from=='Dealer'?'Customer Email':'SubUser Email',
                    icon: Icon(Icons.email_outlined, color: myTheme.primaryColor,),
                  ),
                ),
                const SizedBox(height: 13,),
                Row(
                  children: [
                    Icon(Icons.map_outlined, color: myTheme.primaryColor,),
                    const SizedBox(width: 15,),
                    DropdownMenu<CountryListMDL>(
                      controller: ddCountryList,
                      errorText: showConError ? 'Select Country' : null,
                      hintText: 'Country',
                      width: 240,
                      dropdownMenuEntries: selectedCountry,
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSelected: (CountryListMDL? icon) {
                        setState(() {
                          sldCountryID = icon!.countryId;
                          showConError = false;
                          getStateList(sldCountryID.toString());
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 13,),
                Row(
                  children: [
                    Icon(Icons.pin_drop_outlined, color: myTheme.primaryColor,),
                    const SizedBox(width: 15,),
                    DropdownMenu<StateListMDL>(
                      controller: ddStateList,
                      errorText: showConError ? 'Select State' : null,
                      hintText: 'State',
                      width: 240,
                      //label: const Text('Category'),
                      dropdownMenuEntries: selectedState,
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSelected: (StateListMDL? icon) {
                        setState(() {
                          sldStateID = icon!.stateId;
                          showStateError = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusCityController,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: widget.from=='Admin'? 'Dealer City':widget.from=='Dealer'?'Customer City':'SubUser City',
                    icon: Icon(Icons.location_city, color: myTheme.primaryColor,),
                  ),
                  inputFormatters: [
                    CapitalizeFirstLetterFormatter(),
                  ],
                ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusAdd1Controller,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration:  InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: 'Address line 1',
                    icon: Icon(Icons.linear_scale_rounded, color: myTheme.primaryColor,),
                  ),
                  inputFormatters: [
                    CapitalizeFirstLetterFormatter(),
                  ],
                ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusAdd2Controller,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: 'Address line 2',
                    icon: Icon(Icons.linear_scale_rounded, color: myTheme.primaryColor,),
                  ),
                  inputFormatters: [
                    CapitalizeFirstLetterFormatter(),
                  ],
                ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusAdd3Controller,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: 'Address line 3',
                    icon: Icon(Icons.linear_scale_rounded, color: myTheme.primaryColor,),
                  ),
                  inputFormatters: [
                    CapitalizeFirstLetterFormatter(),
                  ],
                ),
                const SizedBox(height: 13,),
                TextFormField(
                  controller: _cusPinCodeController,
                  validator: (value){
                    if(value==null ||value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: const OutlineInputBorder(),
                    labelText: 'Postal code',
                    icon: Icon(Icons.local_post_office_outlined, color: myTheme.primaryColor,),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 56,
      child: Column(
        children: [
          ListTile(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  onPressed:() {
                    Navigator.pop(context);
                  },
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  child: const Text('Cancel',style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                MaterialButton(
                  onPressed:() async {
                    if (_formKey.currentState!.validate()) {
                      String cusType = widget.from=='Admin'? '2':'3';
                      Map<String, Object> body = {
                        'userName': _cusNameController.text,
                        'countryCode': dialCode,
                        'mobileNumber': _cusMobileNoController.text,
                        'userType': cusType,
                        'macAddress': '1234567890',
                        'deviceToken': '12346789abcdefghijklmnopqrstuvwxyz987654321',
                        'mobCctv': '987654321zyxwvutsrqponmlkjihgfedcba123456789',
                        'createUser': widget.customerId,
                        'address1': _cusAdd1Controller.text,
                        'address2': _cusAdd2Controller.text,
                        'address3': _cusAdd3Controller.text,
                        'city': _cusCityController.text,
                        'postalCode': _cusPinCodeController.text,
                        'country': sldCountryID.toString(),
                        'state': sldStateID.toString(),
                        'email': _cusEmailController.text,
                        'mainUserId': userID,
                      };
                      //print(body);
                      final response = widget.subUsrAccount? await HttpService().postRequest("createUserAccountWithMainUser", body):
                      await HttpService().postRequest("createUser", body);
                      print(response.body);
                      if(response.statusCode == 200)
                      {
                        var data = jsonDecode(response.body);
                        if(data["code"]==200)
                        {
                          widget.callback('reloadCustomer');
                          if(mounted){
                            Navigator.pop(context);
                          }
                        }
                        else{
                          if(data["code"]==409){
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Sub user'),
                                content: const Text('The mobile number already registered. Are you sure! You want add this customer?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      Map<String, Object> body = {
                                        'countryCode': dialCode,
                                        'mobileNumber': _cusMobileNoController.text,
                                        'modifyUser': userID,
                                        'mainUserId': widget.customerId,
                                      };
                                      final response = await HttpService().putRequest("updateMainUserDetail", body);
                                      if(response.statusCode == 200)
                                      {
                                        var data = jsonDecode(response.body);
                                        if(data["code"]==200)
                                        {
                                          widget.callback('reloadCustomer');
                                          if(mounted){
                                            Navigator.of(ctx).pop();
                                            Navigator.pop(context);
                                          }
                                        }
                                        else{
                                          Navigator.of(ctx).pop();
                                          _showAlertDialog('Warning', data["message"]);
                                        }
                                      }

                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Text("Add"),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                ],
                              ),
                            );

                          }else{
                            _showAlertDialog('Warning', data["message"]);
                          }
                        }
                      }
                    }
                  },
                  textColor: Colors.white,
                  color: myTheme.primaryColor,
                  child: const Text('Create',style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String title , String message)
  {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text("okay"),
            ),
          ),
        ],
      ),
    );
  }
}

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isNotEmpty) {
      return TextEditingValue(
        text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
