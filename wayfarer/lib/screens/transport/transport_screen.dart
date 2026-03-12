import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final ApiService _api = ApiService();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  List<dynamic> _transitStops = [];
  bool _isLoadingTransit = false;
  bool _isLoadingRoute = false;
  Map<String, dynamic>? _routeData;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadTransitStops() async {
    setState(() => _isLoadingTransit = true);
    try {
      final response = await _api.getTransitStops(-6.2088, 106.8456, radius: 1000);
      setState(() {
        _transitStops = response.data['stops'] ?? [];
        _isLoadingTransit = false;
      });
    } catch (e) {
      setState(() => _isLoadingTransit = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransitStops();
  }

  Future<void> _findRoutes() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both From and To locations'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }
    setState(() => _isLoadingRoute = true);
    try {
      // Geocode both locations
      final fromRes = await _api.searchPlaces(_fromController.text);
      final toRes = await _api.searchPlaces(_toController.text);
      final List fromResults = fromRes.data;
      final List toResults = toRes.data;

      if (fromResults.isEmpty || toResults.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find one or both locations'), backgroundColor: AppTheme.errorColor),
          );
        }
        setState(() => _isLoadingRoute = false);
        return;
      }

      final fromLat = double.parse(fromResults[0]['lat'].toString());
      final fromLng = double.parse(fromResults[0]['lon'].toString());
      final toLat = double.parse(toResults[0]['lat'].toString());
      final toLng = double.parse(toResults[0]['lon'].toString());

      final routeRes = await _api.getRoute(fromLat, fromLng, toLat, toLng);
      setState(() {
        _routeData = routeRes.data;
        _isLoadingRoute = false;
      });
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Transport', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Planner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route Planner', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _fromController,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'From location',
                      prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.accentColor, size: 18),
                      filled: true,
                      fillColor: AppTheme.lightBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _toController,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'To location',
                      prefixIcon: const Icon(Icons.location_on, color: AppTheme.errorColor, size: 18),
                      filled: true,
                      fillColor: AppTheme.lightBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingRoute ? null : _findRoutes,
                      icon: _isLoadingRoute
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.directions, size: 18),
                      label: Text(_isLoadingRoute ? 'Searching...' : 'Find Routes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Route Result
            if (_routeData != null) ...
              _buildRouteResult(),
            
            // Flight Deals
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cheapest Flight Calendar', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Find the best dates to fly to your destination', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor, size: 16),
                ],
              ),
            ),

            // Transport Options
            Text('Transport Options', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTransportOption(Icons.flight, 'Flight', const Color(0xFF64B5F6)),
                const SizedBox(width: 10),
                _buildTransportOption(Icons.train, 'Train', const Color(0xFF4DB6AC)),
                const SizedBox(width: 10),
                _buildTransportOption(Icons.directions_bus, 'Bus', const Color(0xFFFFB74D)),
                const SizedBox(width: 10),
                _buildTransportOption(Icons.directions_car, 'Drive', const Color(0xFFBA68C8)),
              ],
            ),
            const SizedBox(height: 24),

            // Nearby Transit
            Text('Nearby Transit Stops', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            _isLoadingTransit
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ))
                : _transitStops.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('No transit stops found nearby', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                        ),
                      )
                    : Column(
                        children: _transitStops.take(10).map<Widget>((stop) => _buildTransitStop(stop)).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportOption(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitStop(dynamic stop) {
    final name = stop['name'] ?? 'Unknown Stop';
    final type = stop['type'] ?? 'stop';
    final routes = stop['routes'] ?? '';

    IconData icon = Icons.directions_bus;
    Color color = AppTheme.warningColor;
    if (type.contains('station') || type.contains('railway')) {
      icon = Icons.train;
      color = const Color(0xFF4DB6AC);
    } else if (type.contains('tram')) {
      icon = Icons.tram;
      color = const Color(0xFFBA68C8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                if (routes.isNotEmpty)
                  Text('Routes: $routes', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }

  List<Widget> _buildRouteResult() {
    final summary = _routeData?['features']?[0]?['properties']?['summary'] ?? {};
    final distance = summary['distance'];
    final duration = summary['duration'];

    return [
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Text('Route Found', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentColor)),
              ],
            ),
            const SizedBox(height: 12),
            if (distance != null)
              Row(
                children: [
                  const Icon(Icons.straighten, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${(distance / 1000).toStringAsFixed(1)} km',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            if (duration != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(duration.toDouble()),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ];
  }

  String _formatDuration(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    if (hours > 0) return '${hours}h ${minutes}m';
    return '$minutes min';
  }
}
