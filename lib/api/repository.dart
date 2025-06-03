import 'dart:typed_data';

import 'package:hmer_app/api/api.dart';
import 'package:hmer_app/models/image.dart';

class Repository {
  Repository({ApiService? apiClient})
      : _apiClient = apiClient ?? ApiService();

  final ApiService _apiClient;

  Future<List<Image>> fetchImages() async {
    final images = List<Image>.empty(growable: true);

    for (var product in await _apiClient.fetchProducts()) {
      final image = await _apiClient.fetchImage(product);
      images.add(image);
    }

    return images;
  }

  Future<void> uploadImage(Uint8List image, String name) async {
    await _apiClient.uploadImage(image, name);
  }

  void dispose() => _apiClient.close();
}