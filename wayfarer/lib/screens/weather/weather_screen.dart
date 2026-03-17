import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Default to Tokyo for demo
  final double _lat = 35.6762;
  final double _lng = 139.6503;

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = _weather?['current'] ?? {};
    final daily = _weather?['daily'] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWeather,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 10),
                Text('Tokyo, Japan', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800)),
                Text('REAL-TIME FORECAST', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),
                
                const SizedBox(height: 48),
                _buildMainWeather(current),
                
                const SizedBox(height: 48),
                Text('Next 7 Days', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                ..._buildDailyForecast(daily),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildMainWeather(Map<String, dynamic> current) {
    final temp = current['temperature_2m']?.toString() ?? '--';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$temp°', style: GoogleFonts.outfit(fontSize: 96, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('Partly Cloudy', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            Text('Wind: ${current['wind_speed_10m']} km/h', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          ],
        ),
        const Icon(Icons.cloud_queue, size: 100, color: Colors.blueAccent),
      ],
    );
  }

  List<Widget> _buildDailyForecast(Map<String, dynamic> daily) {
    if (daily['time'] == null) return [];
    
    final times = daily['time'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;

    return List.generate(times.length, (i) {
      final date = DateTime.parse(times[i]);
      final dayName = i == 0 ? 'Today' : _getDayName(date.weekday);
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            SizedBox(width: 80, child: Text(dayName, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
            const Icon(Icons.wb_sunny_outlined, size: 20, color: Colors.orange),
            const Spacer(),
            Text('${maxTemps[i].round()}°', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Text('${minTemps[i].round()}°', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ],
        ),
      );
    });
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
