import 'dart:convert';

import 'package:arhibu/global_service/firebase_secrvices.dart';
import 'package:http/http.dart' as http;

class RequestConfig {
  static String baseUrl = 'https://arhibu-be.onrender.com/api';

  static Future<http.Response> securePost(String endpoint, Map body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final token = await FirebaseServices.getUserToken();
    return http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> secureGet(String endpoint,
      {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: query);
    final token = await FirebaseServices.getUserToken();
    return http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
    );
  }
}
