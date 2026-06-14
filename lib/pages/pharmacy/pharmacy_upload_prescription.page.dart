import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/checkout/widgets/order_delivery_address.view.dart';
import 'package:fuodz/pages/checkout/widgets/schedule_order.view.dart';
import 'package:fuodz/providers/pharmacy_upload_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class PharmacyUploadPrescription extends ConsumerStatefulWidget {
  const PharmacyUploadPrescription(this.vendor, {super.key});

  final Vendor vendor;

  @override
  ConsumerState<PharmacyUploadPrescription> createState() =>
      _PharmacyUploadPrescriptionState();
}

class _PharmacyUploadPrescriptionState
    extends ConsumerState<PharmacyUploadPrescription> {
  final TextEditingController _noteTEC = TextEditingController();
  final TextEditingController _guestCountTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pharmacyUploadControllerProvider(widget.vendor).notifier)
          .initialise();
    });
  }

  @override
  void dispose() {
    _noteTEC.dispose();
    _guestCountTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pharmacyUploadControllerProvider(widget.vendor));
    final controller = ref.read(
      pharmacyUploadControllerProvider(widget.vendor).notifier,
    );
    final vendor = state.vendor ?? widget.vendor;
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      elevation: 0,
      title: ("Upload Prescription".tr() + " ${vendor.name}"),
      appBarColor: context.theme.colorScheme.surface,
      appBarItemColor: AppColor.primaryColor,
      showCart: true,
      body: VStack([
        // prescription photo grid
        VStack([
          CustomGridView(
            noScrollPhysics: true,
            dataSet: state.prescriptionPhotos,
            separatorBuilder: (p0, p1) => UiSpacer.vSpace(10),
            itemBuilder: (ctx, index) {
              final prescriptionPhoto = state.prescriptionPhotos[index];
              return Stack(
                children: [
                  Image.file(
                    prescriptionPhoto,
                    fit: BoxFit.cover,
                  ).wFull(context),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.delete, color: Colors.white, size: 16)
                        .p4()
                        .box
                        .red500
                        .roundedSM
                        .clip(Clip.antiAlias)
                        .make()
                        .onTap(() => controller.removePhoto(index)),
                  ),
                ],
              ).wFull(context).h(100);
            },
          ),
          CustomButton(
            child:
                HStack([
                  Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Utils.textColorByPrimaryColor(),
                  ),
                  UiSpacer.horizontalSpace(space: 10),
                  "Upload Photo".text
                      .color(Utils.textColorByPrimaryColor())
                      .make(),
                ]).centered(),
            shapeRadius: 30,
            height: 20,
            titleStyle: context.textTheme.bodyLarge!.copyWith(
              fontSize: 11,
              color: Utils.textColorByPrimaryColor(),
            ),
            onPressed: controller.changePhoto,
          ).px(context.percentWidth * 25).py(15).centered(),
        ]).wFull(context),

        UiSpacer.verticalSpace(),
        ScheduleOrderView(
          vendor: vendor,
          isScheduled: state.isScheduled,
          onToggleScheduled: controller.toggleScheduledOrder,
          selectedDate: state.checkout?.deliverySlotDate,
          selectedTime: state.checkout?.deliverySlotTime,
          availableTimeSlots: state.availableTimeSlots,
          dateFull: state.dateFull,
          timeFull: state.timeFull,
          onSelectDate: controller.changeSelectedDeliveryDate,
          onSelectTime: controller.changeSelectedDeliveryTime,
          loadingTime: state.loadingTime,
          loadingTables: state.loadingTables,
          tables: state.tables,
          tableSelected: state.tableSelected,
          guestCountController: _guestCountTEC,
          onSelectTable: controller.selectTableSelecte,
        ),
        OrderDeliveryAddressPickerView(
          vendor: vendor,
          isPickup: state.isPickup,
          onTogglePickup: controller.togglePickupStatus,
          onPickAddress: () => controller.pickDeliveryAddress(context),
          deliveryAddress: state.deliveryAddress,
          deliveryAddressOutOfRange: state.deliveryAddressOutOfRange,
        ),
        UiSpacer.verticalSpace(),
        CustomTextFormField(
          labelText: "Note".tr(),
          textEditingController: _noteTEC,
        ),
        UiSpacer.verticalSpace(),
        CustomButton(
          title: "PLACE ORDER REQUEST".tr(),
          loading: state.isBusy,
          onPressed:
              state.prescriptionPhotos.isNotEmpty
                  ? () => controller.placeOrder(
                    context: context,
                    note: _noteTEC.text,
                  )
                  : null,
        ).wFull(context),
      ]).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
    );
  }
}
