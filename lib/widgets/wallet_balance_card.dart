import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key, required this.vm});
  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 248, 253, 228), Color(0xFFE8F0F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Wallet Balance".tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    "${AppStrings.currencySymbol} ${vm.wallet?.balance ?? 0.00}"
                        .currencyFormat(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F6E8C),
                    ),
                  ),
                ],
              ),

              Spacer(),
              Row(
                children: [
                  WalletMenuItem(
                    icon: AppImages.ring,
                    label: "Top Up".tr(),
                    color: Color(0xFF1F6E8C),
                    onTap: () {
                      !vm.isAuthenticated()
                          ? vm.openLogin()
                          : vm.showAmountEntry();
                    },
                  ),
                  SizedBox(width: 10),
                  WalletMenuItem(
                    icon: AppImages.print,
                    label: "Orders".tr(),
                    color: Colors.orange,
                    onTap: () {
                      AppService().changeHomePageIndex(index: 1);
                    },
                  ),
                  SizedBox(width: 10),
                  WalletMenuItem(
                    icon: AppImages.other,
                    label: "Other".tr(),
                    color: Colors.green,
                    onTap: () {
                      AppService().changeHomePageIndex(index: 3);
                    },
                  ),
                ],
              ),
            ],
          ),
          // const SizedBox(height: 24),

          /// MENU BUTTONS
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: const [
          //     WalletMenuItem(
          //       icon: Icons.add_circle_outline,
          //       label: "Topup",
          //       color: Color(0xFF1F6E8C),
          //     ),
          //     WalletMenuItem(
          //       icon: Icons.receipt_long_outlined,
          //       label: "Orders",
          //       color: Colors.orange,
          //     ),
          //     WalletMenuItem(
          //       icon: Icons.grid_view_rounded,
          //       label: "Other",
          //       color: Colors.green,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class WalletMenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final Function() onTap;

  const WalletMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Image.asset(icon, width: 28, height: 28),
            // child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
