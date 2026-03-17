import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final ApiService _api = ApiService();
  final _amountController = TextEditingController(text: '100');
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'JPY';
  double _rate = 150.0;
  double _result = 15000.0;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 10),
              Text('Currency', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text('REAL-TIME EXCHANGE RATES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),
              
              const SizedBox(height: 40),
              _buildConverterCard(),
              
              const SizedBox(height: 32),
              Text('Budget Insights', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildInsightCard(),
              
              const SizedBox(height: 32),
              Text('Popular Pairs', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildPair('USD/EUR', '0.92', true),
              _buildPair('GBP/USD', '1.27', false),
              _buildPair('USD/IDR', '15,640', true),
            ],
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
          if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          IconButton(onPressed: _fetchRates, icon: const Icon(Icons.refresh, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildInputRow(_fromCurrency, _amountController, true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GestureDetector(
              onTap: _swap,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.swap_vert, color: Colors.white),
              ),
            ),
          ),
          _buildResultRow(_toCurrency, _result),
        ],
      ),
    );
  }

  Widget _buildInputRow(String code, TextEditingController controller, bool isInput) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (val) => _convert(),
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Text(code, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildResultRow(String code, double value) {
    return Row(
      children: [
        Expanded(
          child: Text(value.toStringAsFixed(2), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Text(code, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          Text('Local Power', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('USD is strong against JPY right now. Good time to book your stays!',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPair(String pair, String rate, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(pair, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          Row(
            children: [
              Text(rate, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 16, color: isUp ? Colors.green : Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
