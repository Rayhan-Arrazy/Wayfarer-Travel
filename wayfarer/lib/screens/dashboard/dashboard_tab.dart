import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/journal_provider.dart';
import '../../config/routes.dart';
import '../../models/trip_model.dart';
import '../../models/journal_model.dart';
import '../../widgets/loading_widget.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchTrips();
      context.read<JournalProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tp = context.watch<TripProvider>();
    final jp = context.watch<JournalProvider>();

    if (tp.isLoading || jp.isLoading) {
      return const LoadingWidget();
    }

    final activeTrip = tp.upcomingTrip;
    final recentMemory = jp.entries.isNotEmpty ? jp.entries.first : null;
    final userName = auth.user?.name.split(' ').first ?? 'Elias';
    final dateStr = DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
                      ),
                      Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(dateStr, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text('Welcome back, $userName.', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Essential Helpers', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      TextButton(onPressed: () {}, child: Text('Manage Tools', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHelperCard('Converter', 'Live rates for EUR, USD...', Icons.sync),
                      const SizedBox(width: 16),
                      _buildHelperCard('Guide', 'Cultural etiquette phrases...', Icons.menu_book),
                    ],
                  ),

                  const SizedBox(height: 40),

                  if (activeTrip != null) ...[
                    _buildCurrentItinerary(activeTrip),
                    const SizedBox(height: 40),
                  ] else ...[
                     _buildEmptyItinerary(),
                     const SizedBox(height: 40),
                  ],

                  if (recentMemory != null) ...[
                    _buildRecentMemory(recentMemory),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Floating Action Button
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.journalAdd),
                backgroundColor: const Color(0xFF0F4C81),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperCard(String title, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF132F5C), size: 24),
            ),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentItinerary(TripModel trip) {
    final activity = trip.itinerary.isNotEmpty ? trip.itinerary.first : null;
    final dateRange = '${DateFormat('MMM d').format(trip.startDate).toUpperCase()} — ${DateFormat('MMM d').format(trip.endDate).toUpperCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Itinerary', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
              child: Text('ACTIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF132F5C), letterSpacing: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateRange, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Text(trip.destination, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              if (activity != null) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: Color(0xFF132F5C)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(activity.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ),
                    Text('Today', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 4),
                  child: Text(activity.time, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF132F5C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('View Itinerary', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyItinerary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Itinerary', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
          child: Column(
            children: [
              Icon(Icons.event_note, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No active itinerary found.', style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMemory(JournalEntryModel memory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Memory', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.journalAdd), 
              icon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF132F5C)), 
              label: Text('Write', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C)))
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${memory.note.length > 150 ? '${memory.note.substring(0, 147)}...' : memory.note}"',
                style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF475569), height: 1.6, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(memory.location?.name ?? 'Pico do Arieiro', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.journal), 
                    child: Text('View in Journal', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C)))
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
