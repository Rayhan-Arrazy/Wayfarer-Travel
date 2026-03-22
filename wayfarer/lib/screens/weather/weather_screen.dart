import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _weather;
  
  final double _lat = 51.5074; // London coordinates as shown in Image 5
  final double _lng = -0.1278;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getWeather(_lat, _lng);
      setState(() {
        _weather = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final current = _weather?['current'] ?? {};
    final temp = current['temperature_2m']?.round() ?? 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWeather,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeatherHero(temp),
                const SizedBox(height: 32),
                Text('HOURLY FORECAST', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1.2)),
                const SizedBox(height: 16),
                _buildHourlyForecast(),
                const SizedBox(height: 32),
                _buildMetricsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherHero(int temp) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: const Color(0xFF1E3A5F).withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 15))
            ],
            image: const DecorationImage(
              image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1543968996-ee822b817625?q=80&w=800'), // Dark cloudy sky
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.6)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text('CURRENTLY IN LONDON', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                Text('$temp°', style: GoogleFonts.outfit(color: Colors.white, fontSize: 96, fontWeight: FontWeight.w800, height: 1.0)),
                const SizedBox(height: 8),
                Text('Mostly Cloudy', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('H:18°   L:11°', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildHourlyCard('Now', 14, Icons.cloud, true, null),
          _buildHourlyCard('14:00', 15, Icons.wb_cloudy, false, null),
          _buildHourlyCard('15:00', 15, Icons.water_drop, false, '40%'),
          _buildHourlyCard('16:00', 14, Icons.water_drop, false, '60%'),
          _buildHourlyCard('17:00', 13, Icons.cloud, false, null),
        ],
      ),
    );
  }

  Widget _buildHourlyCard(String time, int temp, IconData icon, bool isActive, String? prob) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? AppTheme.primaryColor : const Color(0xFFF1F5F9)),
        boxShadow: isActive ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF64748B)
          )),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: isActive ? Colors.white : AppTheme.primaryColor, size: 24),
              if (prob != null)
                Positioned(
                  bottom: -14,
                  child: Text(prob, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF3B82F6))),
                ),
            ],
          ),
          Text('$temp°', style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppTheme.primaryColor
          )),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(Icons.wb_sunny_outlined, 'UV INDEX', '3', 'Moderate'),
        _buildMetricCard(Icons.visibility_outlined, 'VISIBILITY', '10 km', 'Perfect clear view'),
        _buildMetricCard(Icons.umbrella_outlined, 'PRECIPITATION', '1.2 mm', 'in last 24h'),
        _buildMetricCard(Icons.air, 'AIR QUALITY', '42', 'Good - healthy'),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String value, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: AppTheme.primaryColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
