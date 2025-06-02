import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    Uint8List? image;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                if (file.bytes != null) {
                  image = file.bytes;
                  print('file name: ${file.name}');
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(ProductRefreshed());
            },
          ),
          SizedBox(width: 48),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          return switch (state) {
            ProductInitial() => const CircularProgressIndicator(),
            ProductLoading() => const CircularProgressIndicator(),
            ProductSuccess(images: final images) => ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.memory(images[index].image);
              },
            ),
            ProductFailure() => const Text('Failed to load images'),
          };
        },
      ),
    );
  }
}