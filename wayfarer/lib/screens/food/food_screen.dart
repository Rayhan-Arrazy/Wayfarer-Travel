import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  
  List<dynamic> _restaurants = [];
  List<dynamic> _cuisines = [];
  bool _isLoadingRestaurants = true;
  bool _isLoadingCuisines = false;
  double _lat = -6.2088;
  double _lng = 106.8456;
  String _selectedCountry = 'Indonesian';

  final List<String> _cuisineCountries = ['Indonesian', 'Japanese', 'Italian', 'Indian', 'Thai', 'Mexican', 'Chinese', 'French', 'Korean', 'Vietnamese'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRestaurants();
    _loadCuisine();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoadingRestaurants = true);
    try {
      final response = await _api.searchRestaurants(_lat, _lng, radius: 2000);
      setState(() {
        _restaurants = response.data['restaurants'] ?? [];
        _isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() => _isLoadingRestaurants = false);
    }
  }

  Future<void> _loadCuisine() async {
    setState(() => _isLoadingCuisines = true);
    try {
      final response = await _api.getCuisineByCountry(_selectedCountry);
      setState(() {
        _cuisines = response.data['meals'] ?? [];
        _isLoadingCuisines = false;
      });
    } catch (e) {
      setState(() => _isLoadingCuisines = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Food & Dining', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.textPrimary),
            tooltip: 'Scan Food Barcode',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barcode scanner initializing... (Simulated)')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Nearby', icon: Icon(Icons.restaurant)),
            Tab(text: 'Cuisine Guide', icon: Icon(Icons.menu_book)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRestaurantsTab(),
          _buildCuisineTab(),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (_isLoadingRestaurants) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return _restaurants.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text('No restaurants found nearby', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadRestaurants,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurants.length,
              itemBuilder: (_, i) => _buildRestaurantCard(_restaurants[i]),
            ),
          );
  }

  Widget _buildRestaurantCard(dynamic restaurant) {
    final name = restaurant['name'] ?? 'Restaurant';
    final cuisine = restaurant['cuisine'] ?? '';
    final hours = restaurant['openingHours'] ?? '';
    final diet = restaurant['diet'] ?? {};

    List<String> dietLabels = [];
    if (diet['halal'] == true) dietLabels.add('🥩 Halal');
    if (diet['vegan'] == true) dietLabels.add('🥬 Vegan');
    if (diet['vegetarian'] == true) dietLabels.add('🥗 Vegetarian');
    if (diet['glutenFree'] == true) dietLabels.add('🌾 Gluten-free');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xFFFF8A65), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    if (cuisine.isNotEmpty)
                      Text(cuisine, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (hours.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(hours, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
          if (dietLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: dietLabels.map((l) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(l, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentColor)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCuisineTab() {
    return Column(
      children: [
        // Country selector
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _cuisineCountries.length,
            itemBuilder: (_, i) {
              final isActive = _selectedCountry == _cuisineCountries[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCountry = _cuisineCountries[i]);
                  _loadCuisine();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? AppTheme.primaryColor : AppTheme.lightBorder),
                  ),
                  alignment: Alignment.center,
                  child: Text(_cuisineCountries[i], style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  )),
                ),
              );
            },
          ),
        ),
        
        Expanded(
          child: _isLoadingCuisines
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : _cuisines.isEmpty
                  ? Center(child: Text('No dishes found', style: GoogleFonts.inter(color: AppTheme.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _cuisines.length,
                      itemBuilder: (_, i) => _buildDishCard(_cuisines[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildDishCard(dynamic meal) {
    final name = meal['strMeal'] ?? '';
    final thumb = meal['strMealThumb'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: thumb.isNotEmpty
                  ? Image.network(thumb, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.lightSurface,
                        child: const Center(child: Icon(Icons.fastfood, color: AppTheme.textMuted, size: 32)),
                      ))
                  : Container(
                      color: AppTheme.lightSurface,
                      child: const Center(child: Icon(Icons.fastfood, color: AppTheme.textMuted, size: 32)),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(name,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
