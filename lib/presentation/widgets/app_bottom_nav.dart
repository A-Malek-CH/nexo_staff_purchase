import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../providers/task_provider.dart';
import '../providers/transfer_provider.dart';
import '../providers/order_provider.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final tasksState = ref.watch(tasksProvider);
    final transfersState = ref.watch(transfersProvider);
    final ordersState = ref.watch(ordersProvider);

    final pendingCount = tasksState.tasks
            .where((t) =>
                t.status == AppConstants.taskStatusPending ||
                t.status == AppConstants.taskStatusInProgress)
            .length +
        transfersState.pendingTransfers.length +
        ordersState.orders
            .where((o) => o.status == AppConstants.orderStatusAssigned)
            .length;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/quick-access');
            break;
          case 2:
            context.go('/tasks');
            break;
          case 3:
            context.go('/orders');
            break;
          case 4:
            context.go('/transfers');
            break;
          case 5:
            context.go('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryOrange,
      unselectedItemColor: AppTheme.mediumGrey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
        BottomNavigationBarItem(
          icon: _QuickAccessIcon(pendingCount: pendingCount),
          activeIcon: _QuickAccessIcon(pendingCount: pendingCount, active: true),
          label: l10n.quickAccess,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          activeIcon: const Icon(Icons.assignment),
          label: l10n.tasks,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart_outlined),
          activeIcon: const Icon(Icons.shopping_cart),
          label: l10n.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.swap_horiz_outlined),
          activeIcon: const Icon(Icons.swap_horiz),
          label: l10n.transfers,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outlined),
          activeIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}

class _QuickAccessIcon extends StatelessWidget {
  final int pendingCount;
  final bool active;

  const _QuickAccessIcon({required this.pendingCount, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.flash_on : Icons.flash_on_outlined),
        if (pendingCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.errorRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                pendingCount > 99 ? '99+' : pendingCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
