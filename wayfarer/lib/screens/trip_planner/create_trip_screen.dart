import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _destinationController = TextEditingController();
  final _departureController = TextEditingController();
  final _returnController = TextEditingController();
  
  int _adults = 2;
  int _children = 0;
  String _selectedTripType = 'SOLO';

  final List<String> _checklistItems = ['Book Flights', 'Get Visa', 'Buy Insurance'];
  final Set<String> _selectedChecklist = {};

  @override
  void dispose() {
    _destinationController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF1E2E46))),
        title: Text('WAYFARER', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF1E2E46), letterSpacing: 1.0)),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NEW ADVENTURE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Plan a New Journey', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Text(
              'Define your next destination and let our engine craft an editorial itinerary just for you.',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), height: 1.5),
            ),
            
            const SizedBox(height: 48),
            
            _buildFieldLabel('DESTINATION'),
            _buildTextField(_destinationController, 'Search cities, regions or country', prefix: const Icon(Icons.search, size: 20)),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('DEPARTURE'),
                      _buildTextField(_departureController, 'mm/dd/yyyy', prefix: const Icon(Icons.calendar_today, size: 20), suffix: const Icon(Icons.calendar_month, size: 20)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('RETURN'),
                      _buildTextField(_returnController, 'mm/dd/yyyy', prefix: const Icon(Icons.calendar_today, size: 20), suffix: const Icon(Icons.calendar_month, size: 20)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildFieldLabel('TRAVELERS'),
            _buildCounterField('Adults', '18+ years', _adults, (val) => setState(() => _adults = val)),
            const SizedBox(height: 12),
            _buildCounterField('Children', '0-17 years', _children, (val) => setState(() => _children = val)),
            
            const SizedBox(height: 32),
            _buildFieldLabel('TRIP TYPE'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
              children: [
                _buildTripTypeButton('SOLO'),
                _buildTripTypeButton('COUPLE'),
                _buildTripTypeButton('FAMILY'),
                _buildTripTypeButton('GROUP'),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildFieldLabel('QUICK CHECKLIST ITEMS'),
            ..._checklistItems.map((item) => _buildChecklistItem(item)),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF475569),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('INITIALIZE TRIP', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text('SECURE AI PROCESSING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.5)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {Widget? prefix, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCounterField(String title, String subtitle, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => value > 0 ? onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B), size: 24),
              ),
              const SizedBox(width: 8),
              Text('$value', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle, color: Color(0xFF475569), size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeButton(String type) {
    final isSelected = _selectedTripType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTripType = type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Text(type, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
      ),
    );
  }

  Widget _buildChecklistItem(String item) {
    final isSelected = _selectedChecklist.contains(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) _selectedChecklist.add(item);
                else _selectedChecklist.remove(item);
              });
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: const Color(0xFF475569),
          ),
          const SizedBox(width: 12),
          Text(item, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
        ],
      ),
    );
  }
}
