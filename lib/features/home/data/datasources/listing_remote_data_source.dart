import 'dart:convert';

import 'package:arhibu/global_service/firebase_secrvices.dart';
import 'package:http/http.dart' as http;

import '../models/listing_model.dart';

abstract class ListingRemoteDataSource {
  Future<List<ListingModel>> fetchListings();
  Future<void> createListing(ListingModel model);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final http.Client client;

  ListingRemoteDataSourceImpl(this.client);

  final String baseUrl = 'https://arhibu-be.onrender.com/api/listings/';

  @override
  Future<List<ListingModel>> fetchListings() async {
    final token = await FirebaseServices.getUserToken();
    final response = await client.get(Uri.parse(baseUrl),headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}',
    });
    
    // print('Status code: ${response.statusCode}');
    // print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonData = decoded['listings'];
      return jsonData.map((e) => ListingModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch listings: ${response.body}");
    }
  }

  @override
  Future<void> createListing(ListingModel model) async {
    final token = await FirebaseServices.getUserToken();
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {  'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}',},
      body: json.encode(model.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to create listing");
    }
  }
}
