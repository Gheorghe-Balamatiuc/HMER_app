import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/pages/product_page.dart';
import 'package:hmer_app/product_bloc_observer.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up the BLoC observer for debugging
  Bloc.observer = const ProductBlocObserver();
  
  // Run the app
  runApp(const MyApp());
}

/// Root widget of the application
/// Sets up dependency injection and the main app structure
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      // Provide a Repository instance to the widget tree
      create: (_) => Repository(),
      // Ensure the repository is properly disposed when no longer needed
      dispose: (repository) => repository.dispose(),
      child: BlocProvider(
        // Provide a ProductBloc instance and immediately fetch products
        create: (context) => ProductBloc(context.read<Repository>())
            ..add(ProductFetched()),
        child: MaterialApp(
          title: 'HMER App',
          home: ProductPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}