import 'dart:convert';

import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String _baseUrl = "https://localhost:7005";

  Future<List<Product>> fetchProducts() async {
    final response = await _httpClient.get(
      Uri.parse("$_baseUrl/Product"),
    );

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return List<Product>.from(list.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Image> fetchImage(String image) async {
    final response = await _httpClient.get(
      Uri.parse("$_baseUrl/resources/$image"),
    );

    if (response.statusCode == 200) {
      return Image(image: response.bodyBytes);
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  void close() {
    _httpClient.close();
  }
}