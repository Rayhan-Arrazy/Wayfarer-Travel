import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes.dart';

class GuideTab extends StatelessWidget {
  const GuideTab({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 14, color: Color(0xFF1E40AF)),
                  const SizedBox(width: 8),
                  Text('GLOBAL DIRECTORY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E40AF), letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('World Continents', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Text('Embark on a curated journey through the diverse landscapes and deep-rooted heritages of our planet. Select a region to begin your editorial guide.', 
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5)),
            const SizedBox(height: 32),
            
            _buildContinentCard(context, 'Asia', 'Explore Culture & Tips — A tapestry of ancient traditions meeting hyper-modern cities across the world\'s largest landmass.', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=1200&q=80'),
            _buildContinentCard(context, 'Europe', 'Explore Culture & Tips — From the Mediterranean coast to Alpine peaks and historic capitals.', 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=1200&q=80'),
            _buildContinentCard(context, 'Africa', 'Explore Culture & Tips — Unmatched wildlife, vast deserts, and vibrant urban centers rich in rhythm.', 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?auto=format&fit=crop&w=1200&q=80'),
            _buildContinentCard(context, 'America', 'Explore Culture & Tips — A journey from the Arctic tundra to the tropical rainforests of the south.', 'https://images.unsplash.com/photo-1475503572774-15a45e5d60b9?auto=format&fit=crop&w=1200&q=80'),
            _buildContinentCard(context, 'Oceania & Australia', 'Explore Culture & Tips — Island paradises and the rugged, red soul of the Outback.', 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?auto=format&fit=crop&w=1200&q=80'),
            _buildContinentCard(context, 'Antarctica', 'Explore Culture & Tips — The last great wilderness. A silent, majestic expanse of ice and unique resilience.', 'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?auto=format&fit=crop&w=1200&q=80', isLast: true),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildContinentCard(BuildContext context, String name, String description, String imageUrl, {bool isLast = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.continentDetail, arguments: name),
      child: Container(
        height: 240,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2E46), // Premium dark blue fallback
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.55), BlendMode.darken),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(name, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(description, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.85), height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
            if (isLast) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('VIEW EXPEDITIONS →', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
