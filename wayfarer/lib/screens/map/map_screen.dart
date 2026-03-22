import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();
  
  LatLng _center = const LatLng(35.6895, 139.6917); // Tokyo
  final double _zoom = 15.0;
  List<Marker> _markers = [];
  String _selectedCategory = 'Restaurants';
  bool _showBottomCard = true; // Show Ramen Ichiraku initially for the design

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Restaurants'},
    {'icon': Icons.hotel, 'label': 'Stays'},
    {'icon': Icons.camera_alt, 'label': 'Sights'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          // Background Google Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onTap: (tapPosition, point) => setState(() => _showBottomCard = false),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.wayfarer.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Top UI Floating Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
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
                              hintText: 'Ramen Ichiraku',
                              hintStyle: GoogleFonts.inter(color: AppTheme.textPrimary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.tune, color: AppTheme.textSecondary),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = _categories[i];
                        final isActive = _selectedCategory == cat['label'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['label']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                              ]
                            ),
                            child: Row(
                              children: [
                                Icon(cat['icon'], size: 16, color: isActive ? Colors.white : AppTheme.textPrimary),
                                const SizedBox(width: 8),
                                Text(cat['label'], style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isActive ? Colors.white : AppTheme.textPrimary
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          // Bottom Sheet Overlay
          if (_showBottomCard)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("FEATURED DINING", style: GoogleFonts.inter(color: const Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(5, (index) => const Icon(Icons.star_border, size: 12, color: Color(0xFFF97316))),
                                  )
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                                child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Ramen Ichiraku", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                              const SizedBox(width: 4),
                              Text("1-2-3 Konoha Ward, Tokyo", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Image
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        height: 140,
                                        color: Colors.grey.shade200,
                                        width: double.infinity,
                                        child: Image.network('https://images.unsplash.com/photo-1552611052-33e04de081de?w=400&h=300&fit=crop', fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(4)),
                                        child: Text("TOP RATED", style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right info boxes
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 66,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.schedule, size: 16, color: AppTheme.primaryColor),
                                          const Spacer(),
                                          Text("OPENS UNTIL\n11:00 PM", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10, color: AppTheme.primaryColor, height: 1.2)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 66,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("¥", style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textSecondary)),
                                          const Spacer(),
                                          Text("MODERATE", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.directions, color: Colors.white, size: 18),
                                  label: const Text("Get Directions"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 18),
                                  label: const Text("Menu"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
