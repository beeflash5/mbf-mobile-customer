import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/button/custom_outline_button.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/service_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';

class ServiceFavButton extends ConsumerStatefulWidget {
  const ServiceFavButton({super.key, required this.service, this.color});

  final Service service;
  final Color? color;

  @override
  ConsumerState<ServiceFavButton> createState() => _ServiceFavButtonState();
}

class _ServiceFavButtonState extends ConsumerState<ServiceFavButton> {
  bool _busy = false;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.service.isFavourite;
  }

  Future<void> _toggleFav() async {
    if (!AuthServices.authenticated()) {
      context.pushWidget(LoginPage());
      return;
    }
    setState(() => _busy = true);
    final notifier = ref.read(
      serviceDetailsControllerProvider(widget.service).notifier,
    );
    final result =
        _isFav
            ? await notifier.removeFromFavourite()
            : await notifier.addToFavourite();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.ok) {
        _isFav = !_isFav;
        widget.service.isFavourite = _isFav;
      }
    });
    if (result.ok) {
      if (result.message != null) {
        if (_isFav) {
          // _isFav was true before toggle → we just removed
          AlertService.error(text: result.message!);
        } else {
          AlertService.success(text: result.message!);
        }
      }
    } else if (result.message != null) {
      AlertService.error(text: result.message!);
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
