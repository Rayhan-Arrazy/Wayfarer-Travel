import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';

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
  
  final List<ItineraryActivity> _itinerary = [];
  final _activityTitleController = TextEditingController();
  final _activityTimeController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _activityTitleController.dispose();
    _activityTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('WAYFARER', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF1E2E46), letterSpacing: 1.0)),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80'),
            ),
          ),
        ],
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
                      _buildDateTile(_departureController, () => _selectDate(context, _departureController, true)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('RETURN'),
                      _buildDateTile(_returnController, () => _selectDate(context, _returnController, false)),
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
            _buildQuickChecklist(),
            
            const SizedBox(height: 32),
            _buildFieldLabel('BUILD ITINERARY'),
            const SizedBox(height: 8),
            _buildItinerarySection(),
            
            const SizedBox(height: 48),
            if (_isSaving) 
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleCreateTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2E46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('INITIALIZE JOURNEY', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E2E46),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E2E46),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Widget _buildDateTile(TextEditingController controller, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? 'mm/dd/yyyy' : controller.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: controller.text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E2E46),
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChecklist() {
    return Column(
      children: _checklistItems.map((item) {
        final isSelected = _selectedChecklist.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedChecklist.remove(item);
              } else {
                _selectedChecklist.add(item);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF1E2E46) : Colors.transparent,
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {Widget? prefix}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(hintText: hint, prefixIcon: prefix, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
      ),
    );
  }

  Widget _buildCounterField(String title, String subtitle, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(onPressed: () => value > 0 ? onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$value', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle)),
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
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Text(type, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.black : Colors.grey)),
      ),
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      children: [
        ..._itinerary.map((act) => _buildActivityTile(act)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
          child: Column(
            children: [
              TextField(
                controller: _activityTitleController,
                decoration: const InputDecoration(hintText: 'Activity (e.g. Louvre)', border: InputBorder.none),
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: _activityTimeController, decoration: const InputDecoration(hintText: 'Time', border: InputBorder.none))),
                  TextButton(onPressed: _addActivity, child: const Text('Add')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(ItineraryActivity act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${act.time} - ${act.title}'),
          IconButton(onPressed: () => setState(() => _itinerary.remove(act)), icon: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }

  void _addActivity() {
    if (_activityTitleController.text.isEmpty) return;
    setState(() {
      _itinerary.add(ItineraryActivity(title: _activityTitleController.text, time: _activityTimeController.text, location: ''));
      _activityTitleController.clear();
      _activityTimeController.clear();
    });
  }

  Future<void> _handleCreateTrip() async {
    if (_destinationController.text.isEmpty) return;
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final tp = context.read<TripProvider>();
    final trip = TripModel(
      id: '',
      userId: auth.user?.id ?? 'guest',
      destination: _destinationController.text,
      countryCode: 'US',
      countryName: 'United States',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      partySize: _adults + _children,
      itinerary: _itinerary,
    );
    final success = await tp.createTrip(trip);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context);
    }
  }
}
