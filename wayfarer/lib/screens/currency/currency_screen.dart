import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Top Bar matching reference
              _buildTopBar(context),

              const SizedBox(height: 10),
              Text('Tokyo, Japan', 
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('CURRENCY CONVERTER', 
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),

              const SizedBox(height: 32),

              // Currency Conversion Card
              _buildConverterCard(),

              const SizedBox(height: 24),

              // High Affordability Card
              _buildAffordabilityCard(),

              const SizedBox(height: 32),

              // Recent Tokyo Expenses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Tokyo Expenses', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildExpenseItem('Ichiran Ramen', 'September, Today', '¥1,200', 'USD 8.20'),
              _buildExpenseItem('JR East Topup', 'September, Oct 12', '¥5,000', 'USD 34.12'),
              _buildExpenseItem('Don Quijote', 'September, Oct 10', '¥2,450', 'USD 16.73'),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
          ),
          const Icon(Icons.help_outline, color: AppTheme.textPrimary, size: 24),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildCurrencyInput('USD', 'US Dollar', '1,250.00', '🇺🇸'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
            ),
          ),
          _buildCurrencyInput('JPY', 'Japanese Yen', '182,425.00', '🇯🇵'),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput(String code, String name, String value, String flag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                Text(name, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildAffordabilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('High Affordability', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your current savings cover 15 days of average spending in Tokyo based on your lifestyle profile.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¥12,400', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('Avg Daily Cost', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Analysis', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String title, String date, String amountJPY, String amountUSD) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountJPY, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text(amountUSD, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
