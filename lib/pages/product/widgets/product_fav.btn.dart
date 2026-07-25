import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/button/custom_outline_button.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/favourite_providers.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/providers/favourites_providers.dart';

class ProductFavButton extends ConsumerStatefulWidget {
  const ProductFavButton({super.key, required this.product, this.color});

  final Product product;
  final Color? color;

  @override
  ConsumerState<ProductFavButton> createState() => _ProductFavButtonState();
}

class _ProductFavButtonState extends ConsumerState<ProductFavButton> {
  bool _busy = false;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.product.isFavourite;
  }

  /// Returns true if the product is in the user's favourites,
  /// consulting the global IDs cache as the authoritative source.
  bool get _effectiveIsFav {
    final idsState = ref.watch(favouriteIdsProvider);
    final fromCache = idsState.valueOrNull?['product_ids']?.contains(widget.product.id);
    // If the cache has a definitive answer, trust it; otherwise fall back to model.
    if (fromCache != null) return fromCache;
    return _isFav;
  }

  Future<void> _toggleFav() async {
    if (!AuthServices.authenticated()) {
      context.pushWidget(LoginPage());
      return;
    }
    setState(() => _busy = true);
    final currentFav = _effectiveIsFav;
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final result =
        currentFav
            ? await notifier.removeFromFavourite()
            : await notifier.addToFavourite();
    if (!mounted) return;
    final newFav = !currentFav;
    setState(() {
      _busy = false;
      // Force UI update to match user expectation as API might return false negative
      _isFav = newFav;
      widget.product.isFavourite = newFav;
      // Also sync the global IDs cache
      ref.read(favouriteIdsProvider.notifier).toggleProduct(widget.product.id, newFav);
    });

    // Invalidate the provider so it re-fetches when next watched
    ref.invalidate(favouriteProductsControllerProvider);

    if (result.message != null) {
      AlertService.success(text: result.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _effectiveIsFav;
    return CustomOutlineButton(
      loading: _busy,
      color: Colors.transparent,
      child: Icon(
        (!AuthServices.authenticated() || !isFav)
            ? Icons.favorite_border
            : Icons.favorite,
        color: widget.color ?? Colors.red,
      ),
      onPressed: _toggleFav,
    );
  }
}
