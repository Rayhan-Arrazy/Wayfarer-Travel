import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';
import 'activity_form_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final String? tripId;
  const ItineraryScreen({super.key, this.tripId});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TripProvider>();
    final trip = tp.upcomingTrip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Itinerary Maker', style: GoogleFonts.outfit())),
        body: const Center(child: Text('No active trip found for itinerary.')),
      );
    }

    final activities = trip.itinerary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 24, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
          ),
        ),
        title: Text('Itinerary Maker', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF1E2E46))),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Color(0xFF1E2E46))),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, size: 20, color: Color(0xFF1E2E46)),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE JOURNEY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(trip.destination, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Text(
                  trip.notes.isNotEmpty ? trip.notes : 'A minimalist curation of travel Waypoints for your journey.',
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
          
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildDayTab(0, 'Day 01'),
                _buildDayTab(1, 'Day 02'),
                _buildDayTab(2, 'Day 03'),
              ],
            ),
          ),
          
          Expanded(
            child: activities.isEmpty 
              ? Center(child: Text('No activities added yet.', style: GoogleFonts.inter(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: activities.length,
                  itemBuilder: (ctx, i) {
                    final act = activities[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(act.time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(act.title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))),
                                    GestureDetector(
                                      onTap: () => _handleDeleteActivity(context, trip, act),
                                      child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFB91C1C)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(act.location, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFormScreen(initialData: {'tripId': trip.id}))),
        backgroundColor: const Color(0xFF1E2E46),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _handleDeleteActivity(BuildContext context, TripModel trip, ItineraryActivity activity) async {
    final tp = context.read<TripProvider>();
    final updatedItinerary = trip.itinerary.where((a) => a.title != activity.title).toList();
    final updatedTrip = trip.copyWith(itinerary: updatedItinerary);
    await tp.updateTrip(trip.id, updatedTrip);
  }

  Widget _buildDayTab(int index, String label) {
    final isSelected = _selectedDay == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDay = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFF64748B))),
        ),
      ),
    );
  }
}
