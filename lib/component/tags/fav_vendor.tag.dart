import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/favourite_providers.dart';
import 'package:fuodz/services/auth.service.dart';

class FavVendorTag extends ConsumerStatefulWidget {
  const FavVendorTag(this.vendor, {super.key});

  final Vendor vendor;

  @override
  ConsumerState<FavVendorTag> createState() => _FavVendorTagState();
}

class _FavVendorTagState extends ConsumerState<FavVendorTag> {
  @override
  Widget build(BuildContext context) {
    final isBusy =
        ref
            .watch(favouriteVendorControllerProvider(widget.vendor.id))
            .isLoading;

    return isBusy
        ? BusyIndicator().wh(18, 18).p4()
        : Icon(
          widget.vendor.isFavourite ? Icons.favorite : Icons.favorite_border,
          size: 22,
          color: Theme.of(context).primaryColor,
        ).p4().onTap(_handleTap);
  }

  Future<void> _handleTap() async {
    if (!AuthServices.authenticated()) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }
    final result = await ref
        .read(favouriteVendorControllerProvider(widget.vendor.id).notifier)
        .toggle(vendorId: widget.vendor.id, current: widget.vendor.isFavourite);
    if (result != null && mounted) {
      setState(() => widget.vendor.isFavourite = result);
    }
  }
}
