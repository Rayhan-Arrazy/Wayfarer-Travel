import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTracking = true;
  bool _offlineMaps = false;
  String _distanceUnit = 'km';
  String _tempUnit = '°C';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: auth.user?.email ?? '',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _showChangePasswordDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.currency_exchange,
            title: 'Home Currency',
            subtitle: auth.user?.homeCurrency ?? 'USD',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(auth.user?.homeCurrency ?? 'USD', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primaryColor, fontSize: 13)),
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Trip reminders & alerts',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Location Tracking',
            subtitle: 'Enable for weather & nearby features',
            value: _locationTracking,
            onChanged: (v) => setState(() => _locationTracking = v),
          ),
          _buildSwitchTile(
            icon: Icons.download_outlined,
            title: 'Offline Maps',
            subtitle: 'Download maps for offline use',
            value: _offlineMaps,
            onChanged: (v) => setState(() => _offlineMaps = v),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Units'),
          _buildRadioTile(
            icon: Icons.straighten,
            title: 'Distance',
            options: ['km', 'miles'],
            selected: _distanceUnit,
            onChanged: (v) => setState(() => _distanceUnit = v),
          ),
          _buildRadioTile(
            icon: Icons.thermostat,
            title: 'Temperature',
            options: ['°C', '°F'],
            selected: _tempUnit,
            onChanged: (v) => setState(() => _tempUnit = v),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danger Zone', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.errorColor)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Sign Out?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                auth.logout();
                                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.lightSurface, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20) : null),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.lightSurface, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required IconData icon,
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.lightSurface, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(opt, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppTheme.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_reset)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService().changePassword(currentPwController.text, newPwController.text);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated! ✅'), backgroundColor: AppTheme.successColor),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
