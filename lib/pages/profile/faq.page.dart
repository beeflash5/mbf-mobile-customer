import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/constants/api.dart';

class Faq {
  Faq({
    required this.id,
    required this.title,
    required this.body,
  });

  int id;
  String title;
  String body;

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
        id: json["id"],
        title: json["title"] ?? "",
        body: json["body"] ?? "",
      );
}

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  int? openedFaq;
  late Future<List<Faq>> _faqsFuture;

  @override
  void initState() {
    super.initState();
    _faqsFuture = fetchFaqs();
  }

  Future<List<Faq>> fetchFaqs() async {
    List<Faq> result = [];
    HttpClient httpClient = HttpClient();

    try {
      var url = Uri.parse(Api.baseUrl + Api.faqs);
      HttpClientRequest request = await httpClient.getUrl(url);
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == HttpStatus.ok) {
        final faqsJsonArray = jsonDecode(responseBody);
        result = (faqsJsonArray as List).map((e) => Faq.fromJson(e)).toList();
      } else {
        throw responseBody;
      }
    } catch (error) {
      if (kDebugMode) {
        print("error ==> $error");
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "FAQ".tr(),
      showLeadingAction: true,
      body: FutureBuilder<List<Faq>>(
        future: _faqsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Faq>> snapshot) {
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()).p20();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching FAQs".tr())).p20();
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                final faq = snapshot.data![index];
                final textColor = Theme.of(context).textTheme.bodyMedium?.color;

                return ListTile(
                  title: Text(
                    faq.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  subtitle: (openedFaq == index)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: HtmlWidget(
                            faq.body,
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            customStylesBuilder: (element) {
                              return {'color': 'inherit'};
                            },
                          ),
                        )
                      : null,
                  trailing: Icon(
                    (openedFaq != index) ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 18,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  dense: true,
                  isThreeLine: false,
                  onTap: () {
                    setState(() {
                      openedFaq = (openedFaq == index) ? null : index;
                    });
                  },
                );
              },
              separatorBuilder: (ctx, index) => const Divider(height: 1),
            );
          }
        },
      ),
    );
  }
}
