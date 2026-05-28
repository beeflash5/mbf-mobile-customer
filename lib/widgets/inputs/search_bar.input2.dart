import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchBarInput2 extends StatelessWidget {
  const SearchBarInput2({
    this.hintText,
    this.onTap,
    this.onFilterPressed,
    this.onSubmitted,
    this.readOnly = true,
    this.showFilter = false,
    this.search,
    this.searchTEC,
    Key? key,
  }) : super(key: key);

  final String? hintText;
  final Function? onTap;
  final Function? onFilterPressed;
  final Function(String)? onSubmitted;
  final bool readOnly;
  final Search? search;
  final bool? showFilter;
  final TextEditingController? searchTEC;
  @override
  Widget build(BuildContext context) {
    final mBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.6, color: Colors.grey.shade600),
      borderRadius: BorderRadius.circular(5),
    );
    return HStack([
      //
      Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffB3D8DE)),
          color: const Color(0xffF3F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: TextFormField(
            onTap: () {
              if (search != null) {
                //pages
                final page = NavigationService().searchPageWidget(search!);
                context.nextPage(page);
              } else if (onTap != null) {
                onTap!();
              }
            },
            controller: searchTEC,
            onFieldSubmitted: onSubmitted,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,

              hintText: "Search experiences, services, or places...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),

              contentPadding: const EdgeInsets.symmetric(vertical: 10),

              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
                size: 20,
              ),

              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
        ),
      ).expand(),

      Visibility(
        visible: showFilter ?? true,
        child: HStack([
          SizedBox(width: 8),
          // UiSpacer.horizontalSpace(),
          //filter icon
          IconButton(
                onPressed: null,
                color: Colors.white,
                icon: Icon(
                  FlutterIcons.sliders_faw,
                  color: Colors.white,
                  size: 20,
                ),
              )
              .onInkTap(
                onFilterPressed != null ? () => onFilterPressed!() : () {},
              )
              .material(color: context.theme.primaryColor)
              .box
              .color(context.theme.primaryColor)
              .outerShadowSm
              .roundedSM
              .clip(Clip.antiAlias)
              .make(),
        ]),
      ),
    ]);
  }
}
