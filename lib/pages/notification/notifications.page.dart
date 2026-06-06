import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/providers/notifications_providers.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    NotificationModel n,
  ) async {
    await ref.read(notificationsControllerProvider.notifier).markRead(n);
    if (!context.mounted) return;
    await context.pushRoute(
      AppRoutes.notificationDetailsRoute,
      extra: n,
    );
    await ref.read(notificationsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(notificationsControllerProvider);
    final notifications = asyncList.valueOrNull ?? const [];
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Notifications'.tr(),
      body: SafeArea(
        child: CustomListView(
          dataSet: notifications,
          isLoading: asyncList.isLoading,
          emptyWidget: EmptyState(
            title: 'No Notifications'.tr(),
            description:
                "You dont' have notifications yet. When you get notifications, they will appear here"
                    .tr(),
          ),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return VStack([
              '${notification.title}'
                  .text
                  .bold
                  .fontFamily(GoogleFonts.nunito().fontFamily!)
                  .make(),
              notification.formattedTimeStamp.text.medium
                  .color(Colors.grey)
                  .fontFamily(GoogleFonts.nunito().fontFamily!)
                  .make()
                  .pOnly(bottom: 5),
              '${notification.body}'
                  .text
                  .maxLines(1)
                  .overflow(TextOverflow.ellipsis)
                  .fontFamily(GoogleFonts.nunito().fontFamily!)
                  .make(),
            ])
                .px20()
                .py12()
                .box
                .color((notification.read ?? false)
                    ? Theme.of(context).cardColor
                    : Theme.of(context).canvasColor)
                .make()
                .onInkTap(() => _open(context, ref, notification));
          },
          separatorBuilder: (context, index) => UiSpacer.divider(),
        ),
      ),
    );
  }
}
