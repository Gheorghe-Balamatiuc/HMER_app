import 'dart:convert';
import 'dart:typed_data';

import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  ApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String _baseUrl = "http://10.0.2.2:5071";

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

  Future<Image> fetchImage(Product product) async {
    final response = await _httpClient.get(
      Uri.parse("$_baseUrl/resources/${product.image}"),
    );

    if (response.statusCode == 200) {
      return Image(
        image: response.bodyBytes, 
        id: product.id, 
        imagePrediction: product.imagePrediction,
        predictionDescription: product.predictionDescription,
      );
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  Future<void> uploadImage(Uint8List imageBytes, String name) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/Product"),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'ImageFile',
      imageBytes,
      filename: name,
      contentType: MediaType('image', name.split('.').last),
    ));

    final response = await _httpClient.send(request);

    if (response.statusCode != 201) {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await _httpClient.delete(
      Uri.parse("$_baseUrl/Product/$id"),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  void close() {
    _httpClient.close();
  }
}