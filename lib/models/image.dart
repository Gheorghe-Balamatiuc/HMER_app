import 'dart:typed_data';

class Image {
  const Image({
    required this.image,
    required this.id,
    required this.imagePrediction,
    required this.predictionDescription,
  });

  final Uint8List image;
  final int id;
  final String imagePrediction;
  final String predictionDescription;
}