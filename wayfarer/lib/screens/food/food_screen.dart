import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      // Adding bottom navigation block from prototype is complex since this is pushed via route.
      // Assuming parent Scaffold or similar has the bottom nav, we just render body.
      // But we need the floating action button layout. 
      // Actually prototype has a bottom nav bar. I will just render the body here.
      // But let's add the floating FAB shown in prototype.
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E2E46),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 54,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search cuisines or restaurants...',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(16), child: Icon(Icons.tune, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Smart Translator Hero Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E46),
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: const CachedNetworkImageProvider('https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800&q=80'), // Dark menu bg
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(const Color(0xFF1E2E46).withValues(alpha: 0.8), BlendMode.srcOver),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SMART TRANSLATOR', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text('Menu Lens', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Instantly translate and explain local dishes\nusing your camera.', style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    label: Text('Open Scanner', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Local Cuisine Guide Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FLAVOR PROFILES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text('Local Cuisine Guide', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ],
                ),
                Text('See all', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Large Cuisine Card
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80'), // Food plate
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('The Signature Roast', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Must-try heritage dish', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Smaller Cuisine Cards row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.coffee, color: Color(0xFFF97316), size: 24),
                        const SizedBox(height: 24),
                        Text('Brew Culture', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        Text('Local café guide', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bakery_dining, color: Color(0xFFF97316), size: 24),
                        const SizedBox(height: 24),
                        Text('Pastry Trails', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        Text('Sweet specialties', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Nearby Landmarks (which usually means restaurants near landmarks in this context)
            Text('AROUND YOU', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text('Nearby Landmarks', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 16),

            // Landmark Item 1
            _buildLandmarkItem('The Clock Tower', '250m away', ['Historic', 'Photo Spot'], 'https://images.unsplash.com/photo-1548625361-ec23a7e37dfc?w=150&q=80'),
            const SizedBox(height: 12),
            
            // Landmark Item 2
            _buildLandmarkItem('Central Market', '600m away', ['Dining', 'Shopping'], 'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=150&q=80'),
            
            const SizedBox(height: 100), // padding for bottom nav / FAB
          ],
        ),
      ),
    );
  }

  Widget _buildLandmarkItem(String name, String distance, List<String> tags, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(imageUrl: imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.near_me, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(distance, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                    child: Text(t, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                  )).toList(),
                )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
