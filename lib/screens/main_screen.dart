import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_state_provider.dart';
import '../widgets/responsive_layout.dart';
import 'warehouse_screen.dart';
import 'auto_purchase_screen.dart';
import 'debts_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WarehouseScreen(),
    AutoPurchaseScreen(),
    DebtsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final criticalCount = appState.criticalProducts.length;
    final isWideScreen = !ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Column(
          children: [
            // Верхний индикатор статуса сети (Онлайн / Офлайн)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFF0F172A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appState.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appState.isOnline ? appState.tr('online') : appState.tr('offline'),
                        style: TextStyle(
                          color: appState.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SmartSklad B2B • ${appState.userProfile.role.shortCode}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Основная область с адаптацией под десктоп/планшет
            Expanded(
              child: isWideScreen
                  ? Row(
                      children: [
                        // Боковое меню NavigationRail для планшетов и ПК
                        NavigationRail(
                          backgroundColor: const Color(0xFF0F172A),
                          selectedIndex: _currentIndex,
                          onDestinationSelected: (index) => setState(() => _currentIndex = index),
                          extended: ResponsiveLayout.isDesktop(context),
                          selectedIconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
                          selectedLabelTextStyle: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold),
                          unselectedIconTheme: const IconThemeData(color: Colors.white54),
                          unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
                          destinations: [
                            NavigationRailDestination(
                              icon: const Icon(Icons.inventory_2_outlined),
                              selectedIcon: const Icon(Icons.inventory_2),
                              label: Text(appState.tr('warehouse')),
                            ),
                            NavigationRailDestination(
                              icon: Badge(
                                isLabelVisible: criticalCount > 0,
                                label: Text('$criticalCount'),
                                child: const Icon(Icons.shopping_cart_outlined),
                              ),
                              selectedIcon: Badge(
                                isLabelVisible: criticalCount > 0,
                                label: Text('$criticalCount'),
                                child: const Icon(Icons.shopping_cart),
                              ),
                              label: Text(appState.tr('auto_purchase')),
                            ),
                            NavigationRailDestination(
                              icon: Badge(
                                isLabelVisible: appState.receivables.isNotEmpty,
                                label: Text('${appState.receivables.length}'),
                                child: const Icon(Icons.account_balance_wallet_outlined),
                              ),
                              selectedIcon: const Icon(Icons.account_balance_wallet),
                              label: Text(appState.tr('debts')),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.person_outline),
                              selectedIcon: const Icon(Icons.person),
                              label: Text(appState.tr('profile')),
                            ),
                          ],
                        ),
                        const VerticalDivider(width: 1, color: Colors.white12),

                        // Центральная контентная часть для ПК
                        Expanded(
                          child: ResponsiveCenterView(
                            maxWidth: 1200,
                            child: IndexedStack(
                              index: _currentIndex,
                              children: _screens,
                            ),
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF0F172A),
              selectedItemColor: const Color(0xFF3B82F6),
              unselectedItemColor: Colors.white54,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.inventory_2_outlined),
                  activeIcon: const Icon(Icons.inventory_2),
                  label: appState.tr('warehouse'),
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: criticalCount > 0,
                    label: Text('$criticalCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: criticalCount > 0,
                    label: Text('$criticalCount'),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: appState.tr('auto_purchase'),
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: appState.receivables.isNotEmpty,
                    label: Text('${appState.receivables.length}'),
                    child: const Icon(Icons.account_balance_wallet_outlined),
                  ),
                  activeIcon: const Icon(Icons.account_balance_wallet),
                  label: appState.tr('debts'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: appState.tr('profile'),
                ),
              ],
            ),
    );
  }
}
