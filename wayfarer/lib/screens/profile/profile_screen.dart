import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String _selectedCurrency = 'USD';
  bool _isEditing = false;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'IDR', 'SGD', 'AUD', 'CAD', 'CHF', 'CNY', 'KRW', 'THB', 'MYR'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _selectedCurrency = user.homeCurrency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final bool isGuest = !auth.isAuthenticated;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          if (!isGuest)
            TextButton(
              onPressed: () async {
                if (_isEditing) {
                  await auth.updateProfile({
                    'name': _nameController.text.trim(),
                    'homeCurrency': _selectedCurrency,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.successColor),
                    );
                  }
                }
                setState(() => _isEditing = !_isEditing);
              },
              child: Text(_isEditing ? 'Save' : 'Edit',
                style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: isGuest
          ? _buildGuestState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12)],
                      ),
                      child: Center(
                        child: Text((user?.name ?? 'U')[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Personal Info', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person, color: AppTheme.textMuted)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    enabled: false,
                    style: const TextStyle(color: AppTheme.textMuted),
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email, color: AppTheme.textMuted)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    dropdownColor: AppTheme.lightSurface,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Home Currency', prefixIcon: Icon(Icons.currency_exchange, color: AppTheme.textMuted)),
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: _isEditing ? (v) => setState(() => _selectedCurrency = v ?? 'USD') : null,
                  ),

                  const SizedBox(height: 28),

                  if (user?.role == 'admin') ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 28),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(AppConstants.adminUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: Text('Launch Control Center', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],

                  // Emergency Contacts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Emergency Contacts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      if (_isEditing)
                        IconButton(
                          onPressed: _addEmergencyContact,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (user?.emergencyContacts.isEmpty ?? true)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.lightCard, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text('No emergency contacts added', style: GoogleFonts.inter(color: AppTheme.textMuted))),
                    )
                  else
                    ...user!.emergencyContacts.map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.lightBorder),
                          ),
                          child: Row(children: [
                            const Icon(Icons.contact_emergency, color: AppTheme.errorColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              Text(c.phone, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                              if (c.relationship.isNotEmpty) Text(c.relationship, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                            ])),
                          ]),
                        )),
                      ],
                    ),
                  ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline_rounded, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Welcome, Traveler', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Log in to unlock your profile, manage\npreferences, and sync your journeys.', 
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 0,
            ),
            child: const Text('Log In / Register'),
          ),
          const SizedBox(height: 12),
          TextButton(
             onPressed: () => Navigator.pop(context),
             child: Text('Return to Explore', style: GoogleFonts.inter(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _addEmergencyContact() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.lightCard,
        title: Text('Add Emergency Contact', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _contactNameController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person, color: AppTheme.textMuted, size: 20)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone, color: AppTheme.textMuted, size: 20)),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final contacts = auth.user?.emergencyContacts.map((c) => c.toJson()).toList() ?? [];
              contacts.add({'name': _contactNameController.text, 'phone': _contactPhoneController.text, 'relationship': ''});
              await auth.updateProfile({'emergencyContacts': contacts});
              _contactNameController.clear();
              _contactPhoneController.clear();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
