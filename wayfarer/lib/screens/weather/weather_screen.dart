import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),

              const SizedBox(height: 10),
              Text('Tokyo, Japan', 
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('CURRENT WEATHER', 
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),

              const SizedBox(height: 32),

              // Main Temp Display
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('18°', style: GoogleFonts.outfit(fontSize: 90, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cloudy', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        Text('Feels like 16°', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Icon(Icons.cloud_outlined, size: 64, color: Color(0xFF64B5F6)),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Hourly Forecast
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hourly Forecast', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('View 7-day', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHourlyItem('Now', '18°', Icons.cloud_outlined, true),
                  _buildHourlyItem('2 PM', '20°', Icons.wb_sunny_outlined, false),
                  _buildHourlyItem('3 PM', '21°', Icons.wb_sunny_outlined, false),
                  _buildHourlyItem('4 PM', '19°', Icons.cloud_outlined, false),
                ],
              ),

              const SizedBox(height: 48),

              // UV Index
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('UV INDEX', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('4', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    Text('Moderate', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: Colors.black.withValues(alpha: 0.05),
                      color: Colors.orange,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Text('In intensity later today', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Air Quality
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.air, size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('AIR QUALITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: 0.42,
                            strokeWidth: 10,
                            backgroundColor: Colors.black.withValues(alpha: 0.05),
                            color: Colors.greenAccent,
                          ),
                        ),
                        Column(
                          children: [
                            Text('42', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800)),
                            Text('AQI', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Air Quality is Good', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Air quality is considered satisfactory, and air pollution poses little or no risk. Enjoy your outdoor activities today!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Detailed Analysis'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
          ),
          const Icon(Icons.help_outline, color: AppTheme.textPrimary, size: 24),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(String time, String temp, IconData icon, bool isNow) {
    return Column(
      children: [
        Text(time, style: GoogleFonts.inter(fontSize: 12, color: isNow ? AppTheme.textPrimary : AppTheme.textMuted, fontWeight: isNow ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 12),
        Icon(icon, size: 24, color: isNow ? AppTheme.primaryColor : AppTheme.textSecondary),
        const SizedBox(height: 12),
        Text(temp, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      ],
    );
  }
}
