import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';

/// Main page for displaying and interacting with mathematical expressions
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

  /// Initialize the text-to-speech engine with English language and reduced speech rate
  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setSpeechRate(0.6);
    _ttsInitialized = true;
  }

  /// Read the given text using the text-to-speech engine
  /// Initialize TTS if it hasn't been initialized yet
  Future<void> _speak(String text) async {
    if (!_ttsInitialized) {
      await _initTts();
    }
    
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    // Stop any ongoing speech before disposing the widget
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App bar with title and upload button
          SliverAppBar(
            snap: false,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Formula Reader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                'https://images.pond5.com/futuristic-fractal-dynamic-swirl-curves-footage-201600976_iconl.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            expandedHeight: 230,
            backgroundColor: const Color.fromARGB(255, 37, 40, 105),
            actions: [
              // Upload button in app bar - state dependent
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return switch (state) {
                    ProductInitial() => IconButton(
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                    ProductLoading() => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    ProductSuccess() => IconButton(
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                      // Handle file selection and upload
                      onPressed: () async {
                        final bloc = context.read<ProductBloc>();
                        final FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.any,
                          dialogTitle: 'Select an image file',
                          withData: true,
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
                    ProductFailure() => IconButton(
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  };
                },
              ),
            ],
          ),
          // Pull-to-refresh control
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              final completer = Completer<void>();
              
              // Listen for state changes to complete the refresh operation
              late final StreamSubscription subscription;
              subscription = context.read<ProductBloc>().stream.listen((state) {
                if (state is ProductSuccess) {
                  completer.complete();
                  subscription.cancel();
                } else if (state is ProductFailure) {
                  completer.completeError('Refresh failed');
                  subscription.cancel();
                }
              });
              
              // Trigger the refresh event
              context.read<ProductBloc>().add(ProductRefreshed());
              
              return completer.future;
            },
            refreshTriggerPullDistance: 120.0,
          ),
          // Main content - list of images with their predictions
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return switch (state) {
                ProductInitial() => SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                ),
                ProductLoading() => SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                ),
                ProductSuccess(images: final images) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Card(
                        margin: EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            spacing: 16.0,
                            children: [
                              // Display the image
                              Image.memory(
                                images[index].image,
                                fit: BoxFit.contain,
                              ),
                              // Button to copy LaTeX code
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: images[index].imagePrediction));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Prediction copied to clipboard')),
                                  );
                                },
                                child: const Text(
                                  'Copy LaTeX code',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              // Display prediction description with copy button
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 0,
                                children: [
                                  SizedBox(width: 22.0),
                                  Flexible(
                                    child: Text(
                                      images[index].predictionDescription,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    iconSize: 22.0,
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: images[index].predictionDescription));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Description copied to clipboard')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // TTS play and stop buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8.0,
                                children: [
                                  Flexible(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await _speak(images[index].predictionDescription);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                      ),
                                      child: const Icon(Icons.play_arrow),
                                    ),
                                  ),
                                  Flexible(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await _flutterTts.stop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                      ),
                                      child: const Icon(Icons.stop),
                                    ),
                                  ),
                                ],
                              ),
                              // Delete button
                              OutlinedButton(
                                onPressed: () {
                                  context.read<ProductBloc>().add(ProductDeleted(images[index].id));
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(
                                    double.infinity,
                                    48,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: images.length,
                  ),
                ),
                ProductFailure() => SliverToBoxAdapter(
                  child: Center(child: Text('Failed to load images'))
                ),
              };
            },
          ),
        ],
      ),
    );
  }
}