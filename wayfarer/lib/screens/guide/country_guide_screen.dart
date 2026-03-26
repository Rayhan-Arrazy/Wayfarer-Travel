import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountryGuideScreen extends StatefulWidget {
  final Map<String, dynamic> countryData;
  const CountryGuideScreen({super.key, required this.countryData});

  @override
  State<CountryGuideScreen> createState() => _CountryGuideScreenState();
}

class _CountryGuideScreenState extends State<CountryGuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  // Cuisine Data
  List<dynamic> _popularMeals = [];
  bool _isLoadingCuisine = false;

  

  
  // Lodging Data
  List<dynamic> _hotels = [];
  List<dynamic> _filteredHotels = [];
  bool _isLoadingHotels = false;
  String _selectedRating = 'Any';

  // Transport Data
  List<dynamic> _emergencyNumbers = [];
  bool _isLoadingEmergency = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final name = widget.countryData['name']?['common'] ?? '';
    final code = widget.countryData['cca2'] ?? '';
    final latlng = widget.countryData['latlng'] as List<dynamic>?;
    
    _loadCuisine(name);
    _loadLodging(latlng);
    _loadEmergency(code);
  }

  Future<void> _loadEmergency(String countryCode) async {
    setState(() => _isLoadingEmergency = true);
    try {
      final res = await _api.getEmergencyNumbers(countryCode);
      if (mounted) {
        setState(() => _emergencyNumbers = [res.data]);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingEmergency = false);
  }

  Future<void> _loadCuisine(String countryName) async {
    setState(() => _isLoadingCuisine = true);
    try {
      final res = await _api.getCuisineByCountry(countryName);
      if (mounted && res.data['meals'] != null) {
        setState(() => _popularMeals = res.data['meals']);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingCuisine = false);
  }

  Future<void> _loadLodging(List<dynamic>? latlng) async {
    if (latlng == null || latlng.isEmpty) return;
    setState(() => _isLoadingHotels = true);
    try {
      final res = await _api.searchAccommodation(
        (latlng[0] as num).toDouble(), 
        (latlng[1] as num).toDouble(), 
        radius: 50000 // Huge radius to find recommended lodging
      );
      final els = res.data['elements'] as List? ?? [];
      final hotels = els.where((e) => e['tags']?['tourism'] == 'hotel' || e['tags']?['building'] == 'hotel' || e['tags']?['name'] != null).toList();
      
      if (mounted) {
        setState(() {
          _hotels = hotels;
          _filteredHotels = hotels;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingHotels = false);
  }

  void _applyHotelFilter(String rating) {
    setState(() {
      _selectedRating = rating;
      if (rating == 'Any') {
        _filteredHotels = _hotels;
      } else {
        // Just mock filtering based on arbitrary data availability
        _filteredHotels = _hotels.where((h) => (h['tags']?['stars'] ?? '3') == rating.replaceAll(' Stars', '')).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.countryData['name']?['common'] ?? 'Unknown';
    final flagUrl = widget.countryData['flags']?['png'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, shadows: [const Shadow(color: Colors.black45, blurRadius: 4)])),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    flagUrl.isNotEmpty 
                      ? CachedNetworkImage(imageUrl: flagUrl, fit: BoxFit.cover)
                      : Container(color: AppTheme.primaryColor),
                    Container(color: Colors.black.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.primaryColor,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "OVERVIEW & MAP"),
                    Tab(text: "CUISINE"),
                    Tab(text: "LODGING"),
                    Tab(text: "TRANSPORT"),
                    Tab(text: "EMERGENCY"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildCuisineTab(),
            _buildLodgingTab(),
            _buildTransportTab(),
            _buildEmergencyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final latlng = widget.countryData['latlng'] as List<dynamic>?;
    final cap = widget.countryData['capital']?[0] ?? 'Unknown Capital';
    final sub = widget.countryData['subregion'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Information', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoCard(Icons.location_city, 'Capital', cap),
              const SizedBox(width: 12),
              _infoCard(Icons.map_outlined, 'Region', sub),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoCard(Icons.people_outline, 'Population', widget.countryData['population']?.toString() ?? 'N/A'),
              const SizedBox(width: 12),
              _infoCard(Icons.language, 'Top Level', widget.countryData['tld']?[0] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 32),
          Text('Location on Map', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('This map is non-navigational and only serves to establish geographic positioning.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: latlng != null && latlng.length >= 2 
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng((latlng[0] as num).toDouble(), (latlng[1] as num).toDouble()),
                      initialZoom: 4,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Disable navigation interactions
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                        userAgentPackageName: 'com.wayfarer.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng((latlng[0] as num).toDouble(), (latlng[1] as num).toDouble()),
                            width: 80, height: 80,
                            child: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 40),
                          )
                        ]
                      )
                    ],
                  )
                : const Center(child: Text("Map coordinates unavailable")),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.accentColor, size: 24),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineTab() {
    if (_isLoadingCuisine) return const Center(child: CircularProgressIndicator());
    if (_popularMeals.isEmpty) return Center(child: Text('No specialized cuisine data found.\nExpect a diverse culinary range.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppTheme.textMuted)));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _popularMeals.length,
      itemBuilder: (ctx, i) {
        final meal = _popularMeals[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(meal['strMealThumb'] ?? '', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width:60, height:60)),
            ),
            title: Text(meal['strMeal'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            subtitle: Text('Traditional Dish', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
            trailing: const Icon(Icons.restaurant_menu, color: AppTheme.accentColor),
          ),
        );
      },
    );
  }

  Widget _buildLodgingTab() {
    return Column(
      children: [
        // Filters
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Any', '5 Stars', '4 Stars', '3 Stars'].map((rating) {
              final active = _selectedRating == rating;
              return GestureDetector(
                onTap: () => _applyHotelFilter(rating),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppTheme.primaryColor : AppTheme.lightBorder),
                  ),
                  child: Center(
                    child: Text(rating, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: active ? Colors.white : AppTheme.textPrimary
                    )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _isLoadingHotels 
            ? const Center(child: CircularProgressIndicator())
            : _filteredHotels.isEmpty 
              ? Center(child: Text('No registered lodgings found.', style: GoogleFonts.inter(color: AppTheme.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredHotels.length,
                  itemBuilder: (ctx, i) {
                    final h = _filteredHotels[i];
                    final name = h['tags']?['name'] ?? 'Local Hotel';
                    final stars = h['tags']?['stars'] ?? '3';
                    final website = h['tags']?['website'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.hotel, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('$stars Star Rating', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                                if (website != null) ...[
                                  const SizedBox(height: 4),
                                  Text(website.toString(), style: GoogleFonts.inter(fontSize: 11, color: AppTheme.infoColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _buildTransportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Getting Around', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _transportCard(Icons.directions_subway, 'Public Transit', 'Major cities typically feature comprehensive train, metro, and bus systems. Ensure to buy local transit cards.'),
          const SizedBox(height: 12),
          _transportCard(Icons.local_taxi, 'Taxis & Rideshare', 'Ride-hailing apps are usually available. Metered taxis are standard but always verify regulations locally.'),
          const SizedBox(height: 12),
          _transportCard(Icons.flight, 'Domestic Flights', 'For larger countries, domestic airlines offer efficient connections between major regions.'),
          const SizedBox(height: 12),
          _transportCard(Icons.directions_car, 'Car Rental', 'International Driving Permits might be required. Traffic laws are strictly enforced.'),
        ],
      ),
    );
  }

  Widget _transportCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppTheme.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    if (_isLoadingEmergency) return const Center(child: CircularProgressIndicator());
    final emg = _emergencyNumbers.isNotEmpty ? _emergencyNumbers.first : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emergency Services', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.red.shade700)),
          const SizedBox(height: 8),
          Text('Keep these numbers saved for immediate assistance.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          const SizedBox(height: 24),
          
          _emergencyCard('Police', emg?['police']?['all']?[0] ?? '112', Icons.local_police, Colors.blue),
          const SizedBox(height: 12),
          _emergencyCard('Ambulance', emg?['ambulance']?['all']?[0] ?? '112', Icons.medical_services, Colors.red),
          const SizedBox(height: 12),
          _emergencyCard('Fire Department', emg?['fire']?['all']?[0] ?? '112', Icons.fireplace, Colors.orange),
          
          const SizedBox(height: 32),
          Text('Safety Tips', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _safetyTip('Always carry a copy of your passport.'),
          _safetyTip('Register with your embassy upon arrival.'),
          _safetyTip('Keep emergency cash in a separate location.'),
        ],
      ),
    );
  }

  Widget _emergencyCard(String title, String number, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Text(number, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.phone, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _safetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.lightBg,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
