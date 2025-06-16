import 'dart:typed_data';

import 'package:hmer_app/api/api.dart';
import 'package:hmer_app/models/image.dart';

/// Repository that mediates between the data source (API) and the application
/// Implements the repository pattern to abstract the data source from the business logic
class Repository {
  /// Creates a repository with an optional API client
  /// If no API client is provided, a new one will be created
  Repository({ApiService? apiClient})
      : _apiClient = apiClient ?? ApiService();

  final ApiService _apiClient;

  /// Fetches all images from the data source
  /// First fetches all products, then fetches the image data for each product
  /// Returns a list of Image objects containing both the image data and metadata
  Future<List<Image>> fetchImages() async {
    final images = List<Image>.empty(growable: true);

    // Fetch all products first
    for (var product in await _apiClient.fetchProducts()) {
      // Then fetch the image data for each product
      final image = await _apiClient.fetchImage(product);
      images.add(image);
    }

    return images;
  }

  /// Uploads an image to the data source
  /// Takes the binary image data and the filename
  Future<void> uploadImage(Uint8List image, String name) async {
    await _apiClient.uploadImage(image, name);
  }

  /// Deletes a product with the specified ID
  Future<void> deleteProduct(int id) async {
    await _apiClient.deleteProduct(id);
  }

  /// Releases resources when the repository is no longer needed
  void dispose() => _apiClient.close();
}