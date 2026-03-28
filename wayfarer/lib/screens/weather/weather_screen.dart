import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../providers/trip_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _isLoading = true);
    try {
      final tripProvider = context.read<TripProvider>();
      final upcoming = tripProvider.upcomingTrip;
      double lat = 51.5074; // default London
      double lng = -0.1278;

      if (upcoming != null && upcoming.destinationInfo != null) {
        // If we had coordinates in destinationInfo we'd use them, otherwise use London for prototype match
      }

      final weatherRes = await _api.getWeather(lat, lng);

      setState(() {
        _weather = weatherRes.data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
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
        actions: const [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF97316),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Weather Card
                  _buildHeroWeatherCard(),
                  const SizedBox(height: 24),

                  // Hourly Forecast
                  _buildHourlyForecast(),
                  const SizedBox(height: 24),

                  // UV Index & Visibility
                  _buildUVIndexCard(),
                  const SizedBox(height: 16),
                  _buildVisibilityCard(),
                  const SizedBox(height: 16),

                  // Precipitation
                  _buildPrecipitationCard(),
                  const SizedBox(height: 16),

                  // Air Quality Sphere
                  _buildAirQualityCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroWeatherCard() {
    final temp = (_weather?['temperature'] as num?)?.round() ?? 18;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2E46),
        ),
        child: Stack(
          children: [
            // Right side image
            Positioned(
              right: 0, top: 0, bottom: 0,
              width: 180,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.black]).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=600&q=80', // London
                  fit: BoxFit.cover,
                  color: const Color(0xFF1E2E46).withValues(alpha: 0.2), colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENTLY IN LONDON', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$temp°', style: GoogleFonts.outfit(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                      const SizedBox(width: 8),
                      Text('Cloudy', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Text('H: 21°', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                          const SizedBox(width: 12),
                          Text('L: 14°', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Feels like ${(temp - 2)}°', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                          Text('Moderate breeze', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('HOURLY FORECAST', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: 0.5)),
            Text('View 7-day', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHourlyItem('Now', Icons.cloud, '18°', true),
            _buildHourlyItem('1PM', Icons.wb_sunny, '20°', false),
            _buildHourlyItem('2PM', Icons.wb_sunny, '21°', false),
            // Cutoff item on the right just like prototype
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 20, height: 90,
                  decoration: const BoxDecoration(color: Color(0xFF1E2E46), borderRadius: BorderRadius.horizontal(left: Radius.circular(16))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyItem(String time, IconData icon, String temp, bool isCloudy) {
    return Container(
      width: 80, padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Text(time, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Icon(icon, color: isCloudy ? const Color(0xFFF97316) : const Color(0xFFF97316), size: 22),
          const SizedBox(height: 8),
          Text(temp, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildUVIndexCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('UV INDEX', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 12),
          Text('4', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          Text('Moderate', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          // Progress bar
          Stack(
            children: [
              Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(3))),
              FractionallySizedBox(
                widthFactor: 0.4,
                child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(3))),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('VISIBILITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('12', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(width: 4),
              Text('km', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Text("It's perfectly clear today.", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPrecipitationCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('PRECIPITATION', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPrecipBar(20, '10AM', false),
              _buildPrecipBar(35, '', false),
              _buildPrecipBar(15, '', false),
              _buildPrecipBar(70, '4PM', true),
              _buildPrecipBar(35, '', false),
              _buildPrecipBar(10, '', false),
              _buildPrecipBar(25, '10PM', false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPrecipBar(double height, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32, height: height,
          decoration: BoxDecoration(color: isActive ? const Color(0xFF1E2E46) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted)),
        ]
      ],
    );
  }

  Widget _buildAirQualityCard() {
    int aqi = 42;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: aqi / 100,
                  backgroundColor: const Color(0xFFFCE7F3),
                  color: const Color(0xFFF9B29B),
                  strokeWidth: 8,
                ),
              ),
              // Pointer dot
              Positioned(
                top: 5, right: 30,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEA580C), shape: BoxShape.circle)),
              ),
              Column(
                children: [
                  Text('$aqi', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, height: 1.1)),
                  Text('AQI', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Air Quality is Good', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              const SizedBox(height: 8),
              Text('Air quality is considered satisfactory, and air pollution poses little or no risk. Enjoy your outdoor activities today!', style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2E46), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                child: Text('Detailed Analysis', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              )
            ],
          )
        ],
      ),
    );
  }
}
