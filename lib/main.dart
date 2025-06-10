import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_bloc.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/pages/product_page.dart';
import 'package:hmer_app/product_bloc_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const ProductBlocObserver();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => Repository(),
      dispose: (repository) => repository.dispose(),
      child: BlocProvider(
        create: (context) => ProductBloc(context.read<Repository>())
            ..add(ProductFetched()),
        child: MaterialApp(
          title: 'HMER App',
          home: ProductPage(),
        ),
      ),
    );
  }
}