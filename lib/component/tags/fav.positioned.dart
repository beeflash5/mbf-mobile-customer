import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/favourite_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

class FavPositiedView extends ConsumerStatefulWidget {
  const FavPositiedView(this.product, {super.key});

  final Product product;

  @override
  ConsumerState<FavPositiedView> createState() => _FavPositiedViewState();
}

class _FavPositiedViewState extends ConsumerState<FavPositiedView> {
  @override
  Widget build(BuildContext context) {
    final isBusy = ref
        .watch(favouriteProductControllerProvider(widget.product.id))
        .isLoading;

    return Positioned(
      top: 0,
      left: !Utils.isArabic ? null : 0,
      right: Utils.isArabic ? null : 0,
      child: isBusy
          ? BusyIndicator().wh(18, 18).p4()
          : Icon(
              widget.product.isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: AppColor.primaryColor,
              size: 20,
            ).p4().onTap(_handleTap),
    );
  }

  Future<void> _handleTap() async {
    if (!AuthServices.authenticated()) {
      context.pushRoute(AppRoutes.loginRoute);
      return;
    }
    final result = await ref
        .read(favouriteProductControllerProvider(widget.product.id).notifier)
        .toggle(
          productId: widget.product.id,
          current: widget.product.isFavourite,
        );
    if (result != null && mounted) {
      setState(() => widget.product.isFavourite = result);
    }
  }
}
