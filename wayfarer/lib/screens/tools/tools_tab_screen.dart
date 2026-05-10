import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/wayfarer_app_bar.dart';
import '../../providers/translation_provider.dart';
import '../../services/tts_service.dart';

class ToolsTabScreen extends StatefulWidget {
  const ToolsTabScreen({super.key});

  @override
  State<ToolsTabScreen> createState() => _ToolsTabScreenState();
}

class _ToolsTabScreenState extends State<ToolsTabScreen> {
  final TextEditingController _leftCurrencyController = TextEditingController(text: '1.00');
  final TextEditingController _rightCurrencyController = TextEditingController(text: '0.92');

  String _leftCurrency = 'USD';
  String _rightCurrency = 'EUR';
  bool _isUpdatingFromLeft = true;
  bool _isProcessing = false;

  final TextEditingController _translationInputController = TextEditingController(text: 'Where is the nearest station?');
  String _selectedSourceLang = 'English';
  String _selectedTargetLang = 'Japanese';

  final Map<String, String> _languages = {
    'English': 'en', 'Japanese': 'ja', 'Spanish': 'es', 'French': 'fr', 'German': 'de',
    'Chinese': 'zh-cn', 'Korean': 'ko', 'Indonesian': 'id', 'Italian': 'it', 'Russian': 'ru',
    'Portuguese': 'pt', 'Arabic': 'ar', 'Dutch': 'nl', 'Turkish': 'tr', 'Thai': 'th', 'Vietnamese': 'vi',
  };

  @override
  void initState() {
    super.initState();
    _leftCurrencyController.addListener(_onLeftCurrencyChanged);
    _rightCurrencyController.addListener(_onRightCurrencyChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().fetchRates(_leftCurrency);
    });
  }

  @override
  void dispose() {
    _leftCurrencyController.removeListener(_onLeftCurrencyChanged);
    _rightCurrencyController.removeListener(_onRightCurrencyChanged);
    _leftCurrencyController.dispose();
    _rightCurrencyController.dispose();
    _translationInputController.dispose();
    super.dispose();
  }

  void _onLeftCurrencyChanged() {
    if (!_isUpdatingFromLeft) return;
    _calculateConversion(true);
  }

  void _onRightCurrencyChanged() {
    if (_isUpdatingFromLeft) return;
    _calculateConversion(false);
  }

  void _calculateConversion(bool fromLeft) {
    if (_isProcessing) return;
    final cp = context.read<CurrencyProvider>();
    _isProcessing = true;
    if (fromLeft) {
      final text = _leftCurrencyController.text.replaceAll(',', '');
      final amount = double.tryParse(text) ?? 0.0;
      final result = cp.convert(amount, _leftCurrency, _rightCurrency);
      _rightCurrencyController.text = result.toString();
    } else {
      final text = _rightCurrencyController.text.replaceAll(',', '');
      final amount = double.tryParse(text) ?? 0.0;
      final result = cp.convert(amount, _rightCurrency, _leftCurrency);
      _leftCurrencyController.text = result.toString();
    }
    _isProcessing = false;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _leftCurrency;
      _leftCurrency = _rightCurrency;
      _rightCurrency = temp;

      final tempVal = _leftCurrencyController.text;
      _isUpdatingFromLeft = false;
      _leftCurrencyController.text = _rightCurrencyController.text;
      _isUpdatingFromLeft = true;
      _rightCurrencyController.text = tempVal;
    });
  }

  Future<void> _translateText() async {
    final text = _translationInputController.text;
    final from = _languages[_selectedSourceLang]!;
    final to = _languages[_selectedTargetLang]!;
    await context.read<TranslationProvider>().translate(text, from, to);
  }

  Future<void> _speak() async {
    final tts = context.read<TtsService>();
    final tp = context.read<TranslationProvider>();
    if (tp.translatedText.isNotEmpty) {
      await tts.speak(tp.translatedText, _languages[_selectedTargetLang]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WayfarerAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'QUICK UTILITY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Traveler Utility Tools',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Essential utilities designed for the modern nomad. High-precision tools to navigate the world with effortless clarity.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 48),
                _buildCurrencyConverterSection(),
                const SizedBox(height: 48),
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
        ),
      ],
    );
  }

  Widget _buildCurrencyConverterSection() {
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
              Text(
                'LIVE RATES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Currency Converter',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E2E46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Instant conversion for 150+ global currencies with real-time exchange API.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildCurrencyInputBox(true),
              const SizedBox(height: 16),
              Center(
                child: IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.sync, color: Color(0xFF94A3B8), size: 32),
                ),
              ),
              const SizedBox(height: 16),
              _buildCurrencyInputBox(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInputBox(bool isLeft) {
    final controller = isLeft ? _leftCurrencyController : _rightCurrencyController;
    final currency = isLeft ? _leftCurrency : _rightCurrency;
    final cp = context.watch<CurrencyProvider>();
    final allCurrencies = cp.rates.keys.toList()..sort();
    if (allCurrencies.isEmpty) allCurrencies.addAll(['USD', 'EUR', 'JPY', 'GBP', 'AUD', 'CAD']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: isLeft ? Border.all(color: const Color(0xFF1E2E46), width: 1.5) : null,
      ),
      child: Row(
        children: [
          if (!isLeft) ...[
            _buildCurrencyDropdown(allCurrencies, currency, (val) {
              setState(() {
                _rightCurrency = val!;
                _calculateConversion(true);
              });
            }),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)),
              textAlign: isLeft ? TextAlign.left : TextAlign.right,
              onTap: () => _isUpdatingFromLeft = isLeft,
              decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00', isDense: false, contentPadding: EdgeInsets.zero),
            ),
          ),
          if (isLeft) ...[
            const SizedBox(width: 16),
            _buildCurrencyDropdown(allCurrencies, currency, (val) {
              setState(() {
                _leftCurrency = val!;
                _calculateConversion(true);
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown(List<String> currencies, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currencies.contains(value) ? value : currencies.first,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C)),
          onChanged: onChanged,
          items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        ),
      ),
    );
  }

  Widget _buildBudgeterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 28, color: Color(0xFF1E2E46)),
          const SizedBox(height: 32),
          Text('Budgeter', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text('Track expenses, manage shared funds, and allocate your travel budget with precision across your entire journey.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.budgeter),
            child: Text('MANAGE BUDGETS >', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTranslation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Text Translation', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Text('Real-time voice and text translation for global communication. Break language barriers with effortless clarity.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.6)),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _buildLangDropdown(true)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.swap_horiz, color: Color(0xFF94A3B8))),
            Expanded(child: _buildLangDropdown(false)),
          ],
        ),
        const SizedBox(height: 32),
        _buildTranslationBox('INPUT', _translationInputController, false),
        const SizedBox(height: 16),
        Consumer<TranslationProvider>(
          builder: (context, tp, _) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFFA6BCDB).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tp.translatedText, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _speak,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up_outlined, size: 24, color: Color(0xFF132F5C)),
                            const SizedBox(width: 12),
                            Text('read loud', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF132F5C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: tp.isLoading ? null : _translateText,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                    child: tp.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('TRANSLATE', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLangDropdown(bool isSource) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isSource ? _selectedSourceLang : _selectedTargetLang,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
          borderRadius: BorderRadius.circular(8),
          onChanged: (val) {
            if (val != null) setState(() { if (isSource) _selectedSourceLang = val; else _selectedTargetLang = val; });
          },
          items: _languages.keys.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
        ),
      ),
    );
  }

  Widget _buildTranslationBox(String label, TextEditingController controller, bool isOutput) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: isOutput ? const Color(0xFFA6BCDB).withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: isOutput ? null : Border.all(color: const Color(0xFFF1F5F9))),
          child: TextField(
            controller: controller,
            maxLines: null,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: isOutput ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF0F172A)),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
          ),
        ),
      ],
    );
  }

  Widget _buildWorldWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(Icons.cloud_outlined, color: Color(0xFF1E40AF), size: 28), const SizedBox(width: 12), Text('World Weather', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))]),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.3,
          children: [_buildWeatherItem('London', '14°C', 'CLOUDY', Icons.cloud), _buildWeatherItem('Tokyo', '22°C', 'SUNNY', Icons.wb_sunny), _buildWeatherItem('New York', '18°C', 'SHOWERS', Icons.beach_access), _buildWeatherItem('Sydney', '24°C', 'CLEAR', Icons.wb_twilight)],
        ),
      ],
    );
  }

  Widget _buildWeatherItem(String city, String temp, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(city, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)))), Icon(icon, size: 20, color: const Color(0xFF132F5C))]),
          const Spacer(),
          FittedBox(fit: BoxFit.scaleDown, child: Text(temp, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))),
          const SizedBox(height: 2),
          Text(status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildWorldTimeZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(Icons.access_time, color: Color(0xFF1E40AF), size: 28), const SizedBox(width: 12), Text('World Time Zones', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))]),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.2,
          children: [_buildTimeZoneItem('PARIS (CET)', '10:42 AM'), _buildTimeZoneItem('DUBAI (GST)', '01:42 PM'), _buildTimeZoneItem('SINGAPORE (SGT)', '05:42 PM'), _buildTimeZoneItem('LOS ANGELES (PST)', '01:42 AM')],
        ),
      ],
    );
  }

  Widget _buildTimeZoneItem(String city, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(city, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(time, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
