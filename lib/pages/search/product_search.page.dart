import 'package:flutter/material.dart';

import 'package:fuodz/models/search.dart';
import 'package:fuodz/pages/search/search.page.dart';

class ProductSearchPage extends StatelessWidget {
  const ProductSearchPage({
    super.key,
    required this.search,
    this.showCancel = true,
  });

  final Search search;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return SearchPage(search: search, showCancel: showCancel);
  }
}
