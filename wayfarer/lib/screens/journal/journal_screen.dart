import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../config/theme.dart';

class JournalScreen extends StatefulWidget {
  final String? tripId;
  const JournalScreen({super.key, this.tripId});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final selectedTrip = tripProvider.selectedTrip;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF97316),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT ADVENTURE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text(selectedTrip?.destination ?? 'My Adventures', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, height: 1.1)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge('12 Days'),
                const SizedBox(width: 8),
                _buildBadge('42 Entries'),
              ],
            ),
            const SizedBox(height: 24),

            // Hero Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 220, width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80'), // Golden Pavilion
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)])),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Text('KINKAKU-JI, KYOTO', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.0)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('The Golden Pavilion at Dawn', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                        const SizedBox(height: 8),
                        Text('The reflection on the water was perfectly still this morning. A moment of absolute Zen befo...', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mood & Gallery Stats row
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 100, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFFFFF6ED), shape: BoxShape.circle),
                              child: const Icon(Icons.sentiment_satisfied, color: Color(0xFFF97316), size: 18),
                            ),
                            Text('AVG MOOD', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Serene', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const Spacer(),
                        Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)), child: Align(alignment: Alignment.centerLeft, child: Container(width: 80, decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(2))))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 100, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E2E46), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.camera, color: Colors.white, size: 18),
                            ),
                            Text('GALLERY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 0.5)),
                          ],
                        ),
                        const Spacer(),
                        Text('128', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Captures this week', style: GoogleFonts.inter(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Visual Timeline
            Text('Visual Timeline', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 24),

            // Item 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineDate('NOV', '14'),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arashiyama Bamboo Grove', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text('08:30 AM', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text('Ukyo Ward', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text("Woke up early to beat the crowds to the Bamboo Forest. The sound of the stalks swaying in the wind is something I'll never forget—a deep, hollow clacking that feels like the forest is whispering. We found a small tea house nearby that served the most incredible matcha.", style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppTheme.textSecondary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTag('#NATURE'),
                          const SizedBox(width: 8),
                          _buildTag('#SERENITY'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: 'https://images.unsplash.com/photo-1542259145-813ab5bf4eaf?w=400&q=80', height: 120, fit: BoxFit.cover))),
                          const SizedBox(width: 12),
                          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: 'https://images.unsplash.com/photo-1576404289891-95c514781cf9?w=400&q=80', height: 120, fit: BoxFit.cover))),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                )
              ],
            ),

            // Item 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineDate('NOV', '13'),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(left: BorderSide(color: Color(0xFF1E2E46), width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lost in Gion Districts', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                        const SizedBox(height: 12),
                        Text('"The lanterns started flickering to life as dusk settled. We saw a Geiko hurrying into a tea house—the sound of her wooden geta sandals echoing on the stone pavement was the only sound in the narrow alley."', style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 14, color: Color(0xFFF97316)),
                            const SizedBox(width: 6),
                            Text('Highlight of the Trip', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFF97316))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: 'https://images.unsplash.com/photo-1624253321171-1be53e12f5f4?w=600&q=80', height: 140, width: double.infinity, fit: BoxFit.cover)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 48),

            // Journaling Tools Bottom Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Journaling Tools', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                  const SizedBox(height: 4),
                  Text('Enhance your memories with smart analysis', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildToolBtn(Icons.mic, 'AUDIO LOG'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildToolBtn(Icons.auto_awesome, 'AI SUMMARY'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildToolBtn(Icons.share, 'EXPORT PDF'),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 100), // FAB padding
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
    );
  }

  Widget _buildTimelineDate(String month, String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.lightBorder)),
      child: Column(
        children: [
          Text(month, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          Text(day, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
    );
  }

  Widget _buildToolBtn(IconData icon, String label) {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 16),
       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]),
       child: Column(
         children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
             child: Icon(icon, color: AppTheme.primaryColor, size: 18),
           ),
           const SizedBox(height: 12),
           Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: 0.5)),
         ],
       ),
    );
  }
}
