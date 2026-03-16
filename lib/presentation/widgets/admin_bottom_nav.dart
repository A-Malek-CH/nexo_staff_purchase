import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/admin/dashboard');
            break;
          case 1:
            context.go('/admin/orders');
            break;
          case 2:
            context.go('/admin/staff');
            break;
          case 3:
            context.go('/admin/suppliers');
            break;
          case 4:
            context.go('/admin/products');
            break;
          case 5:
            context.go('/admin/analytics');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryOrange,
      unselectedItemColor: AppTheme.mediumGrey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: 'Staff',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_outlined),
          activeIcon: Icon(Icons.business),
          label: 'Suppliers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
      ],
    );
  }
}
