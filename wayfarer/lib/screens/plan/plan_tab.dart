import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../config/routes.dart';

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
    final activeTrip = tripProvider.upcomingTrip;
    
    // Using hardcoded data from image if no active trip to match pixel-perfection
    final String budget = activeTrip != null ? '\$${activeTrip.budget.amount.toStringAsFixed(2)}' : '\$2,450.00';
    final String remaining = '\$842.15';
    final String tripName = activeTrip?.destination ?? 'Scandinavia Trip';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('The Wayfarer', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT TRIP BUDGET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Text(budget, style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
            const SizedBox(height: 4),
            Text('Total allocation for $tripName', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('REMAINING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                   const SizedBox(height: 8),
                   Text(remaining, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                   const SizedBox(height: 16),
                   Stack(
                     children: [
                       Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4))),
                       FractionallySizedBox(
                         widthFactor: 0.65,
                         child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF132F5C), borderRadius: BorderRadius.circular(4))),
                       ),
                     ],
                   ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Average', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Text('\$112.40', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
                  const SizedBox(height: 8),
                  Text('Based on the last 14 days of travel.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF132F5C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Text('View Analytics', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Entries', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                  child: Text('JULY 2024', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildEntryItem('Dinner - Stockholm Bistro', '\$54.20', 'Today, 8:15 PM'),
            _buildEntryItem('Museum Entrance - Vasa', '\$18.00', 'Today, 2:30 PM'),
            _buildEntryItem('Train Ticket - SJ Rail', '\$125.50', 'Yesterday, 9:00 AM'),
            _buildEntryItem('Morning Coffee', '\$6.50', 'Yesterday, 8:15 AM'),
            _buildEntryItem('Grocery Store - ICA', '\$32.10', 'July 12, 6:45 PM'),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Load More Transactions', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.budgeter),
          backgroundColor: const Color(0xFF132F5C),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEntryItem(String title, String amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(date, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
