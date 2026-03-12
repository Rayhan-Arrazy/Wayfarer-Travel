import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  Map<String, dynamic> _dashboard = {};
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dashRes = await _api.getAdminDashboard();
      final usersRes = await _api.getAdminUsers();
      setState(() {
        _dashboard = dashRes.data;
        _users = usersRes.data['users'] ?? [];
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Admin Panel', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.warningColor,
          labelColor: AppTheme.warningColor,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Dashboard'), Tab(text: 'Users')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.warningColor))
          : TabBarView(controller: _tabController, children: [_buildDashboard(), _buildUsers()]),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Row(children: [
            _stat('👥', 'Total Users', '${_dashboard['totalUsers'] ?? 0}', AppTheme.primaryColor),
            const SizedBox(width: 12),
            _stat('✈️', 'Total Trips', '${_dashboard['totalTrips'] ?? 0}', AppTheme.accentColor),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _stat('✅', 'Active Users', '${_dashboard['activeUsers'] ?? 0}', AppTheme.successColor),
            const SizedBox(width: 12),
            _stat('📝', 'Journal Entries', '${_dashboard['totalJournalEntries'] ?? 0}', const Color(0xFFE57373)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _stat('🆕', 'New This Week', '${_dashboard['newUsersThisWeek'] ?? 0}', AppTheme.warningColor),
            const SizedBox(width: 12),
            _stat('🌍', 'Active Trips', '${_dashboard['activeTrips'] ?? 0}', const Color(0xFFBA68C8)),
          ]),
          const SizedBox(height: 24),
          Text('Top Destinations', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...(_dashboard['topDestinations'] as List? ?? []).take(5).map<Widget>((d) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.lightCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.lightBorder)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d['destination'] ?? d['_id'] ?? '', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${d['count']} trips', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.lightCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildUsers() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          final isActive = u['isActive'] ?? true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.lightCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.lightBorder)),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Text((u['name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(u['name'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(width: 6),
                  if (u['role'] == 'admin')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: AppTheme.warningColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text('ADMIN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.warningColor)),
                    ),
                ]),
                Text(u['email'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ])),
              Switch(
                value: isActive,
                activeColor: AppTheme.successColor,
                onChanged: (val) async {
                  try {
                    await _api.updateAdminUser(u['_id'], {'isActive': val});
                    _loadData();
                  } catch (e) { /* handle */ }
                },
              ),
            ]),
          );
        },
      ),
    );
  }
}
