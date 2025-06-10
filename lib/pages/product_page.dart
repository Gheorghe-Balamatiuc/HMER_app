import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late FlutterTts _flutterTts;
  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setVoice({"name": "Google UK English Female", "locale": "en-GB"});
    await _flutterTts.setSpeechRate(0.6);
    _ttsInitialized = true;
  }

  Future<void> _speak(String text) async {
    if (!_ttsInitialized) {
      await _initTts();
    }
    // Re-apply settings to ensure they're active
    await _flutterTts.setVoice({"name": "Google UK English Female", "locale": "en-GB"});
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8.0,
                        children: [
                          Flexible(
                            child: Text(
                              images[index].imagePrediction,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: images[index].imagePrediction));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Prediction copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8.0,
                        children: [
                          Flexible(
                            child: Text(
                              images[index].predictionDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () async {
                              await _speak(images[index].predictionDescription);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop),
                            onPressed: () async {
                              await _flutterTts.stop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: images[index].predictionDescription));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Description copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
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