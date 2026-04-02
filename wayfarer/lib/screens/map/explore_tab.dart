import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final ApiService _api = ApiService();
  Position? _currentPosition;
  Map<String, List<Map<String, dynamic>>> _categorizedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyData();
  }

  // Load when the widget is rebuilt (e.g. coming back from map)
  @override
  void didUpdateWidget(ExploreTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadNearbyData();
  }

  Future<void> _loadNearbyData() async {
    if (!mounted) return;
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Use high accuracy but with a small time limit to ensure responsiveness
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _isLoading = true; // Trigger loader while fetching API
      });

      // Fetch within strictly 500M as requested
      final response = await _api.getNearbyPlaces(pos.latitude, pos.longitude, 'all', radius: 500);
      final List<dynamic> elements = response.data['elements'] ?? [];
      
      Map<String, List<Map<String, dynamic>>> newCategorizedItems = {
        'EMERGENCY': [],
        'FINANCIAL': [],
        'TRANSPORT': [],
        'DINING': [],
        'SHOPPING': [],
        'TOURISM': [],
        'HOTELS': [],
        'OTHER PLACES': [],
      };

      for (var e in elements) {
        final tags = e['tags'] ?? {};
        
        // FILTER: Only show places with a proper name/brand to avoid generic dots
        final name = tags['name'] ?? tags['brand'] ?? tags['operator'];
        if (name == null) continue;

        final lat = (e['lat'] ?? e['center']?['lat'])?.toDouble() ?? 0.0;
        final lon = (e['lon'] ?? e['center']?['lon'])?.toDouble() ?? 0.0;
        if (lat == 0.0) continue;

        final distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lon);
        
        final item = {
          'icon': _getIconForTags(tags),
          'title': name,
          'subtitle': _getSubtitle(tags),
          'badge': _getBadge(tags),
          'distance': distance,
          'distanceText': distance < 1000 ? '${distance.round()} M' : '${(distance/1000).toStringAsFixed(1)} KM',
          'lat': lat,
          'lng': lon,
        };

        String? amenity = tags['amenity'];
        String? tourism = tags['tourism'];
        String? shop = tags['shop'];
        String? railway = tags['railway'];
        String? historic = tags['historic'];
        String? leisure = tags['leisure'];

        if (['hospital', 'pharmacy', 'clinic', 'doctors', 'dentist'].contains(amenity)) {
          newCategorizedItems['EMERGENCY']!.add(item);
        } else if (['atm', 'bank', 'bureau_de_change', 'money_transfer', 'payment_terminal'].contains(amenity)) {
          newCategorizedItems['FINANCIAL']!.add(item);
        } else if (['restaurant', 'cafe', 'fast_food', 'bar', 'food_court', 'ice_cream'].contains(amenity)) {
          newCategorizedItems['DINING']!.add(item);
        } else if (['bus_station', 'taxi', 'bus_stop', 'ferry_terminal', 'parking'].contains(amenity) || ['station', 'halt', 'tram_stop'].contains(railway)) {
          newCategorizedItems['TRANSPORT']!.add(item);
        } else if (['hotel', 'hostel', 'guest_house', 'motel', 'resort', 'apartment'].contains(tourism)) {
          newCategorizedItems['HOTELS']!.add(item);
        } else if (tourism != null || historic != null || leisure != null) {
          newCategorizedItems['TOURISM']!.add(item);
        } else if (shop != null || amenity == 'marketplace' || amenity == 'shopping_mall') {
          newCategorizedItems['SHOPPING']!.add(item);
        } else {
          newCategorizedItems['OTHER PLACES']!.add(item);
        }
      }

      // Sort every category by distance and limit to 5 per category
      newCategorizedItems.forEach((key, list) {
        list.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        newCategorizedItems[key] = list.take(5).toList();
      });

      // Clear empty categories
      newCategorizedItems.removeWhere((key, value) => value.isEmpty);

      if (!mounted) return;
      setState(() {
        _categorizedItems = newCategorizedItems;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ExploreTab Load Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSubtitle(Map tags) {
    String type = (tags['amenity'] ?? tags['tourism'] ?? tags['shop'] ?? tags['highway'] ?? 'Point of Interest').toString().replaceAll('_', ' ').toUpperCase();
    String? street = tags['addr:street'];
    if (street != null) return '$type • $street';
    return type;
  }

  String _getBadge(Map tags) {
    if (['hospital', 'pharmacy', 'clinic'].contains(tags['amenity'])) return 'IMMEDIATE ASSISTANCE AVAILABLE';
    if (['atm', 'bank'].contains(tags['amenity'])) return 'FINANCIAL SERVICE POINT';
    return 'NEARBY TRAVEL LOCATION';
  }

  IconData _getIconForTags(Map tags) {
    if (tags['amenity'] == 'hospital' || tags['amenity'] == 'clinic' || tags['amenity'] == 'pharmacy') return Icons.medical_services_rounded;
    if (tags['amenity'] == 'atm' || tags['amenity'] == 'bank' || tags['amenity'] == 'bureau_de_change') return Icons.attach_money_rounded;
    if (tags['amenity'] == 'restaurant' || tags['amenity'] == 'cafe') return Icons.restaurant_rounded;
    if (tags['railway'] == 'station' || tags['amenity'] == 'bus_station' || tags['amenity'] == 'taxi') return Icons.train_rounded;
    if (tags['tourism'] == 'hotel' || tags['tourism'] == 'hostel') return Icons.hotel_rounded;
    if (tags['shop'] != null) return Icons.shopping_bag_rounded;
    return Icons.place_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
          ),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
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
                     Text('Nearby Explorer', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                     const SizedBox(height: 8),
                     Text('ESSENTIAL DATA IN YOUR AREA', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
                     const SizedBox(height: 24),
                     SizedBox(
                       height: 56,
                       width: 200,
                       child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF132F5C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Live Map View', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                       ),
                     ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('What matters\nnearby', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46), height: 1.1)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                        child: Text('LIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF166534))),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('500M RADIUS ACTIVE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444), letterSpacing: 1.0)),
                      Text(
                        _currentPosition != null 
                        ? '${_currentPosition!.latitude.toStringAsFixed(4)} N, ${_currentPosition!.longitude.toStringAsFixed(4)} E'
                        : 'GPS Locating...', 
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: Color(0xFF132F5C)),
                ))
              else if (_categorizedItems.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.location_searching_rounded, size: 48, color: Colors.grey[200]),
                      const SizedBox(height: 16),
                      Text('Still searching for locations...', style: GoogleFonts.inter(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Check connection or zoom out map.', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ))
              else
                ..._categorizedItems.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 4),
                      child: Text(entry.key, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
                    ),
                    ...entry.value.map((item) => _buildNearbyItem(item)),
                    const SizedBox(height: 16),
                  ],
                )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.map, arguments: {
            'lat': item['lat'],
            'lng': item['lng'],
            'name': item['title'],
            'icon': item['icon'],
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
               child: Icon(item['icon'], color: const Color(0xFF94A3B8), size: 20),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Flexible(child: Text(item['title'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), overflow: TextOverflow.ellipsis)),
                       Text(item['distanceText'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                     ],
                   ),
                   Text(item['subtitle'], style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                   const SizedBox(height: 4),
                   Text(item['badge'], style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1E40AF), letterSpacing: 0.5)),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}
