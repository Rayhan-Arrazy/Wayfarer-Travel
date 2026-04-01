import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';
import '../../config/routes.dart';
import '../../widgets/loading_widget.dart';

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final auth = context.watch<AuthProvider>();
    final trips = tripProvider.trips;

    if (tripProvider.isLoading) return const LoadingWidget();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(auth.user?.avatar ?? 'https://i.pravatar.cc/150?u=alex'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WORKSPACE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Text('Trip Planning Hub', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
            const SizedBox(height: 24),
            
            _buildNewJourneyButton(context),
            
            const SizedBox(height: 48),
            Row(
              children: [
                const Icon(Icons.airplanemode_active, color: Color(0xFF1D4E89), size: 20),
                const SizedBox(width: 12),
                Text('Active & Upcoming Trips', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
              ],
            ),
            const SizedBox(height: 24),
            
            if (trips.isEmpty)
              _buildEmptyTrips()
            else
              ...trips.map((trip) => _buildTripCard(context, trip)),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNewJourneyButton(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Journey', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6083),
          elevation: 4,
          shadowColor: const Color(0xFF1E2E46).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    String dateRange = "${DateFormat('MMM d').format(trip.startDate)} — ${DateFormat('MMM d, y').format(trip.endDate)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
                Text(trip.destination, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(dateRange, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editTrip, arguments: trip),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, trip.id),
            icon: const Icon(Icons.delete_outline, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrips() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No trips planned yet', style: GoogleFonts.inter(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip?'),
        content: const Text('This action will permanently remove this trip and its itinerary.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final provider = context.read<TripProvider>();
      await provider.deleteTrip(id);
    }
  }
}
