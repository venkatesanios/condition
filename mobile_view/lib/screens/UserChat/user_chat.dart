import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_view/constants/http_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  final int userId, dealerId;
  final String userName;
  const UserChatScreen({super.key, required this.userId, required this.dealerId, required this.userName});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  late OverAllUse overAllUse;
  List messages = [];
  List chatIds = [];
  String errorMessage = '';
  int dealerId = 0;
  String dealerName = "";
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateTime time = DateTime.now();

  @override
  void initState() {
    super.initState();
    overAllUse = Provider.of<OverAllUse>(context, listen: false);
    if (mounted) {
      getData();
    }
  }

  Future<void> getData() async {
    await getUserDealerDetails();
    await getUserChat();
    updateUserChatReadStatus();
  }

  Future<void> getUserDealerDetails() async {
    Map<String, dynamic> userData = {
      "userId": widget.userId,
    };

    try {
      final getUserDealerDetails = await HttpService().postRequest("getUserDealerDetails", userData);
      if (getUserDealerDetails.statusCode == 200) {
        setState(() {
          final response = jsonDecode(getUserDealerDetails.body);
          if (response['code'] == 200) {
            dealerId = response['data']['userId'];
            dealerName = response['data']['userName'];
          } else {
            errorMessage = response['message'];
          }
        });
      }
    } catch (error, stackTrace) {
      print("Error in the user chat: $error");
      print("Stack trace in user chat: $stackTrace");
    }
  }

  Future<void> getUserChat() async {
    Map<String, dynamic> userData = {
      "fromUserId": widget.dealerId != 0 ? dealerId : widget.userId,
      "toUserId": widget.dealerId != 0 ? widget.userId : dealerId,
    };

    // print(userData);
    try {
      final getUserChat = await HttpService().postRequest("getUserChat", userData);
      if (getUserChat.statusCode == 200) {
        chatIds.clear();
        setState(() {
          final response = jsonDecode(getUserChat.body);
          if (response['code'] == 200) {
            messages = response['data'];
            messages.forEach((element) {
              if(((widget.dealerId != 0 ? dealerId : widget.userId) == element['toUserId']) && element['readStatus'] == "0") {
                chatIds.add(element['chatId']);
              }
            });
            // print("getUserChat");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            });
            // print("chatIds ==> $chatIds");
          } else {
            errorMessage = response['message'];
          }
        });
      }
    } catch (error, stackTrace) {
      print("Error in the user chat: $error");
      print("Stack trace in user chat: $stackTrace");
    }
  }

  Future<void> updateUserChatReadStatus() async {
    Map<String, dynamic> userData = {
      "chatId": chatIds,
      "toUserId": widget.dealerId != 0 ? dealerId : widget.userId,
      "fromUserId": widget.dealerId != 0 ? widget.userId : dealerId,
    };

    print(userData);
    try {
      final updateUserChatReadStatus = await HttpService().putRequest("updateUserChatReadStatus", userData);
      print(updateUserChatReadStatus.body);
      if (updateUserChatReadStatus.statusCode == 200) {
        setState(() {
          final response = jsonDecode(updateUserChatReadStatus.body);
          print(response);
          if (response['code'] == 200) {
            print(response);
            print("updateUserChatReadStatus");
          } else {
            errorMessage = response['message'];
          }
        });
      }
    } catch (error, stackTrace) {
      print("Error in the user chat: $error");
      print("Stack trace in user chat: $stackTrace");
    }
  }

  Future<void> createUserChat() async {
    Map<String, dynamic> userData = {
      "fromUserId": widget.dealerId != 0 ? dealerId : widget.userId,
      "toUserId": widget.dealerId != 0 ? widget.userId : dealerId,
      "date": DateFormat("yyyy-MM-dd").format(time),
      "time": DateFormat("HH:mm:ss").format(time),
      "message": _messageController.text,
    };

    // print(userData);
    try {
      final createUserChat = await HttpService().postRequest("createUserChat", userData);
      setState(() {
        if (createUserChat.statusCode == 200) {
          _messageController.clear();
          getUserChat().whenComplete(() {
            updateUserChatReadStatus();
          });
        } else {
          errorMessage = jsonDecode(createUserChat.body)['message'];
        }
      });
    } catch (error, stackTrace) {
      print("Error in the user chat: $error");
      print("Stack trace in user chat: $stackTrace");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  void _sendMessage() {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      createUserChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dealerId != 0 ? widget.userName : dealerName}')),
      body: RefreshIndicator(
        onRefresh: getData,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index];
                    final isUserMessage = message['fromUserId'] == (widget.dealerId != 0 ? dealerId : widget.userId);
                    return Align(
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message['message'],
                                style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                              ),
                            ),
                            Icon(
                                isUserMessage
                                    ? message['readStatus'] == "1"
                                    ? Icons.done_all
                                    : null
                                    : null,
                              size: 12,
                              // style: TextStyle(
                              //   fontSize: 10
                              // ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type your message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onSubmitted: (text) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
