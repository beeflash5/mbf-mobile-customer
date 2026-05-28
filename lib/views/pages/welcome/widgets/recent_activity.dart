import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/order.dart';
import 'package:dartx/dartx.dart';

class RecentActivityHorizontal extends StatelessWidget {
  final List<Order> orders;

  const RecentActivityHorizontal({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final order = orders[index];

          return InkWell(
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.orderDetailsRoute, arguments: order);
            },
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // 🔹 Icon status
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _statusIcon(order.status),
                      size: 18,
                      color: _statusColor(order.status),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🔹 Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          order.vendor?.name ?? "Order",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.status.capitalize(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 🔹 Time
                  Text(
                    order.formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 icon mapping
  IconData _statusIcon(String status) {
    switch (status) {
      case "pending":
        return Icons.access_time;
      case "preparing":
        return Icons.inventory_2_outlined;
      case "enroute":
        return Icons.local_shipping;
      case "delivered":
      case "completed":
        return Icons.check_circle_outline;
      case "cancelled":
      case "failed":
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  // 🔥 color mapping
  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "preparing":
        return Colors.blue;
      case "enroute":
        return Colors.purple;
      case "delivered":
      case "completed":
        return Colors.green;
      case "cancelled":
      case "failed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
