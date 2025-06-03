import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmer_app/api/repository.dart';
import 'package:hmer_app/bloc/product_event.dart';
import 'package:hmer_app/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState>  {
  ProductBloc(this._repository) : super(ProductInitial()) {
    on<ProductFetched>(_onFetched);
    on<ProductRefreshed>(_onRefreshed);
    on<ProductAdded>(_onAdded);
    on<ProductDeleted>(_onDeleted);
  }

  final Repository _repository;

  void _onFetched(ProductFetched event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    try {
      final images = await _repository.fetchImages();
      emit(ProductSuccess(images: images));
    } catch (e) {
      emit(ProductFailure());
    }
  }

  void _onRefreshed(ProductRefreshed event, Emitter<ProductState> emit) async {
    if (state is! ProductSuccess) return;
    try {
      final images = await _repository.fetchImages();
      emit(ProductSuccess(images: images));
    } catch (e) {
      emit(state);
    }
  }

  void _onAdded(ProductAdded event, Emitter<ProductState> emit) async {
    try {
      await _repository.uploadImage(event.image, event.name);
      add(ProductRefreshed());
    } catch (e) {
      emit(ProductFailure());
    }
  }

  void _onDeleted(ProductDeleted event, Emitter<ProductState> emit) async {
    if (state is! ProductSuccess) return;
    try {
      await _repository.deleteProduct(event.id);
      add(ProductRefreshed());
    } catch (e) {
      emit(ProductFailure());
    }
  }
}