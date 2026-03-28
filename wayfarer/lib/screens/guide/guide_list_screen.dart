import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/guide_provider.dart';
import '../../models/guide_model.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideProvider>().fetchGuides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final guideProvider = context.watch<GuideProvider>();
    final guides = guideProvider.guides;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 24, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
          ),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF1E2E46))),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: guideProvider.isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 14, color: Color(0xFF1E40AF)),
                  const SizedBox(width: 8),
                  Text('GLOBAL DIRECTORY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E40AF), letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Travel Guides', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Text('Embark on a curated journey through diverse landscapes and heritages. Select a guide to begin your journey.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5)),
            const SizedBox(height: 32),
            
            if (guides.isEmpty)
              const Center(child: Text('No guides available yet.'))
            else
              ...guides.map((guide) => _buildGuideCard(context, guide)),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, CountryGuideModel guide) {
    return GestureDetector(
      onTap: () {}, // Detail navigation if needed
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(guide.coverImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(guide.name, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(guide.description, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8), height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
