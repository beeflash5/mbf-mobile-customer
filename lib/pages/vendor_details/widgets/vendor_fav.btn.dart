import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/button/custom_outline_button.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/favourite_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';

class VendorFavButton extends ConsumerStatefulWidget {
  const VendorFavButton({super.key, required this.vendor, this.color});

  final Vendor vendor;
  final Color? color;

  @override
  ConsumerState<VendorFavButton> createState() => _VendorFavButtonState();
}

class _VendorFavButtonState extends ConsumerState<VendorFavButton> {
  bool _busy = false;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.vendor.isFavourite;
  }

  Future<void> _toggleFav() async {
    if (!AuthServices.authenticated()) {
      context.pushWidget(LoginPage());
      return;
    }
    setState(() => _busy = true);
    final notifier = ref.read(
      favouriteVendorControllerProvider(widget.vendor.id).notifier,
    );
    final result = await notifier.toggle(
      vendorId: widget.vendor.id,
      current: _isFav,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result != null) {
      setState(() {
        _isFav = result;
        widget.vendor.isFavourite = result;
      });
      if (result) {
        AlertService.success(text: "Added to favourite list");
      } else {
        AlertService.error(text: "Removed from favourite list");
      }
    } else {
      AlertService.error(text: "Failed to update favourite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomOutlineButton(
      loading: _busy,
      color: Colors.transparent,
      child: Icon(
        (!AuthServices.authenticated() || !_isFav)
            ? Icons.favorite_border
            : Icons.favorite,
        color: widget.color ?? Colors.red,
      ),
      onPressed: _toggleFav,
    );
  }
}
