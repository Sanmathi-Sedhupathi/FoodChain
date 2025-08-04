import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart'; // Make sure this path matches where UserRole is defined

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUserModel;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Information
                Card(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.phone,
                        title: 'Phone',
                        subtitle: user.phone,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.location_on,
                        title: 'Address',
                        subtitle: user.address ?? 'Not provided',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.calendar_today,
                        title: 'Member Since',
                        subtitle: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to edit profile
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history, color: AppTheme.primaryColor),
                        title: const Text('Activity History'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to activity history
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to settings
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final shouldSignOut = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                              ),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );

                      if (shouldSignOut == true) {
                        await authService.signOut();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Food Donor';
      case UserRole.receiver:
        return 'Food Receiver';
      case UserRole.driver:
        return 'Delivery Driver';
    }
  }
}