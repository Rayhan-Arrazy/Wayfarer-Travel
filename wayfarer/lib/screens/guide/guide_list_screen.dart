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

class _GuideListScreenState extends State<GuideListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<dynamic> _countries = [];
  List<dynamic> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final response = await _api.getAllCountries();
      setState(() {
        _countries = response.data;
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Country Guides', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Comprehensive travel handbooks for every destination', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightCard,
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
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredCountries.isEmpty
                  ? Center(child: Text('No countries found', style: GoogleFonts.inter(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredCountries.length,
                      itemBuilder: (ctx, i) {
                        final country = _filteredCountries[i];
                        final name = country['name']?['common'] ?? 'Unknown';
                        final flagUrl = country['flags']?['png'] ?? '';
                        final region = country['region'] ?? '';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.lightBorder),
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
                            title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                            subtitle: Text(region, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
