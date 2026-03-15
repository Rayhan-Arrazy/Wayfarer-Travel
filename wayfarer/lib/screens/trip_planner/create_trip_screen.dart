import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destController = TextEditingController();
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  final ApiService _api = ApiService();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  int _partySize = 1;
  String _selectedCountryCode = '';
  List<dynamic> _countrySuggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _destController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _searchCountries(String query) async {
    if (query.length < 2) {
      setState(() => _countrySuggestions = []);
      return;
    }
    try {
      final response = await _api.searchCountries(query);
      final List data = response.data;
      setState(() {
        _countrySuggestions = data.take(8).toList();
      });
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.lightCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountryCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country from suggestions'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _api.createTrip({
        'destination': _destController.text.trim(),
        'countryCode': _selectedCountryCode,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'partySize': _partySize,
        'notes': _notesController.text.trim(),
        'budget': {
          'amount': double.tryParse(_budgetController.text) ?? 0,
          'currency': 'USD',
        },
      });

      if (mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip created successfully! ✈️'), backgroundColor: AppTheme.successColor),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trip: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Plan a Trip', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination section
              Text('Where are you going?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Destination Country',
                  prefixIcon: Icon(Icons.public, color: AppTheme.textMuted),
                  hintText: 'e.g. Japan, France, Thailand',
                ),
                onChanged: _searchCountries,
                validator: (v) => v == null || v.isEmpty ? 'Destination is required' : null,
              ),
              
              // Country suggestions
              if (_countrySuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightBorder),
                  ),
                  child: Column(
                    children: _countrySuggestions.map<Widget>((c) {
                      final name = c['name']?['common'] ?? '';
                      final code = c['cca2'] ?? '';
                      final flag = c['flags']?['png'] ?? '';
                      return ListTile(
                        dense: true,
                        leading: flag.isNotEmpty
                            ? Image.network(flag, width: 28, height: 18, fit: BoxFit.cover)
                            : const Icon(Icons.flag, size: 20, color: AppTheme.textMuted),
                        title: Text(name, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: Text(code, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        onTap: () {
                          _destController.text = name;
                          setState(() {
                            _selectedCountryCode = code;
                            _countrySuggestions = [];
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 24),

              // Travel Dates
              Text('Travel Dates', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker('Start Date', _startDate, () => _selectDate(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker('End Date', _endDate, () => _selectDate(false)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('${_endDate.difference(_startDate).inDays} days trip',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Party Size
              Text('Party Size', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: AppTheme.textMuted),
                        const SizedBox(width: 12),
                        Text('Travelers', style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCounterButton(Icons.remove, () {
                          if (_partySize > 1) setState(() => _partySize--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$_partySize', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        ),
                        _buildCounterButton(Icons.add, () => setState(() => _partySize++)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Budget
              Text('Budget (optional)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Estimated Budget (USD)',
                  prefixIcon: Icon(Icons.attach_money, color: AppTheme.textMuted),
                ),
              ),

              const SizedBox(height: 24),

              // Notes
              Text('Notes (optional)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Trip notes...',
                  prefixIcon: Icon(Icons.note, color: AppTheme.textMuted),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Create Trip ✈️', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(date),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primaryColor),
      ),
    );
  }
}
