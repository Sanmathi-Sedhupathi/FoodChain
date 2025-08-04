import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../donor/donor_dashboard.dart';
import '../receiver/receiver_dashboard.dart';
import '../driver/driver_dashboard.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUserModel;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<Widget> screens = _getScreensForRole(user.role);
        final List<BottomNavigationBarItem> navItems = _getNavItemsForRole(user.role);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            items: navItems,
          ),
        );
      },
    );
  }

  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return [
          const DonorDashboard(),
          const ProfileScreen(),
        ];
      case UserRole.receiver:
        return [
          const ReceiverDashboard(),
          const ProfileScreen(),
        ];
      case UserRole.driver:
        return [
          const DriverDashboard(),
          const ProfileScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'My Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case UserRole.receiver:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case UserRole.driver:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }
}