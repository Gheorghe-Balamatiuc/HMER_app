import 'dart:typed_data';

/// Represents an image with its metadata
/// Contains both the binary image data and metadata like prediction
class Image {
  const Image({
    required this.image,
    required this.id,
    required this.imagePrediction,
    required this.predictionDescription,
  });

  /// The binary data of the image
  final Uint8List image;
  
  /// The unique identifier of the image
  final int id;
  
  /// The LaTeX representation of the mathematical expression in the image
  final String imagePrediction;
  
  /// A textual description of the mathematical expression
  final String predictionDescription;
}