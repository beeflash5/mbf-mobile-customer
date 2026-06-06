import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/models/blog.dart';
import 'package:fuodz/pages/welcome/widgets/blog_detail_page.dart';
import 'package:fuodz/component/button/custom_button_light.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

class TravelNewsPage extends StatelessWidget {
  const TravelNewsPage({
    super.key,
    required this.blogs,
    required this.hasMore,
    required this.onLoadMore,
    required this.loading,
  });

  final List<Blog> blogs;
  final bool hasMore;
  final bool loading;
  final Function onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        const Text(
          "Travel News and Views",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ).px(20),

        const SizedBox(height: 8),

        const Text(
          "Stay in the loop with the latest news.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ).px(20),

        const SizedBox(height: 10),

        /// BLOG LIST
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            final blog = blogs[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: BlogCard(blog: blog),
            );
          },
        ),

        /// VIEW MORE
        if (hasMore)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: CustomButtonLight(
                loading: loading,
                title: "View More..".tr(),
                onPressed: () => onLoadMore(),
              ),
            ),

            // TextButton(
            //   onPressed: () => onLoadMore(),
            //   child: const Text(
            //     "View More",
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //   ),
            // ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class BlogCard extends StatelessWidget {
  const BlogCard({super.key, required this.blog});

  final Blog blog;

  String stripHtml(String htmlText) {
    final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '');
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final cleanText = stripHtml(blog.description);

    return InkWell(
      onTap: () {
        context.pushWidget(BlogDetailPage(blog: blog));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(1, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE + DATE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    blog.photo,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Positioned(
                //   left: 16,
                //   bottom: 16,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 10,
                //       vertical: 4,
                //     ),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.6),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Text(
                //       formatDate(blog.created_at),
                //       style: const TextStyle(color: Colors.white, fontSize: 12),
                //     ),
                //   ),
                // ),
              ],
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(
                          text:
                              cleanText.length > 100
                                  ? cleanText.substring(0, 100)
                                  : cleanText,
                        ),

                        if (cleanText.length > 100)
                          TextSpan(
                            text: " read more...",
                            style: TextStyle(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
