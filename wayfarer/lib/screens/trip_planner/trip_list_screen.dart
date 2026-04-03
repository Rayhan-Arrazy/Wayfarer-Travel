import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';
import '../../widgets/wayfarer_app_bar.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().getTrips();
      final List data = response.data;
      setState(() {
        _trips = data.map((t) => TripModel.fromJson(t)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _trips = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: WayfarerAppBar(showMenu: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WORKSPACE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Trip Planning Hub', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 24),
            
            // New Journey Button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text('New Journey', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF475569),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Shortcut Cards
            _buildShortcutCard(
              icon: Icons.gesture,
              title: 'Itinerary Maker',
              subtitle: 'Map out your daily activities',
              onTap: () => Navigator.pushNamed(context, '/itinerary'),
            ),
            const SizedBox(height: 16),
            _buildShortcutCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budgeter',
              subtitle: 'Track expenses and savings',
              onTap: () => Navigator.pushNamed(context, '/budgeter'),
            ),
            
            const SizedBox(height: 48),
            
            // Section Header
            Row(
              children: [
                const Icon(Icons.flight_takeoff, color: Color(0xFF1E2E46), size: 24),
                const SizedBox(width: 12),
                Text('Active & Upcoming Trips', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Trip List
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_trips.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No trips found', style: GoogleFonts.inter(color: Colors.grey[400])),
                    ],
                  ),
                ),
              )
            else
              ..._trips.map((trip) => _buildTripListItem(trip)),
            
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF1E40AF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripListItem(TripModel trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.destination, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(trip.startDate)} — ${_formatDate(trip.endDate)}',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/trips/edit', arguments: trip),
                icon: const Icon(Icons.edit, color: Color(0xFF475569), size: 22),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Color(0xFF475569), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
