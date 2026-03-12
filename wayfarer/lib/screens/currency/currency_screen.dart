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
  String _toCurrency = 'EUR';
  double _rate = 0;
  double _result = 0;
  bool _isLoading = false;
  Map<String, dynamic> _rates = {};

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'IDR', 'SGD', 'AUD', 'CAD', 'CHF', 'CNY', 'KRW', 'THB', 'MYR', 'INR', 'BRL', 'ZAR', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'TRY', 'RUB', 'PHP', 'VND', 'TWD', 'HKD', 'NZD', 'AED'];
  final List<String> _cities = ['Tokyo', 'London', 'New York', 'Paris', 'Singapore', 'Bali'];
  String _selectedCity = 'Tokyo';
  Map<String, dynamic>? _costOfLivingData;
  bool _isLoadingCol = true;

  @override
  void initState() {
    super.initState();
    _convert();
    _loadCostOfLiving();
  }

  Future<void> _loadCostOfLiving() async {
    setState(() => _isLoadingCol = true);
    try {
      final response = await _api.getCostOfLiving(_selectedCity);
      setState(() {
        _costOfLivingData = response.data;
        _isLoadingCol = false;
      });
    } catch (e) {
      setState(() => _isLoadingCol = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.convertCurrency(_fromCurrency, _toCurrency, double.tryParse(_amountController.text) ?? 100);
      final data = response.data;
      setState(() {
        _rate = (data['rate'] ?? 0).toDouble();
        _result = (data['result'] ?? 0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Currency & Finance', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Converter Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.lightBorder),
              ),
              child: Column(
                children: [
                  Text('Currency Converter', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 20),
                  
                  // Amount input
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppTheme.lightBg,
                    ),
                    onChanged: (_) => _convert(),
                  ),
                  const SizedBox(height: 16),

                  // From/To Row
                  Row(
                    children: [
                      Expanded(child: _buildCurrencyDropdown('From', _fromCurrency, (v) {
                        setState(() => _fromCurrency = v ?? _fromCurrency);
                        _convert();
                      })),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: _swap,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor, size: 22),
                          ),
                        ),
                      ),
                      Expanded(child: _buildCurrencyDropdown('To', _toCurrency, (v) {
                        setState(() => _toCurrency = v ?? _toCurrency);
                        _convert();
                      })),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Result
                  if (_isLoading)
                    const CircularProgressIndicator(color: AppTheme.primaryColor)
                  else
                    Column(
                      children: [
                        Text(
                          '${_result.toStringAsFixed(2)} $_toCurrency',
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.accentColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '1 $_fromCurrency = ${_rate.toStringAsFixed(4)} $_toCurrency',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick rates
            Text('Popular Rates', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            _buildQuickRate('USD', 'EUR', '🇺🇸', '🇪🇺'),
            _buildQuickRate('USD', 'GBP', '🇺🇸', '🇬🇧'),
            _buildQuickRate('USD', 'JPY', '🇺🇸', '🇯🇵'),
            _buildQuickRate('EUR', 'GBP', '🇪🇺', '🇬🇧'),
            _buildQuickRate('USD', 'IDR', '🇺🇸', '🇮🇩'),

            const SizedBox(height: 32),

            // Cost of Living
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cost of Living', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                DropdownButton<String>(
                  value: _selectedCity,
                  dropdownColor: AppTheme.lightSurface,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                  underline: const SizedBox(),
                  items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedCity = v);
                      _loadCostOfLiving();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCostOfLivingCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppTheme.lightSurface,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRate(String from, String to, String fromFlag, String toFlag) {
    return FutureBuilder(
      future: _api.convertCurrency(from, to, 1),
      builder: (context, snapshot) {
        final rate = snapshot.hasData ? (snapshot.data?.data['rate'] ?? 0).toDouble() : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('$fromFlag $from', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 16, color: AppTheme.textMuted),
                  ),
                  Text('$toFlag $to', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
              Text(
                snapshot.hasData ? rate.toStringAsFixed(4) : '...',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.accentColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostOfLivingCard() {
    if (_isLoadingCol) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primaryColor)));
    }

    if (_costOfLivingData == null || _costOfLivingData?['categories'] == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.lightCard, borderRadius: BorderRadius.circular(14)),
        child: Text('Data not available for $_selectedCity', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
      );
    }

    final categories = _costOfLivingData!['categories'] as List;
    final housing = categories.firstWhere((c) => c['id'] == 'HOUSING', orElse: () => {'score_out_of_10': 5})['score_out_of_10'] * 10;
    final food = categories.firstWhere((c) => c['id'] == 'COST-OF-LIVING', orElse: () => {'score_out_of_10': 5})['score_out_of_10'] * 10;
    final safety = categories.firstWhere((c) => c['id'] == 'SAFETY', orElse: () => {'score_out_of_10': 5})['score_out_of_10'] * 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        children: [
          _buildColRow(Icons.home, 'Housing Cost', housing),
          const SizedBox(height: 12),
          _buildColRow(Icons.restaurant, 'Food Cost', food),
          const SizedBox(height: 12),
          _buildColRow(Icons.health_and_safety, 'Safety Score', safety),
        ],
      ),
    );
  }

  Widget _buildColRow(IconData icon, String label, num value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 20),
        const SizedBox(width: 12),
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppTheme.lightSurface,
              color: value > 70 ? AppTheme.successColor : value > 40 ? AppTheme.warningColor : AppTheme.errorColor,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${value.toStringAsFixed(0)}/100', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ],
    );
  }
}

