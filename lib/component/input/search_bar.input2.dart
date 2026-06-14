import 'package:flutter/material.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/utils/extensions/router.dart';
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
                context.pushRoute('/search', extra: search!);
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
                icon: Icon(Icons.tune, color: Colors.white, size: 20),
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
