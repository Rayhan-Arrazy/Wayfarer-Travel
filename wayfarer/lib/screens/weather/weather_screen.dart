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
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _airQualityData;
  bool _isLoading = true;
  double _lat = -6.2088;
  double _lng = 106.8456;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _api.getCurrentWeather(_lat, _lng),
        _api.getAirQuality(_lat, _lng),
      ]);
      setState(() {
        _weatherData = responses[0].data;
        _airQualityData = responses[1].data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      final response = await _api.searchPlaces(query);
      final List results = response.data;
      if (results.isNotEmpty) {
        setState(() {
          _lat = double.parse(results[0]['lat'].toString());
          _lng = double.parse(results[0]['lon'].toString());
        });
        _loadWeather();
      }
    } catch (e) {
      // Handle error
    }
  }

  String _getWeatherIcon(int code) {
    if (code <= 1) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 57) return '🌧️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    return '⛈️';
  }

  String _getWeatherDesc(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Weather & Climate', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryColor, size: 20),
                        onPressed: () => _searchLocation(_searchController.text),
                      ),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                  const SizedBox(height: 20),

                  if (_weatherData != null) ...[
                    // Current Weather Card
                    _buildCurrentWeather(),
                    const SizedBox(height: 20),
                    
                    // Hourly Forecast
                    _buildHourlyForecast(),
                    const SizedBox(height: 20),

                    // Daily Forecast
                    _buildDailyForecast(),
                    const SizedBox(height: 20),

                    // UV & Air Quality
                    _buildWeatherDetails(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeather() {
    final current = _weatherData?['current'] ?? {};
    final code = current['weather_code'] ?? 0;
    final temp = current['temperature_2m'] ?? 0;
    final feelsLike = current['apparent_temperature'] ?? 0;
    final humidity = current['relative_humidity_2m'] ?? 0;
    final wind = current['wind_speed_10m'] ?? 0;
    
    final hourly = _weatherData?['hourly'] ?? {};
    final precips = hourly['precipitation_probability'] as List? ?? [];
    final precip = precips.isNotEmpty ? precips[0] : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0D47A1).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(_getWeatherIcon(code), style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text('${temp.toStringAsFixed(1)}°C',
            style: GoogleFonts.outfit(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(_getWeatherDesc(code),
            style: GoogleFonts.inter(fontSize: 18, color: Colors.white.withValues(alpha: 0.8))),
          Text('Feels like ${feelsLike.toStringAsFixed(1)}°C',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherStat('💧', 'Humidity', '$humidity%'),
              _buildWeatherStat('💨', 'Wind', '${wind.toStringAsFixed(1)} km/h'),
              _buildWeatherStat('☔', 'Rain', '$precip%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hourly = _weatherData?['hourly'] ?? {};
    final temps = hourly['temperature_2m'] as List? ?? [];
    final codes = hourly['weather_code'] as List? ?? [];
    final times = hourly['time'] as List? ?? [];

    if (temps.isEmpty) return const SizedBox.shrink();
    
    // Show next 24 hours
    final now = DateTime.now().hour;
    final startIdx = now;
    final endIdx = (now + 24).clamp(0, temps.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hourly Forecast', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (endIdx - startIdx).clamp(0, 24),
            itemBuilder: (_, i) {
              final idx = startIdx + i;
              if (idx >= temps.length || idx >= codes.length) return const SizedBox.shrink();
              final time = times[idx]?.toString().split('T').last.substring(0, 5) ?? '';
              return Container(
                width: 64,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: i == 0 ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: i == 0 ? AppTheme.primaryColor.withValues(alpha: 0.4) : AppTheme.lightBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(i == 0 ? 'Now' : time, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    Text(_getWeatherIcon(codes[idx] ?? 0), style: const TextStyle(fontSize: 20)),
                    Text('${(temps[idx] ?? 0).toStringAsFixed(0)}°', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast() {
    final daily = _weatherData?['daily'] ?? {};
    final maxTemps = daily['temperature_2m_max'] as List? ?? [];
    final minTemps = daily['temperature_2m_min'] as List? ?? [];
    final codes = daily['weather_code'] as List? ?? [];
    final times = daily['time'] as List? ?? [];

    if (maxTemps.isEmpty) return const SizedBox.shrink();

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('16-Day Forecast', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        ...List.generate(maxTemps.length.clamp(0, 16), (i) {
          final date = DateTime.tryParse(times[i]?.toString() ?? '');
          final dayName = date != null ? (i == 0 ? 'Today' : i == 1 ? 'Tomorrow' : dayNames[date.weekday - 1]) : '';
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(width: 70, child: Text(dayName, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary))),
                Text(_getWeatherIcon(codes.length > i ? codes[i] : 0), style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Text('${(minTemps.length > i ? minTemps[i] : 0).toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
                Container(
                  width: 80, height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFFFF9800)]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text('${(maxTemps.length > i ? maxTemps[i] : 0).toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    final current = _weatherData?['current'] ?? {};
    final uv = (current['uv_index'] ?? 0).toDouble();
    
    String uvLevel = 'Low';
    Color uvColor = AppTheme.successColor;
    String uvAdvice = 'No protection needed';
    if (uv >= 3 && uv < 6) { uvLevel = 'Moderate'; uvColor = AppTheme.warningColor; uvAdvice = 'Wear sunscreen SPF 30+'; }
    else if (uv >= 6 && uv < 8) { uvLevel = 'High'; uvColor = const Color(0xFFFF6D00); uvAdvice = 'Apply sunscreen, hat, and sunglasses'; }
    else if (uv >= 8 && uv < 11) { uvLevel = 'Very High'; uvColor = AppTheme.errorColor; uvAdvice = 'Avoid sun between 10am-4pm'; }
    else if (uv >= 11) { uvLevel = 'Extreme'; uvColor = const Color(0xFF9C27B0); uvAdvice = 'Stay indoors during midday'; }

    final aqiCurrent = _airQualityData?['current'] ?? {};
    final aqi = (aqiCurrent['us_aqi'] ?? 0).toDouble();

    String aqiLevel = 'Good';
    Color aqiColor = AppTheme.successColor;
    String aqiAdvice = 'Air quality is satisfactory';
    if (aqi >= 51 && aqi <= 100) { aqiLevel = 'Moderate'; aqiColor = AppTheme.warningColor; aqiAdvice = 'Acceptable air quality'; }
    else if (aqi >= 101 && aqi <= 150) { aqiLevel = 'Unhealthy for Sensitive Groups'; aqiColor = const Color(0xFFFF6D00); aqiAdvice = 'Sensitive people should limit outdoor time'; }
    else if (aqi >= 151 && aqi <= 200) { aqiLevel = 'Unhealthy'; aqiColor = AppTheme.errorColor; aqiAdvice = 'Everyone may begin to experience health effects'; }
    else if (aqi >= 201) { aqiLevel = 'Very Unhealthy'; aqiColor = const Color(0xFF9C27B0); aqiAdvice = 'Health warnings of emergency conditions'; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health & Environment', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        // UV Index
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: uvColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(uv.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: uvColor))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UV Index: $uvLevel', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: uvColor)),
                    const SizedBox(height: 2),
                    Text(uvAdvice, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Air Quality
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: aqiColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(aqi.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: aqiColor))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AQI: $aqiLevel', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: aqiColor)),
                    const SizedBox(height: 2),
                    Text(aqiAdvice, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
