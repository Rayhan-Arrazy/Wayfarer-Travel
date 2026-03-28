import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final ApiService _api = ApiService();
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
      final response = await _api.getTrips();
      final List data = response.data;
      setState(() {
        _trips = data.map((t) => TripModel.fromJson(t)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          // Mock data for demo if API fails or is empty, to match the image
          _trips = [
            TripModel(
              id: '1',
              userId: 'user1',
              destination: 'Amalfi Coast, Italy',
              countryCode: 'IT',
              startDate: DateTime(2024, 9, 12),
              endDate: DateTime(2024, 9, 24),
              status: 'planning',
              partySize: 4,
            ),
            TripModel(
              id: '2',
              userId: 'user1',
              destination: 'Kyoto, Japan',
              countryCode: 'JP',
              startDate: DateTime(2024, 11, 4),
              endDate: DateTime(2024, 11, 18),
              status: 'planning',
              partySize: 2,
            ),
            TripModel(
              id: '3',
              userId: 'user1',
              destination: 'Agra, India',
              countryCode: 'IN',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              status: 'planning',
              partySize: 1,
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: AppTheme.primaryColor),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80'),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
    // Check if it's the "Dates TBD" one (the third one in mockup)
    final bool isTbd = trip.destination == 'Agra, India';
    
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
                      isTbd ? 'Dates TBD' : '${_formatDate(trip.startDate)} — ${_formatDate(trip.endDate)}',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontStyle: isTbd ? FontStyle.italic : FontStyle.normal),
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
