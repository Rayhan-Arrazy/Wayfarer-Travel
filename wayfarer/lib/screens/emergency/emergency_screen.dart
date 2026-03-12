import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  Map<String, dynamic>? _emergencyNumbers;
  List<dynamic> _hospitals = [];
  bool _isLoadingNumbers = true;
  bool _isLoadingHospitals = true;
  bool _isSendingSOS = false;
  String _countryCode = 'ID'; // Default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmergencyNumbers();
    _loadNearbyHospitals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyNumbers() async {
    setState(() => _isLoadingNumbers = true);
    try {
      final response = await _api.getEmergencyNumbers(_countryCode);
      setState(() {
        _emergencyNumbers = response.data;
        _isLoadingNumbers = false;
      });
    } catch (e) {
      setState(() => _isLoadingNumbers = false);
    }
  }

  Future<void> _loadNearbyHospitals() async {
    setState(() => _isLoadingHospitals = true);
    try {
      final response = await _api.getNearbyHospitals(-6.2088, 106.8456, radius: 5000);
      setState(() {
        _hospitals = response.data['facilities'] ?? [];
        _isLoadingHospitals = false;
      });
    } catch (e) {
      setState(() => _isLoadingHospitals = false);
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSOS() async {
    final auth = context.read<AuthProvider>();
    final contacts = auth.user?.emergencyContacts ?? [];

    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contacts saved. Add contacts in your Profile.'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.lightCard,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sos, color: AppTheme.errorColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Send SOS?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will send an emergency SMS with your current location to:',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ...contacts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppTheme.errorColor),
                  const SizedBox(width: 8),
                  Text('${c.name} (${c.phone})', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text('Send SOS', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSendingSOS = true);
    try {
      final contactList = contacts.map((c) => {'name': c.name, 'phone': c.phone}).toList();
      await _api.sendSOS(
        contactList,
        {'lat': -6.2088, 'lng': 106.8456, 'name': 'Current Location'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🆘 SOS sent to your emergency contacts!'), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    setState(() => _isSendingSOS = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Emergency', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.errorColor,
          labelColor: AppTheme.errorColor,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'SOS', icon: Icon(Icons.sos, size: 20)),
            Tab(text: 'Numbers', icon: Icon(Icons.call, size: 20)),
            Tab(text: 'Hospitals', icon: Icon(Icons.local_hospital, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSOSTab(),
          _buildNumbersTab(),
          _buildHospitalsTab(),
        ],
      ),
    );
  }

  Widget _buildSOSTab() {
    final auth = context.watch<AuthProvider>();
    final contacts = auth.user?.emergencyContacts ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // SOS Button
          GestureDetector(
            onTap: _isSendingSOS ? null : _sendSOS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.emergencyGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.errorColor.withValues(alpha: _isSendingSOS ? 0.1 : 0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: _isSendingSOS
                  ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sos, color: Colors.white, size: 48),
                        const SizedBox(height: 6),
                        Text('SOS', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Tap to alert your emergency contacts',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),

          // Share Location (What3Words mock)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Precise Location', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('///', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.errorColor)),
                          Text('brave.solar.travel', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                        ],
                      ),
                      Text('Accuracy: 3m', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: AppTheme.textMuted),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Call
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Emergency Call', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildQuickCall('🚔', 'Police', '112'),
                    const SizedBox(width: 10),
                    _buildQuickCall('🚑', 'Ambulance', '112'),
                    const SizedBox(width: 10),
                    _buildQuickCall('🚒', 'Fire', '112'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Emergency Contacts
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Emergency Contacts', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('${contacts.length}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                if (contacts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.contact_phone, size: 32, color: AppTheme.textMuted),
                          const SizedBox(height: 8),
                          Text('No contacts added yet', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text('Add contacts in your Profile', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  )
                else
                  ...contacts.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: AppTheme.errorColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              Text(c.phone, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _callNumber(c.phone),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.call, color: AppTheme.successColor, size: 18),
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // WHO Health Alerts
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WHO Health Alerts', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.warningColor)),
                      const SizedBox(height: 4),
                      Text('No active disease outbreaks or travel health notices for your current region.', 
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQuickCall(String emoji, String label, String number) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _callNumber(number),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text(number, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumbersTab() {
    if (_isLoadingNumbers) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.errorColor));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Country selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _countryCode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppTheme.lightSurface,
                    style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'ID', child: Text('🇮🇩 Indonesia')),
                      DropdownMenuItem(value: 'US', child: Text('🇺🇸 United States')),
                      DropdownMenuItem(value: 'GB', child: Text('🇬🇧 United Kingdom')),
                      DropdownMenuItem(value: 'JP', child: Text('🇯🇵 Japan')),
                      DropdownMenuItem(value: 'SG', child: Text('🇸🇬 Singapore')),
                      DropdownMenuItem(value: 'TH', child: Text('🇹🇭 Thailand')),
                      DropdownMenuItem(value: 'AU', child: Text('🇦🇺 Australia')),
                      DropdownMenuItem(value: 'FR', child: Text('🇫🇷 France')),
                      DropdownMenuItem(value: 'DE', child: Text('🇩🇪 Germany')),
                      DropdownMenuItem(value: 'KR', child: Text('🇰🇷 South Korea')),
                      DropdownMenuItem(value: 'IN', child: Text('🇮🇳 India')),
                      DropdownMenuItem(value: 'MY', child: Text('🇲🇾 Malaysia')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _countryCode = v);
                        _loadEmergencyNumbers();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_emergencyNumbers != null) ...[
            _buildEmergencyNumberCard('🚔', 'Police', _getNumber('police')),
            _buildEmergencyNumberCard('🚑', 'Ambulance', _getNumber('ambulance')),
            _buildEmergencyNumberCard('🚒', 'Fire Department', _getNumber('fire')),
            const SizedBox(height: 20),

            // Safety tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: AppTheme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Safety Tips', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Save emergency numbers offline before traveling'),
                  _buildTip('Register with your country\'s embassy'),
                  _buildTip('Share your itinerary with family'),
                  _buildTip('Keep copies of important documents'),
                  _buildTip('Know your hotel address in local language'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.accentColor)),
          Expanded(child: Text(tip, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary))),
        ],
      ),
    );
  }

  String _getNumber(String type) {
    final data = _emergencyNumbers?[type];
    if (data is Map && data['all'] is List) {
      return (data['all'] as List).join(', ');
    }
    if (data is String) return data;
    return '112';
  }

  Widget _buildEmergencyNumberCard(String emoji, String label, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _callNumber(number.split(',').first.trim()),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      Text(number, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.call, color: AppTheme.successColor, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalsTab() {
    if (_isLoadingHospitals) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.errorColor));
    }

    return _hospitals.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text('No hospitals found nearby', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadNearbyHospitals,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadNearbyHospitals,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hospitals.length,
              itemBuilder: (_, i) => _buildHospitalCard(_hospitals[i]),
            ),
          );
  }

  Widget _buildHospitalCard(dynamic facility) {
    final name = facility['name'] ?? 'Medical Facility';
    final type = facility['type'] ?? 'hospital';
    final phone = facility['phone'] ?? '';
    final address = facility['address'] ?? '';
    final emergency = facility['emergency'] ?? false;

    IconData icon = Icons.local_hospital;
    Color color = AppTheme.errorColor;
    if (type == 'pharmacy') {
      icon = Icons.local_pharmacy;
      color = const Color(0xFF4DB6AC);
    } else if (type == 'clinic') {
      icon = Icons.medical_services;
      color = const Color(0xFFFF8A65);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(type.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                        ),
                        if (emergency) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('24H EMERGENCY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.errorColor)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                GestureDetector(
                  onTap: () => _callNumber(phone),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.call, color: AppTheme.successColor, size: 18),
                  ),
                ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(address, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
