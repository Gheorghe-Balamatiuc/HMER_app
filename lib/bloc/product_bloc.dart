import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';
import 'package:logger/logger.dart';

// Logger for debugging purposes
final logger = Logger();

/// BLoC (Business Logic Component) for managing products
/// Handles product-related events and emits new states accordingly
class ProductBloc extends Bloc<ProductEvent, ProductState>  {
  /// Creates a product bloc with a repository dependency
  ProductBloc(this._repository) : super(ProductInitial()) {
    // Register event handlers
    on<ProductFetched>(_onFetched);
    on<ProductRefreshed>(_onRefreshed);
    on<ProductAdded>(_onAdded);
    on<ProductDeleted>(_onDeleted);
  }

  final Repository _repository;

  /// Handles the ProductFetched event
  /// Emits ProductLoading followed by either ProductSuccess or ProductFailure
  void _onFetched(ProductFetched event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    try {
      final images = await _repository.fetchImages();
      emit(ProductSuccess(images: images));
    } catch (e) {
      logger.e("Error fetching products: $e");
      emit(ProductFailure());
    }
  }

  /// Handles the ProductRefreshed event
  /// Only works if the current state is ProductSuccess
  /// Updates the list of images without showing a loading state
  void _onRefreshed(ProductRefreshed event, Emitter<ProductState> emit) async {
    if (state is! ProductSuccess) return;
    try {
      final images = await _repository.fetchImages();
      emit(ProductSuccess(images: images));
    } catch (e) {
      logger.e("Error refreshing products: $e");
      emit(state);
    }
  }

  /// Handles the ProductAdded event
  /// Uploads a new image and refreshes the product list
  void _onAdded(ProductAdded event, Emitter<ProductState> emit) async {
    if (state is! ProductSuccess) return;
    try {
      emit(ProductLoading());
      await _repository.uploadImage(event.image, event.name);
      final images = await _repository.fetchImages();
      emit(ProductSuccess(images: images));
      add(ProductRefreshed());
    } catch (e) {
      logger.e("Error adding product: $e");
      emit(ProductFailure());
    }
  }

  /// Handles the ProductDeleted event
  /// Deletes a product and refreshes the product list
  void _onDeleted(ProductDeleted event, Emitter<ProductState> emit) async {
    if (state is! ProductSuccess) return;
    try {
      await _repository.deleteProduct(event.id);
      add(ProductRefreshed());
    } catch (e) {
      logger.e("Error deleting product: $e");
      emit(ProductFailure());
    }
  }
}