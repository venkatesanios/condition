
import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpService
{
  final String baseURL = "http://192.168.1.141:3000/api/v1/";//development
  Future<http.Response> postRequest(String action, Map<String, dynamic> data) async
  {
    var headers = {
      'Content-Type':'application/json',
      "action": action
    };
    var body = json.encode(data);

    return await http.post(Uri.parse(baseURL),
        headers : headers,
        body: body
    );
  }

  Future<http.Response> putRequest(String action, Map<String, dynamic> data) async
  {
    var headers = {
      'Content-Type':'application/json',
      "action": action
    };
    var body = json.encode(data);

    return await http.put(Uri.parse(baseURL),
        headers : headers,
        body: body
    );
  }
  Future<http.Response> deleteRequest(String action, Map<String, dynamic> data) async
  {
    var headers = {
      'Content-Type':'application/json',
      "action": action
    };
    var body = json.encode(data);

    return await http.put(Uri.parse(baseURL),
        headers : headers,
        body: body
    );
  }
}