import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF97316),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PLANNED JOURNEY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text('Tokyo to Kyoto', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, height: 1.1)),
            const SizedBox(height: 8),
            Text("Compare transit methods for your next leg. We've curated the most efficient paths for the Modern Nomad.", style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            // Departure Date Block
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEPARTURE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                      Text('Oct 24, 08:30', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shinkansen dark block
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF1E2E46), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1E2E46).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('SHINKANSEN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0)),
                      ),
                      const Icon(Icons.train, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('2h 15m', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                      const SizedBox(width: 8),
                      Text('Direct', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('The gold standard of Japanese travel. High-speed, ultra-reliable, and city-center to city-center.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4)),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ESTIMATE', style: GoogleFonts.inter(fontSize: 9, color: Colors.white54, letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text('¥13,910', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                        child: Row(
                          children: [
                            Text('Book Seat', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 14),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Domestic Flight Card
            _buildTransitCard(
              icon: Icons.flight,
              title: 'Domestic Flight',
              durationLabel: '3H 45M TOTAL',
              description: 'Includes check-in & transit to Haneda.',
              price: '¥9,800',
              badge: 'CHEAPEST',
              badgeColor: const Color(0xFFF97316),
            ),
            const SizedBox(height: 16),

            // Overnight Bus Card
            _buildTransitCard(
              icon: Icons.directions_bus,
              title: 'Overnight Bus',
              durationLabel: '8H 20M',
              description: 'Direct from Shinjuku. Reclining seats available.',
              price: '¥4,500',
              badge: 'ECONOMY',
              badgeColor: AppTheme.textSecondary,
            ),
            const SizedBox(height: 32),

            // Live Arrivals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Live Arrivals', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('SHIBUYA STATION', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),

            _buildArrivalItem('02', 'Yamanote Line', 'TOWARDS SHINJUKU'),
            const SizedBox(height: 12),
            _buildArrivalItem('07', 'Ginza Line', 'TOWARDS ASAKUSA'),
            const SizedBox(height: 12),
            _buildArrivalItem('11', 'Hanzomon Line', 'TOWARDS OSHIAGE'),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.lightBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                ),
                child: Text('VIEW ALL STATIONS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: 1.0)),
              ),
            ),
            const SizedBox(height: 32),

            // Map Area
            Container(
              height: 300, width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.lightBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(imageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80', fit: BoxFit.cover, color: Colors.white.withValues(alpha: 0.5), colorBlendMode: BlendMode.lighten),
                  ),
                  Positioned(top: 20, left: 20, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('Explore local spots', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  )),
                  // YOU ARE HERE
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF1E2E46), borderRadius: BorderRadius.circular(12)),
                        child: Text('YOU ARE HERE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0)),
                      ),
                      const SizedBox(height: 4),
                      Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFFF97316), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    ],
                  ),
                  // Map controls bottom right
                  Positioned(
                    bottom: 60, right: 16,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                      child: Column(
                        children: [
                          IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {}, constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                          Container(height: 1, width: 24, color: AppTheme.lightBorder),
                          IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () {}, constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                        ],
                      ),
                    ),
                  ),
                  // Legend at bottom
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Row(
                             children: [
                               Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1E2E46), shape: BoxShape.circle)),
                               const SizedBox(width: 6),
                               Text('TRANSIT HUBS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                               const SizedBox(width: 12),
                               Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                               const SizedBox(width: 6),
                               Text('DINING', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                             ],
                           ),
                           Row(
                             children: [
                               Text('FULL MAP', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 0.5)),
                               const SizedBox(width: 4),
                               const Icon(Icons.open_in_new, size: 12, color: AppTheme.primaryColor),
                             ],
                           )
                         ],
                       ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitCard({
    required IconData icon, required String title, required String durationLabel, 
    required String description, required String price, required String badge, required Color badgeColor
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              Text(durationLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              Text(badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 1.0)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildArrivalItem(String mins, String line, String dir) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.lightBorder), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text('MIN', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                Text(mins, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                const SizedBox(height: 2),
                Text(dir, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 0.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
