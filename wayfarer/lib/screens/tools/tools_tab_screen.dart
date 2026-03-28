import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class ToolsTabScreen extends StatefulWidget {
  const ToolsTabScreen({super.key});

  @override
  State<ToolsTabScreen> createState() => _ToolsTabScreenState();
}

class _ToolsTabScreenState extends State<ToolsTabScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _translateController = TextEditingController();
  String _translationResult = "";
  bool _isTranslating = false;

  final List<Map<String, dynamic>> _weatherData = [
    {'city': 'London', 'temp': '14°C', 'status': 'CLOUDY', 'icon': Icons.cloud},
    {'city': 'Tokyo', 'temp': '22°C', 'status': 'SUNNY', 'icon': Icons.wb_sunny},
    {'city': 'New York', 'temp': '18°C', 'status': 'SHOWERS', 'icon': Icons.beach_access},
    {'city': 'Sydney', 'temp': '24°C', 'status': 'CLEAR', 'icon': Icons.wb_twilight},
  ];

  final List<Map<String, dynamic>> _timezoneData = [
    {'city': 'Paris', 'offset': 'CET', 'time': '10:42 AM'},
    {'city': 'Dubai', 'offset': 'GST', 'time': '01:42 PM'},
    {'city': 'Singapore', 'offset': 'SGT', 'time': '05:42 PM'},
    {'city': 'Los Angeles', 'offset': 'PT', 'time': '01:42 AM'},
  ];

  @override
  void dispose() {
    _translateController.dispose();
    super.dispose();
  }

  Future<void> _handleTranslation(String text) async {
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final res = await _api.translateText(text, 'en', 'ja');
      final translated = res.data['responseData']['translatedText'];
      setState(() {
        _translationResult = translated ?? "Error translating";
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translationResult = "Error connecting to service";
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', 
          style: GoogleFonts.outfit(
            color: const Color(0xFF1D4E89), 
            fontWeight: FontWeight.w800,
            fontSize: 22,
          )),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80'),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUICK UTILITY', 
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.w800, 
                color: const Color(0xFF64748B), 
                letterSpacing: 1.5,
              )),
            const SizedBox(height: 8),
            Text('Crucial Traveler Tools', 
              style: GoogleFonts.outfit(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.textPrimary,
                height: 1.1,
              )),
            const SizedBox(height: 12),
            Text(
              'Essential utilities designed for the modern nomad. High-precision tools to navigate the world with effortless clarity.',
              style: GoogleFonts.inter(
                fontSize: 14, 
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Itinerary Maker
            _buildLargeToolCard(
              icon: Icons.calendar_today_outlined,
              title: 'Itinerary Maker',
              description: 'A standalone architect for your journey. Craft detailed day-by-day schedules with precise timestamps and waypoint mapping.',
              buttonLabel: 'LAUNCH WORKSPACE',
              onTap: () => Navigator.pushNamed(context, AppRoutes.itinerary),
            ),
            
            const SizedBox(height: 24),
            
            // Currency Converter
            _buildMediumToolCard(
              icon: Icons.sync,
              label: 'LIVE RATES',
              title: 'Currency Converter',
              description: 'Instant conversion for 150+ global currencies with real-time exchange API.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.currency),
              extra: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1.00 USD', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const Icon(Icons.sync, size: 16, color: AppTheme.textMuted),
                  Text('0.92 EUR', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Budgeter
            _buildMediumToolCard(
              icon: Icons.person_add_outlined,
              title: 'Budgeter',
              description: 'Split bills, track debts, and manage shared funds effortlessly across your travel party.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.budgeter),
              extra: Row(
                children: [
                  const CircleAvatar(radius: 12, backgroundColor: Colors.teal),
                  const SizedBox(width: -8),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.cyan),
                  const SizedBox(width: -8),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                  const Spacer(),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Text Translation
            _buildTranslationSection(),
            
            const SizedBox(height: 48),
            
            // World Weather
            _buildHeaderWithIcon(Icons.wb_sunny_outlined, 'World Weather'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weatherData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (ctx, i) {
                final d = _weatherData[i];
                return _buildDataBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d['city'], style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text(d['temp'], style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(d['status'], style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      Icon(d['icon'], color: const Color(0xFF1E2E46), size: 24),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // World Time Zones
            _buildHeaderWithIcon(Icons.access_time, 'World Time Zones'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timezoneData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (ctx, i) {
                final d = _timezoneData[i];
                return _buildDataBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${d['city'].toUpperCase()} [${d['offset']}]', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(d['time'], style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeToolCard({required IconData icon, required String title, required String description, required String buttonLabel, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.lightBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30, bottom: -30,
              child: Icon(Icons.menu_book, size: 160, color: const Color(0xFFF1F5F9).withOpacity(0.5)),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: AppTheme.textPrimary, size: 28),
                  const SizedBox(height: 24),
                  Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Text(description, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(buttonLabel, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF64748B)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumToolCard({required IconData icon, String? label, required String title, required String description, required VoidCallback onTap, required Widget extra}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: const Color(0xFF132F5C), size: 24),
                if (label != null)
                  Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(description, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            extra,
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Text Translation', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Text('Offline-ready voice and text translation for over 80 languages. Communication without borders.', 
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const Icon(Icons.mic_none, size: 24, color: AppTheme.textPrimary),
              const SizedBox(height: 4),
              Text('voice', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('INPUT (ENGLISH)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: _translateController,
          onSubmitted: _handleTranslation,
          decoration: InputDecoration(
            hintText: 'Where is the nearest station?',
            hintStyle: GoogleFonts.inter(color: AppTheme.textPrimary),
            border: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Text('OUTPUT (JAPANESE)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8).withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _isTranslating 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(_translationResult.isEmpty ? '最寄りの駅はどこですか？' : _translationResult, 
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildHeaderWithIcon(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildDataBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: child,
    );
  }
}
