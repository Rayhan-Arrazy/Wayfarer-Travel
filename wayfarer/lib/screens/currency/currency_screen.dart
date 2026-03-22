import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final ApiService _api = ApiService();
  final _amountController = TextEditingController(text: '1.00');
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'JPY';
  double _rate = 149.20;
  double _result = 149.20;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getExchangeRates(_fromCurrency, to: _toCurrency);
      setState(() {
        _rate = (response.data['rates'][_toCurrency] as num).toDouble();
        _convert();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _result = amount * _rate;
    });
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildConverterSection(),
                const SizedBox(height: 24),
                _buildBudgetIntelligence(),
                const SizedBox(height: 32),
                _buildRecentExpenses(),
              ],
            ),
          ),
          
          // Floating Action Button
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFFF97316),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background Image
        SizedBox(
          height: 260,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=800',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.3),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        // Content
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CURRENT DESTINATION',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tokyo, Japan',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)]
                ),
              ),
            ],
          ),
        ),
        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CURRENCY CONVERTER',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(12)),
                child: Text('Live Rates', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _convert(),
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          ),
                          const SizedBox(height: 4),
                          Text(_fromCurrency, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_result.toStringAsFixed(2), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          const SizedBox(height: 4),
                          Text(_toCurrency, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _swap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.sync_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetIntelligence() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF1E3A5F).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF60A5FA), size: 16),
                const SizedBox(width: 8),
                Text('BUDGET INTELLIGENCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF93C5FD), letterSpacing: 1.0)),
              ],
            ),
            const SizedBox(height: 16),
            Text('High Affordability', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Your current savings cover 14 days of average spending in Tokyo based on your lifestyle profile.', 
              style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.white70)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(8)),
                  child: Text('¥12,400 DAILY AVERAGE', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text('View Analysis', style: GoogleFonts.inter(color: const Color(0xFF1E3A5F), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT TOKYO EXPENSES',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _buildExpenseItem(Icons.ramen_dining, 'Ichiran Ramen', 'Shinjuku Today', '¥1,890', '\$12.60 USD', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          _buildExpenseItem(Icons.train, 'JR East Top-up', 'Suica Card Yesterday', '¥5,000', '\$33.35 USD', const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
          _buildExpenseItem(Icons.shopping_bag, 'Don Quijote', 'Souvenirs Oct 24', '¥8,420', '\$56.15 USD', const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(IconData icon, String title, String subtitle, String amountJPY, String amountUSD, Color bg, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountJPY, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 2),
              Text(amountUSD, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}
