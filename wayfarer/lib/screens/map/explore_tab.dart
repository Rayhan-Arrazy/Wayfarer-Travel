import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
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
            // Hero Live Map Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.lighten),
                ),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                     child: const Icon(Icons.map, color: Color(0xFF132F5C), size: 32),
                   ),
                   const SizedBox(height: 24),
                   Text('View Live Map', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                   const SizedBox(height: 8),
                   Text('EXPLORE REAL-TIME DATA NEAR YOU', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                   const SizedBox(height: 24),
                   SizedBox(
                     height: 56,
                     width: 180,
                     child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132F5C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Open Explorer', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                     ),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('What matters\nnearby', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46), height: 1.1)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('CURRENT COORDINATES:', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
                    Text('48.85 N, 2.35 E', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildNearbyItem(Icons.attach_money, 'ATM', 'Banque de France • Open 24h', 'FEE-FREE FOR PREMIUM', '0.2 MI'),
            _buildNearbyItem(Icons.restaurant, 'Quick Bite', 'L\'As du Fallafel • Closes 23:00', 'HIGHLY RATED LOCALLY', '0.5 MI'),
            _buildNearbyItem(Icons.train, 'Transit', 'Châtelet – Les Halles • Lines 1, 4, 7', 'ELEVATORS OPERATIONAL', '0.1 MI'),
            _buildNearbyItem(Icons.medical_services, 'Pharmacy', 'Pharmacie Monge • Open until 20:00', 'MULTILINGUAL STAFF', '0.8 MI'),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('VIEW ALL CATEGORIES (12)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 1.0)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyItem(IconData icon, String title, String subtitle, String badge, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
             child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                     Text(distance, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                   ],
                 ),
                 Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                 const SizedBox(height: 4),
                 Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1E40AF), letterSpacing: 0.5)),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
