import 'dart:convert';
import 'dart:typed_data';

import 'package:hmer_app/models/image.dart';
import 'package:hmer_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Service for handling API requests to the backend server
/// Provides methods for fetching products, images, and handling CRUD operations
class ApiService {
  /// Creates an API service with an optional HTTP client
  /// If no client is provided, a new one will be created
  ApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  // Base URL for the API endpoints - configured for Android emulator
  final String _baseUrl = "http://10.0.2.2:5071";

  /// Fetches all products from the server
  /// Returns a list of Product objects
  /// Throws an exception if the request fails
  Future<List<Product>> fetchProducts() async {
    final response = await _httpClient.get(
      Uri.parse("$_baseUrl/Product"),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response into a list of Product objects
      Iterable list = json.decode(response.body);
      return List<Product>.from(list.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  /// Fetches the image data for a specific product
  /// Returns an Image object containing the binary image data and metadata
  /// Throws an exception if the request fails
  Future<Image> fetchImage(Product product) async {
    final response = await _httpClient.get(
      Uri.parse("$_baseUrl/resources/${product.image}"),
    );

    if (response.statusCode == 200) {
      // Create an Image object with the binary data and product metadata
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

  /// Uploads an image to the server
  /// Takes the binary image data and the filename
  /// Throws an exception if the upload fails
  Future<void> uploadImage(Uint8List imageBytes, String name) async {
    // Create a multipart request for uploading the image file
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/Product"),
    );

    // Add the image file to the request
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

  /// Deletes a product with the specified ID
  /// Throws an exception if the deletion fails
  Future<void> deleteProduct(int id) async {
    final response = await _httpClient.delete(
      Uri.parse("$_baseUrl/Product/$id"),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  /// Closes the HTTP client to free resources
  void close() {
    _httpClient.close();
  }
}