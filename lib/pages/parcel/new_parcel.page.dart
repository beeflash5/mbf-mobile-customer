import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/parcel/widgets/package_delivery_info.dart';
import 'package:fuodz/pages/parcel/widgets/package_delivery_parcel_info.dart';
import 'package:fuodz/pages/parcel/widgets/package_delivery_payment.dart';
import 'package:fuodz/pages/parcel/widgets/package_delivery_summary.dart';
import 'package:fuodz/pages/parcel/widgets/package_recipient_info.dart';
import 'package:fuodz/pages/parcel/widgets/package_type_selector.dart';
import 'package:fuodz/pages/parcel/widgets/vendor_package_type_selector.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class NewParcelPage extends ConsumerStatefulWidget {
  const NewParcelPage(
    this.vendorType, {
    super.key,
    this.onFinish,
  });

  final VendorType vendorType;
  final Function? onFinish;

  @override
  ConsumerState<NewParcelPage> createState() => _NewParcelPageState();
}

class _NewParcelPageState extends ConsumerState<NewParcelPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctl =
          ref.read(newParcelControllerProvider(widget.vendorType).notifier);
      ctl.onFinish = widget.onFinish;
      ctl.initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newParcelControllerProvider(widget.vendorType));
    final controller =
        ref.read(newParcelControllerProvider(widget.vendorType).notifier);
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      elevation: 0,
      showCart: false,
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Utils.textColorByTheme(),
      body: VStack(
        [
          VStack(
            [
              "New Order".tr().text
                  .color(Utils.textColorByTheme())
                  .bold
                  .xl3
                  .make(),
              "Please complete the steps below to place an order"
                  .tr()
                  .text
                  .base
                  .color(Utils.textColorByTheme())
                  .light
                  .make(),
              UiSpacer.vSpace(12),
              AnimatedSmoothIndicator(
                activeIndex: state.activeStep,
                count: 7,
                effect: ExpandingDotsEffect(
                  activeDotColor: context.theme.colorScheme.surface,
                  dotColor: context.theme.colorScheme.surface,
                  strokeWidth: 1,
                  paintStyle: PaintingStyle.stroke,
                ),
              ),
              UiSpacer.vSpace(10),
            ],
          )
              .p20()
              .box
              .bgImage(
                DecorationImage(
                  image: NetworkImage(widget.vendorType.logo),
                  opacity: 0.05,
                ),
              )
              .color(AppColor.primaryColor)
              .make()
              .wFull(context),
          PageView(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: [
              PackageTypeSelector(state: state, controller: controller),
              PackageDeliveryInfo(state: state, controller: controller),
              VendorPackageTypeSelector(state: state, controller: controller),
              PackageRecipientInfo(state: state, controller: controller),
              CustomVisibilty(
                visible: state.requireParcelInfo,
                child: PackageDeliveryParcelInfo(
                  state: state,
                  controller: controller,
                ),
              ),
              PackageDeliverySummary(state: state, controller: controller),
              PackageDeliveryPayment(state: state, controller: controller),
            ],
          ).box.make().px20().expand(),
        ],
      ).pOnly(bottom: context.mq.viewInsets.bottom),
    );
  }
}
