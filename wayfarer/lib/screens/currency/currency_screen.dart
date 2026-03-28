import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final ApiService _api = ApiService();
  final _amountController = TextEditingController(text: '1,250.00');

  String _fromCurrency = 'USD';
  String _toCurrency = 'JPY';
  String _fromName = 'US Dollar';
  String _toName = 'Japanese Yen';
  String _destinationName = 'Tokyo, Japan';
  String _destinationImage = 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=800';
  double _rate = 0;
  double _result = 0;
  bool _isLoading = false;

  final Map<String, String> _currencyNames = {
    'USD': 'US Dollar', 'EUR': 'Euro', 'GBP': 'British Pound', 'JPY': 'Japanese Yen',
    'IDR': 'Indonesian Rupiah', 'SGD': 'Singapore Dollar', 'AUD': 'Australian Dollar',
    'THB': 'Thai Baht', 'KRW': 'South Korean Won', 'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee', 'CHF': 'Swiss Franc', 'CAD': 'Canadian Dollar',
    'MYR': 'Malaysian Ringgit', 'AED': 'UAE Dirham', 'NZD': 'New Zealand Dollar',
  };

  final Map<String, String> _currencyFlags = {
    'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧', 'JPY': '🇯🇵', 'IDR': '🇮🇩', 'SGD': '🇸🇬',
    'AUD': '🇦🇺', 'THB': '🇹🇭', 'KRW': '🇰🇷', 'CNY': '🇨🇳', 'INR': '🇮🇳', 'CHF': '🇨🇭',
    'CAD': '🇨🇦', 'MYR': '🇲🇾', 'AED': '🇦🇪', 'NZD': '🇳🇿',
  };

  // Sample expenses for the prototype look
  final List<Map<String, dynamic>> _recentExpenses = [
    {'icon': Icons.restaurant, 'name': 'Ichiran Ramen', 'location': 'Shinjuku • Today', 'localAmount': '¥1,890', 'usdAmount': '\$12.60 USD'},
    {'icon': Icons.train, 'name': 'JR East Top-up', 'location': 'Suica Card • Yesterday', 'localAmount': '¥5,000', 'usdAmount': '\$33.35 USD'},
    {'icon': Icons.shopping_bag, 'name': 'Don Quijote', 'location': 'Souvenirs • Oct 24', 'localAmount': '¥8,420', 'usdAmount': '\$56.15 USD'},
  ];

  @override
  void initState() {
    super.initState();
    _initFromTrip();
  }

  void _initFromTrip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final tripProvider = context.read<TripProvider>();
      final upcoming = tripProvider.upcomingTrip;

      _fromCurrency = auth.user?.homeCurrency ?? 'USD';
      _fromName = _currencyNames[_fromCurrency] ?? _fromCurrency;

      if (upcoming != null) {
        _destinationName = upcoming.destination;
        if (upcoming.coverImage.isNotEmpty) _destinationImage = upcoming.coverImage;
        if (upcoming.destinationInfo != null && upcoming.destinationInfo!.currency.isNotEmpty) {
          _toCurrency = upcoming.destinationInfo!.currency;
          _toName = _currencyNames[_toCurrency] ?? _toCurrency;
        }
      }
      _fetchRates();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getExchangeRates(_fromCurrency, to: _toCurrency);
      final rates = response.data['rates'] as Map<String, dynamic>?;
      if (rates != null && rates.containsKey(_toCurrency)) {
        _rate = (rates[_toCurrency] as num).toDouble();
        _convert();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _convert() {
    final text = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(text) ?? 0;
    setState(() => _result = amount * _rate);
  }

  void _swap() {
    setState(() {
      final tempCode = _fromCurrency;
      final tempName = _fromName;
      _fromCurrency = _toCurrency;
      _fromName = _toName;
      _toCurrency = tempCode;
      _toName = tempName;
    });
    _fetchRates();
  }

  String _formatAmount(double val) {
    if (val >= 1000) {
      return val.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return val.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF97316),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Hero Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Currency Converter
            _buildConverterCard(),
            const SizedBox(height: 20),

            // Budget Intelligence
            _buildBudgetIntelligence(),
            const SizedBox(height: 20),

            // Recent Expenses
            _buildRecentExpenses(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: '$_destinationImage?w=800&q=80',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.35),
            colorBlendMode: BlendMode.darken,
            errorWidget: (_, __, ___) => Container(color: AppTheme.primaryColor),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT DESTINATION', style: GoogleFonts.inter(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(_destinationName, style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CURRENCY CONVERTER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.successColor, borderRadius: BorderRadius.circular(8)),
                child: Text('Live Rates', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FROM card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                // Currency badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Text(_currencyFlags[_fromCurrency] ?? '💱', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(_fromCurrency, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FROM', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
                    Text(_fromName, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _convert(),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, fillColor: Colors.transparent, filled: true),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Swap button
          GestureDetector(
            onTap: _swap,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.swap_vert, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 8),

          // TO card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Text(_currencyFlags[_toCurrency] ?? '💱', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(_toCurrency, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TO', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
                    Text(_toName, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatAmount(_result),
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
        ],
      ),
    );
  }

  Widget _buildBudgetIntelligence() {
    final dailyAvg = _rate > 100 ? (_rate * 83).round() : (_rate * 83);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2E46),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF1E2E46).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFFBBF24), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.psychology, color: Color(0xFF1E2E46), size: 16),
                ),
                const SizedBox(width: 8),
                Text('BUDGET INTELLIGENCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF93C5FD), letterSpacing: 1.0)),
              ],
            ),
            const SizedBox(height: 16),
            Text('High Affordability', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Your current savings cover 14 days of average spending in ${_destinationName.split(',').first} based on your lifestyle profile.',
              style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rate > 100 ? '¥${_formatAmount(dailyAvg.toDouble())}' : '\$${dailyAvg.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF93C5FD)),
                    ),
                    Text('DAILY AVERAGE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 0.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('View Analysis', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
          Text('RECENT ${_destinationName.split(',').first.toUpperCase()} EXPENSES',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ..._recentExpenses.map((exp) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: Icon(exp['icon'], size: 20, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp['name'], style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
                      Text(exp['location'], style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(exp['localAmount'], style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryColor)),
                    Text(exp['usdAmount'], style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
