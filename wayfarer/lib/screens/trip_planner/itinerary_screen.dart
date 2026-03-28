import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import 'activity_form_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final String? tripId;
  const ItineraryScreen({super.key, this.tripId});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _selectedDay = 0;

  final List<Map<String, dynamic>> _activities = [
    {
      'time': '09:00 AM',
      'title': 'Design Museum Danmark',
      'desc': 'Explore the evolution of Danish furniture and graphic design in this restored rococo building. Focus on the Kaare Klint furniture collection.',
    },
    {
      'time': '12:30 PM',
      'title': 'TorvehallerneKBH',
      'desc': 'Experience the vibrant food market. Highly recommend traditional Smørrebrød from Hallernes and fresh coffee from The Coffee Collective.',
    },
    {
      'time': '03:00 PM',
      'title': 'The Black Diamond',
      'desc': 'Royal Library extension featuring striking neo-modernist architecture. Walk through the central atrium for harbor views and light play.',
    },
    {
      'time': '07:30 PM',
      'title': 'Dinner at Høst',
      'desc': 'Award-winning New Nordic cuisine in a rustic, beautifully designed space. Set menu focusing on seasonal Scandinavian ingredients.',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        title: Text('Trip Budget', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF1E2E46))),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppTheme.primaryColor)),
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
                Text('Copenhagen Discovery', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'A minimalist curation of Scandinavian design, culinary highlights, and maritime history across three curated days.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _activities.length,
              itemBuilder: (ctx, i) {
                final act = _activities[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(act['time'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(act['title'], style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            const SizedBox(height: 8),
                            Text(act['desc'], style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
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
        onPressed: () => _openActivityForm(context),
        backgroundColor: const Color(0xFF1E2E46),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
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

  void _openActivityForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityFormScreen()));
  }

}
