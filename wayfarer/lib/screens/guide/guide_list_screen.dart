import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'country_guide_screen.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<dynamic> _countries = [];
  List<dynamic> _filteredCountries = [];

  final List<Map<String, dynamic>> _travelTypes = [
    {
      'title': 'Adventure & Hiking',
      'subtitle': 'For the thrill seekers and trailblazers.',
      'icon': Icons.terrain,
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&q=80',
      'tips': [
        'Always check weather forecasts before departing.',
        'Invest in high-quality, broken-in footwear.',
        'Carry a physical map and compass along with GPS.',
      ]
    },
    {
      'title': 'Cultural Tourism',
      'subtitle': 'Immerse yourself in history and heritage.',
      'icon': Icons.account_balance,
      'image': 'https://images.unsplash.com/photo-1548625361-ec23a7e37dfc?w=400&q=80',
      'tips': [
        'Learn basic greetings in the local language.',
        'Dress modestly when visiting religious sites.',
        'Read about the destination\'s history beforehand.',
      ]
    },
    {
      'title': 'Wellness & Retreat',
      'subtitle': 'Disconnect, relax, and rejuvenate.',
      'icon': Icons.spa,
      'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80',
      'tips': [
        'Pack comfortable, loose-fitting clothing.',
        'Set an out-of-office response and stay offline.',
        'Embrace early morning meditation or yoga sessions.',
      ]
    },
    {
      'title': 'Backpacking',
      'subtitle': 'Travel light, travel far on a budget.',
      'icon': Icons.backpack,
      'image': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400&q=80',
      'tips': [
        'Roll your clothes to save space in your pack.',
        'Stay in eco-hostels to meet fellow travelers.',
        'Always carry a reusable water bottle.',
      ]
    },
    {
      'title': 'Luxury & Resort',
      'subtitle': 'Five-star excellence and premium comfort.',
      'icon': Icons.king_bed,
      'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&q=80',
      'tips': [
        'Book concierge services in advance for reservations.',
        'Check for inclusive spa or dining credits.',
        'Dress code is often smart casual for evening dining.',
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCountries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final response = await _api.getAllCountries();
      setState(() {
        _countries = response.data;
        // Sort alphabetically
        _countries.sort((a, b) {
          final nameA = a['name']?['common']?.toString() ?? '';
          final nameB = b['name']?['common']?.toString() ?? '';
          return nameA.compareTo(nameB);
        });
        _filteredCountries = _countries;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCountries(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCountries = _countries);
      return;
    }
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredCountries = _countries.where((c) {
        final name = c['name']?['common']?.toString().toLowerCase() ?? '';
        return name.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Explore Guides', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: const Color(0xFFF97316),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Destinations'),
            Tab(text: 'Travel Styles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDestinationsTab(),
          _buildTravelStylesTab(),
        ],
      ),
    );
  }

  Widget _buildDestinationsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Search for a country...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _filteredCountries.isEmpty
              ? Center(child: Text('No countries found', style: GoogleFonts.inter(color: AppTheme.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (ctx, i) {
                    final country = _filteredCountries[i];
                    final name = country['name']?['common'] ?? 'Unknown';
                    final flagUrl = country['flags']?['png'] ?? '';
                    final region = country['region'] ?? '';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CountryGuideScreen(countryData: country),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: flagUrl.isNotEmpty 
                            ? Image.network(flagUrl, width: 60, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width: 60, height: 40))
                            : Container(width: 60, height: 40, color: Colors.grey.shade200),
                        ),
                        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                        subtitle: Text(region, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTravelStylesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _travelTypes.length,
      itemBuilder: (context, index) {
        final type = _travelTypes[index];
        final List<String> tips = List<String>.from(type['tips']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.lightBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  type['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(height: 160, color: Colors.grey.shade200),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(type['icon'], color: const Color(0xFFF97316), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(type['title'], style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              const SizedBox(height: 4),
                              Text(type['subtitle'], style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('ESSENTIAL TIPS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary))),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
