/// The catalogue's route paths (`P2-05`).
///
/// They live beside the screens rather than in `lib/app/` so the feature can
/// navigate within itself without importing the composition root, which the
/// layer rules forbid. The router builds its nested routes from these same
/// constants, so a path is written once and can never be spelled two ways.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The location of a catalogue screen.
abstract final class CatalogRoutes {
  const CatalogRoutes._();

  /// The product list, mounted as the products shell destination.
  static const String products = '/products';

  /// The form for a brand-new product.
  static const String create = '$products/$createSegment';

  /// The details screen of one product.
  static String details(String productId) => '$products/$productId';

  /// The edit form of one product.
  static String edit(String productId) => '${details(productId)}/$editSegment';

  /// The path segment of the create form, relative to [products].
  static const String createSegment = 'new';

  /// The path segment carrying a product id, relative to [products].
  static const String idSegment = ':id';

  /// The path segment of the edit form, relative to a product's details.
  static const String editSegment = 'edit';
}

/// Leaves a catalogue screen.
///
/// The details screen and the form both need this, so it lives here rather than
/// being written twice. Popping is the honest default — it returns to whatever
/// opened the screen — and the list is the fallback for a screen that was opened
/// directly by location, where there is nothing to pop.
void catalogBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(CatalogRoutes.products);
  }
}
