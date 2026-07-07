import 'package:dartx/dartx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/favourite.request.dart';
import 'package:fuodz/services/product.request.dart';

final _productRequestProvider = Provider<ProductRequest>(
  (_) => ProductRequest(),
);
final _favouriteRequestProvider = Provider<FavouriteRequest>(
  (_) => FavouriteRequest(),
);

sealed class AddToCartResult {
  const AddToCartResult();
}

class AddToCartSuccess extends AddToCartResult {
  const AddToCartSuccess(this.cart);
  final Cart cart;
}

class AddToCartConflictVendor extends AddToCartResult {
  const AddToCartConflictVendor();
}

class AddToCartConflictDigital extends AddToCartResult {
  const AddToCartConflictDigital();
}

class AddToCartRequiredOption extends AddToCartResult {
  const AddToCartRequiredOption(this.groupName);
  final String groupName;
}

class AddToCartMaxReached extends AddToCartResult {
  const AddToCartMaxReached(this.message);
  final String message;
}

class AddToCartFailure extends AddToCartResult {
  const AddToCartFailure(this.message);
  final String message;
}

class FavouriteResult {
  const FavouriteResult({required this.ok, this.message});
  final bool ok;
  final String? message;
}

class ProductDetailsState {
  ProductDetailsState({
    required this.product,
    this.selectedOptions = const [],
    this.subTotal = 0,
    this.total = 0,
  });
  final Product product;
  final List<Option> selectedOptions;
  final double subTotal;
  final double total;

  List<int> get selectedOptionIds => selectedOptions.map((e) => e.id).toList();

  ProductDetailsState copyWith({
    Product? product,
    List<Option>? selectedOptions,
    double? subTotal,
    double? total,
  }) => ProductDetailsState(
    product: product ?? this.product,
    selectedOptions: selectedOptions ?? this.selectedOptions,
    subTotal: subTotal ?? this.subTotal,
    total: total ?? this.total,
  );
}

class ProductDetailsController
    extends FamilyAsyncNotifier<ProductDetailsState, Product> {
  @override
  Future<ProductDetailsState> build(Product arg) async {
    final oldTag = arg.heroTag;
    final detail = await ref
        .read(_productRequestProvider)
        .productDetails(arg.id);
    detail.heroTag = oldTag;
    if (detail.selectedQty < 1) detail.selectedQty = 1;

    // The detail API endpoint may not return `variants`, but the list endpoint does.
    // Preserve any variant OptionGroups (id == -1) from the original arg product
    // so they are not lost after a fresh fetch.
    final hasVariantGroup = detail.optionGroups.any((g) => g.id == -1);
    if (!hasVariantGroup) {
      final argVariantGroups = arg.optionGroups.where((g) => g.id == -1).toList();
      if (argVariantGroups.isNotEmpty) {
        detail.optionGroups = [...argVariantGroups, ...detail.optionGroups];
      }
    }

    return _recalculate(ProductDetailsState(product: detail));
  }

  ProductDetailsState _recalculate(ProductDetailsState s) {
    final p = s.product;
    final price = !p.showDiscount ? p.price : p.discountPrice;
    double options = 0;
    for (final o in s.selectedOptions) {
      options += o.price;
    }
    final sub =
        (p.plusOption == 1 || s.selectedOptions.isEmpty)
            ? price + options
            : options;
    return s.copyWith(subTotal: sub, total: sub * p.selectedQty);
  }

  void updateSelectedQty(int qty) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    cur.product.selectedQty = qty;
    state = AsyncData(_recalculate(cur));
  }

  bool isOptionSelected(Option option) {
    return state.valueOrNull?.selectedOptionIds.contains(option.id) ?? false;
  }

  /// Returns null on success, or an error message string if a max-options
  /// rule was violated.
  String? toggleOption(OptionGroup group, Option option) {
    final cur = state.valueOrNull;
    if (cur == null) return null;
    final selected = [...cur.selectedOptions];
    final ids = selected.map((e) => e.id).toList();
    if (ids.contains(option.id)) {
      selected.removeWhere((e) => e.id == option.id);
    } else {
      if (group.multiple == 0) {
        final found = selected.firstOrNullWhere(
          (o) => o.optionGroupId == group.id,
        );
        if (found != null) selected.remove(found);
      }
      if (group.maxOptions != null && group.maxOptions! > 0) {
        final count = selected.where((e) => e.optionGroupId == group.id).length;
        if (count >= group.maxOptions!) {
          return "You can only select ${group.maxOptions} options for ${group.name}";
        }
      }
      selected.add(option);
    }
    state = AsyncData(_recalculate(cur.copyWith(selectedOptions: selected)));
    return null;
  }

  /// Remove all selections from [group] (used by the "None" deselect button).
  void clearOptionGroup(OptionGroup group) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final selected = [
      ...cur.selectedOptions.where((o) => o.optionGroupId != group.id),
    ];
    state = AsyncData(_recalculate(cur.copyWith(selectedOptions: selected)));
  }

  String? optionGroupRequirementCheck() {
    final cur = state.valueOrNull;
    if (cur == null) return null;
    for (final group in cur.product.optionGroups) {
      final hasSelection = cur.selectedOptions.any(
        (o) => o.optionGroupId == group.id,
      );
      // By user request, make options optional even if the API says required == 1
      // if (group.required == 1 && !hasSelection) {
      //   return "You are required to select at least one option of ${group.name}";
      // }
    }
    return null;
  }

  /// Builds the Cart for the current state. Caller decides whether to
  /// actually persist it (CartServices.addToCart).
  Cart buildCart() {
    final cur = state.valueOrNull!;
    return Cart()
      ..price = cur.subTotal
      ..product = cur.product
      ..selectedQty = cur.product.selectedQty
      ..options = cur.selectedOptions
      ..optionsIds = cur.selectedOptionIds;
  }

  Future<FavouriteResult> addToFavourite() async {
    try {
      final res = await ref
          .read(_favouriteRequestProvider)
          .makeFavourite(arg.id);
      if (res.allGood) {
        final cur = state.valueOrNull;
        if (cur != null) {
          cur.product.isFavourite = true;
          state = AsyncData(cur);
        }
      }
      return FavouriteResult(ok: res.allGood, message: res.message);
    } catch (e) {
      return FavouriteResult(ok: false, message: '$e');
    }
  }

  Future<FavouriteResult> removeFromFavourite() async {
    try {
      final res = await ref
          .read(_favouriteRequestProvider)
          .removeFavourite(arg.id);
      if (res.allGood) {
        final cur = state.valueOrNull;
        if (cur != null) {
          cur.product.isFavourite = false;
          state = AsyncData(cur);
        }
      }
      return FavouriteResult(ok: res.allGood, message: res.message);
    } catch (e) {
      return FavouriteResult(ok: false, message: '$e');
    }
  }
}

final productDetailsControllerProvider = AsyncNotifierProvider.family<
  ProductDetailsController,
  ProductDetailsState,
  Product
>(ProductDetailsController.new);
