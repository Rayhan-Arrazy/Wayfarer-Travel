import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

class AccommodationScreen extends StatefulWidget {
  const AccommodationScreen({super.key});

  @override
  State<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Filters';

  final List<String> _filters = ['Filters', 'Hotel', 'Resort', 'Villa', 'Apartment'];

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
            Text('YOUR NEXT STAY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text('Explore curated accommodations', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, height: 1.1)),
            const SizedBox(height: 24),

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
                        hintText: 'Where are you going?',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFF1E2E46), borderRadius: BorderRadius.circular(10)),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16)),
                      child: Text('Search', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isFilterBtn = filter == 'Filters';
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Row(
                        children: [
                          if (isFilterBtn) ...[
                            const Icon(Icons.tune, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(filter),
                        ],
                      ),
                      selected: isFilterBtn ? true : _selectedFilter == filter,
                      onSelected: (selected) {
                        if (!isFilterBtn) setState(() => _selectedFilter = filter);
                      },
                      labelStyle: GoogleFonts.inter(
                        color: isFilterBtn ? Colors.white : (_selectedFilter == filter ? Colors.white : AppTheme.textSecondary),
                        fontWeight: FontWeight.w600, fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF1E2E46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isFilterBtn ? const Color(0xFF1E2E46) : AppTheme.lightBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Accommodation Card 1
            _buildAccommodationCard(
              imageUrl: 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80', // Resort pool
              title: 'Azure Horizon Retreat',
              location: 'Amalfi Coast, Italy',
              price: '\$450',
              rating: '4.9',
              reviews: '128',
              isTopRated: true,
            ),
            const SizedBox(height: 20),
            
            // Accommodation Card 2
            _buildAccommodationCard(
              imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80', // Ocean view room
              title: 'The Cobalt Boutique',
              location: 'Santorini, Greece',
              price: '\$320',
              rating: '4.7',
              reviews: '94',
              isTopRated: false,
            ),
            const SizedBox(height: 20),

            // Map Preview with price tags
            Container(
              height: 400, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'), // Google maps style satellite view
                  fit: BoxFit.cover,
                )
              ),
              child: Stack(
                children: [
                  // Map overlay blur + items
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Stack(
                        children: [
                          Positioned(top: 20, left: 100, right: 100, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh, size: 14),
                                const SizedBox(width: 8),
                                Text('Search this area', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          )),

                          // Price tags
                          _buildPriceTag(100, 150, '\$450', true),
                          _buildPriceTag(200, 220, '\$320', false),
                          _buildPriceTag(240, 200, '\$280', false),

                          // Map controls bottom right
                          Positioned(
                            bottom: 60, right: 16,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                                  child: Column(
                                    children: [
                                      IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {}, constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                      Container(height: 1, width: 24, color: AppTheme.lightBorder),
                                      IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () {}, constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                                  child: IconButton(icon: const Icon(Icons.my_location, size: 18), onPressed: () {}, constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
                                )
                              ],
                            ),
                          ),
                          
                          // Showing X properties label
                          Positioned(
                            bottom: 16, left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.info, size: 12, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('Showing 12 properties near Amalfi Coast', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 100), // padding for bottom nav / FAB
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTag(double top, double left, String price, bool isActive) {
    return Positioned(
      top: top, left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E2E46) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
          border: Border.all(color: isActive ? Colors.transparent : AppTheme.lightBorder),
        ),
        child: Text(price, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? Colors.white : AppTheme.primaryColor)),
      ),
    );
  }

  Widget _buildAccommodationCard({
    required String imageUrl, required String title, required String location, 
    required String price, required String rating, required String reviews, required bool isTopRated
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        children: [
          // Image block
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(imageUrl: imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 18),
                ),
              ),
              if (isTopRated)
                Positioned(
                  bottom: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(12)),
                    child: Text('TOP RATED', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ),
          
          // Info block
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(location, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFF97316)),
                          const SizedBox(width: 4),
                          Text(rating, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryColor)),
                          const SizedBox(width: 4),
                          Text('($reviews reviews)', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('from', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        Text('/night', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2E46),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text('Book Now', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
