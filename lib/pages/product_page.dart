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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final bloc = context.read<ProductBloc>();
              final FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                final name = file.name;
                final bytes = file.bytes!;
                if (file.bytes != null) {
                  bloc.add(ProductAdded(bytes, name));
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
        builder: (context, state) {
          return switch (state) {
            ProductInitial() => Center(child: const CircularProgressIndicator()),
            ProductLoading() => Center(child: const CircularProgressIndicator()),
            ProductSuccess(images: final images) => ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.memory(images[index].image),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<ProductBloc>().add(ProductDeleted(images[index].id));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ProductFailure() => Center(child: const Text('Failed to load images')),
          };
        },
      ),
    );
  }
}