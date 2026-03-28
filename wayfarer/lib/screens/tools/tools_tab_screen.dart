import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes.dart';

class ToolsTabScreen extends StatefulWidget {
  const ToolsTabScreen({super.key});

  @override
  State<ToolsTabScreen> createState() => _ToolsTabScreenState();
}

class _ToolsTabScreenState extends State<ToolsTabScreen> {
  final String _inputAmount = '1.00';
  final String _outputAmount = '0.92';
  
  final String _translationInput = 'Where is the nearest station?';
  final String _translationOutput = '最寄りの駅はどこですか？';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUICK UTILITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Crucial Traveler Tools', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.1)),
            const SizedBox(height: 12),
            Text('Essential utilities designed for the modern nomad. High-precision tools to navigate the world with effortless clarity.', 
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
            
            const SizedBox(height: 48),
            
            _buildItineraryCard(),
            
            const SizedBox(height: 32),
            _buildCurrencyConverter(),
            
            const SizedBox(height: 32),
            _buildBudgeterCard(),
            
            const SizedBox(height: 48),
            _buildTextTranslation(),
            
            const SizedBox(height: 48),
            _buildWorldWeather(),
            
            const SizedBox(height: 48),
            _buildWorldTimeZones(),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 28, color: Color(0xFF1E2E46)),
          const SizedBox(height: 32),
          Text('Itinerary Maker', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text('A standalone architect for your journey. Craft detailed day-by-day schedules with precise timestamps and waypoint mapping.', 
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.itinerary),
            child: Row(
              children: [
                Text('LAUNCH WORKSPACE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6), letterSpacing: 0.5)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.sync_alt, color: Color(0xFF1E40AF)),
              Text('LIVE RATES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Currency Converter', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text('Instant conversion for 150+ global currencies with real-time exchange API.', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_inputAmount USD', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const Icon(Icons.sync, color: Color(0xFF94A3B8), size: 18),
              Text('$_outputAmount EUR', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgeterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_add_outlined, size: 24, color: Color(0xFF1E2E46)),
          const SizedBox(height: 24),
          Text('Budgeter', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text('Split bills, track debts, and manage shared funds effortlessly across your travel party.', 
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
          const SizedBox(height: 24),
          Row(
            children: [
               _buildAvatar('https://i.pravatar.cc/150?u=1'),
               _buildAvatar('https://i.pravatar.cc/150?u=2'),
               _buildAvatar('https://i.pravatar.cc/150?u=3'),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.budgeter),
            child: Text('MANAGE BUDGETS >', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
      child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(url)),
    );
  }

  Widget _buildTextTranslation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Text Translation', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Text('Offline-ready voice and text translation for over 80 languages. Communication without borders.', 
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              const Icon(Icons.mic_none_outlined, size: 28, color: Color(0xFF132F5C)),
              const SizedBox(height: 8),
              Text('VOICE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildTranslationBox('INPUT (ENGLISH)', _translationInput, false),
        const SizedBox(height: 16),
        _buildTranslationBox('OUTPUT (JAPANESE)', _translationOutput, true),
      ],
    );
  }

  Widget _buildTranslationBox(String label, String text, bool isOutput) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOutput ? const Color(0xFFA6BCDB).withValues(alpha: 0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, style: GoogleFonts.inter(fontSize: 15, fontWeight: isOutput ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF0F172A))),
        ),
      ],
    );
  }

  Widget _buildWorldWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_outlined, color: Color(0xFF1E40AF), size: 24),
            const SizedBox(width: 12),
            Text('World Weather', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildWeatherItem('London', '14°C', 'CLOUDY', Icons.cloud),
            _buildWeatherItem('Tokyo', '22°C', 'SUNNY', Icons.wb_sunny),
            _buildWeatherItem('New York', '18°C', 'SHOWERS', Icons.beach_access), // No exact rain icon in mdi style sometimes
            _buildWeatherItem('Sydney', '24°C', 'CLEAR', Icons.wb_twilight),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherItem(String city, String temp, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(city, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
              Icon(icon, size: 18, color: const Color(0xFF1D4E89)),
            ],
          ),
          const Spacer(),
          Text(temp, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildWorldTimeZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1E40AF), size: 24),
            const SizedBox(width: 12),
            Text('World Time Zones', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildTimeZoneItem('PARIS (CET)', '10:42 AM'),
            _buildTimeZoneItem('DUBAI (GST)', '01:42 PM'),
            _buildTimeZoneItem('SINGAPORE (SGT)', '05:42 PM'),
            _buildTimeZoneItem('LOS ANGELES (PST)', '01:42 AM'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeZoneItem(String city, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(city, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(time, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
