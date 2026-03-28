import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinentDetailScreen extends StatelessWidget {
  final String continent;
  const ContinentDetailScreen({super.key, required this.continent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCultureSection(),
                  const SizedBox(height: 64),
                  _buildHistorySection(),
                  const SizedBox(height: 64),
                  _buildTopPlacesSection(),
                  const SizedBox(height: 64),
                  _buildHowToAdaptSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 480,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1535139262971-c51845bb398f?w=1200'), // Large Globe/Continent
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('EDITORIAL NOTES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(continent, style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            'A tapestry of ancient wisdom, hyper-modern cities, and landscapes that redefine the sublime. Welcome to the heart of the world.',
            style: GoogleFonts.inter(fontSize: 18, color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCultureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outlined, color: Color(0xFF1E40AF), size: 28),
            const SizedBox(width: 12),
            Text('Culture & People', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Asia culture is not a single entity but a vibrant mosaic of thousands of ethnic groups, languages, and belief systems. From the hypnotic chanting of monks in Bhutan to the frenetic energy of a Tokyo intersection, the human landscape is as varied as the geography.',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), height: 1.7),
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Community First',
          'Unlike the Western focus on individualism, many Asian cultures prioritize the collective. Respect for elders and social harmony are foundational values that dictate daily interaction.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Spiritual Roots',
          'Religion and philosophy — Buddhism, Hinduism, Islam, Shinto, and Confucianism — are deeply woven into the fabric of life, influencing everything from architecture to cuisine.',
        ),
        const SizedBox(height: 32),
        Text(
          'Traveling through Asia means participating in this living history, whether it\'s sharing a meal on a low plastic stool in Hanoi or witnessing the delicate tea ceremonies of Kyoto. The "people" component is what transforms a trip into a journey.',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), height: 1.7, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 12),
          Text(description, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_edu, color: Color(0xFF1E40AF), size: 28),
            const SizedBox(width: 12),
            Text('History', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Asia is the cradle of civilization. Its history is marked by the rise and fall of massive empires — the Mongols, the Mughals, the Khmers, and the Dynasties of China — which have left behind architectural wonders that defy modern logic.',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), height: 1.7),
        ),
        const SizedBox(height: 32),
        _buildBulletPoint('The Silk Road Era', 'The ancient network of trade routes that connected East and West, facilitating not just silk and spices, but the exchange of ideas and technologies.'),
        const SizedBox(height: 24),
        _buildBulletPoint('The Golden Age of Empires', 'The construction of Angkor Wat, the Great Wall, and the Taj Mahal — monuments that signaled unparalleled wealth and engineering prowess.'),
        const SizedBox(height: 24),
        _buildBulletPoint('The Modern Renaissance', 'Post-colonial recovery and the rapid technological leapfrog that has turned cities like Singapore and Seoul into blueprints for the future.'),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Icon(Icons.square, size: 8, color: Color(0xFF1E40AF)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Text(desc, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Color(0xFF1E40AF), size: 28),
            const SizedBox(width: 12),
            Text('Top Places & Destinations', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 32),
        _buildPlaceCard('Kyoto, Japan', 'the spiritual heart of Japan, where centuries-old traditions meet Zen gardens.', 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800'),
        const SizedBox(height: 16),
        _buildPlaceCard('Ha Long Bay', 'Emerald water and towering limestone peaks covered in rainforest.', 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800'),
        const SizedBox(height: 16),
        _buildPlaceCard('Ubud, Bali', 'Lush paddy fields and sacred temples where tradition remains timeless.', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800'),
      ],
    );
  }

  Widget _buildPlaceCard(String title, String desc, String imageUrl) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildHowToAdaptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security_outlined, color: Color(0xFF1E40AF), size: 28),
            const SizedBox(width: 12),
            Text('How to Adapt', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildAdaptItem(Icons.restaurant, 'Street Food Literacy', 'Don\'t be afraid of street stalls. Look for high turnover and local crowds — it\'s usually fresher and more authentic than buffets.'),
              const Divider(height: 32),
              _buildAdaptItem(Icons.front_hand, 'Non-Verbal Etiquette', 'In many regions, touching someone\'s head is taboo while pointing with your feet is deeply offensive. Observe before you act.'),
              const Divider(height: 32),
              _buildAdaptItem(Icons.payments, 'The Cash & Coin Balance', 'While China is almost entirely cashless (QR based), many parts of Japan and rural Southeast Asia still rely heavily on physical currency.'),
              const Divider(height: 32),
              _buildAdaptItem(Icons.wb_sunny, 'Pace Management', 'The heat and humidity in the tropics can be taxing. Adopt the local "siesta" habit — explore early and late, rest during the mid-day peak.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF1E2E46).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF1E2E46), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
