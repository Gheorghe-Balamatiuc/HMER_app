import 'dart:typed_data';

class Image {
  const Image({
    required this.image,
    required this.id,
  });

  final Uint8List image;
  final int id;
}