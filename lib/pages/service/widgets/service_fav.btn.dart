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
        widget.service.isFavourite
            ? await notifier.removeFromFavourite()
            : await notifier.addToFavourite();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.ok) {
      if (result.message != null) {
        AlertService.success(text: result.message!);
      }
    } else if (result.message != null) {
      AlertService.error(text: result.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      serviceDetailsControllerProvider(widget.service),
    );
    final liveService = asyncState.valueOrNull?.service ?? widget.service;
    return CustomOutlineButton(
      loading: _busy,
      color: Colors.transparent,
      child: Icon(
        (!AuthServices.authenticated() || !liveService.isFavourite)
            ? Icons.favorite_border
            : Icons.favorite,
        color: widget.color ?? Colors.red,
      ),
      onPressed: _toggleFav,
    );
  }
}
