sealed class ProductEvent {
  const ProductEvent();
}

final class ProductFetched extends ProductEvent {
  const ProductFetched();
}

final class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}