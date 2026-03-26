import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Admin Panel maintains its own screens within main.dart or via package imports.
// Removed incorrect relative imports to mobile app directories.

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wayfarer Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8), // Match screenshot background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E2E46), // Dark slate
          primary: const Color(0xFF1E2E46),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController(text: 'admin@wayfarer.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  String? _error;

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api'));

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      
      final token = response.data['token'];
      final user = response.data['user'];

      if (user['role'] == 'admin') {
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (ctx) => AdminDashboard(token: token, adminName: user['name']))
          );
        }
      } else {
        setState(() => _error = 'Access denied. You are not an admin.');
      }
    } catch (e) {
      setState(() => _error = 'Login failed. Please check your credentials.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12), 
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)), 
                child: const Text('W', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 28))
              ),
              const SizedBox(height: 24),
              Text('Wayfarer Control', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 48),
              _buildField('Email', _emailController, false),
              const SizedBox(height: 20),
              _buildField('Password', _passwordController, true),
              if (_error != null) ...[
                const SizedBox(height: 20), 
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Authorize Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              // SKIP LOGIN BUTTON FOR PROTOTYPING
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   Navigator.pushReplacement(
                     context, 
                     MaterialPageRoute(builder: (ctx) => const AdminDashboard(token: 'mock', adminName: 'Admin Portal'))
                   );
                },
                child: const Text('Skip Login (Dev View)', style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, 
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final String token;
  final String adminName;
  const AdminDashboard({super.key, required this.token, required this.adminName});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<dynamic> _trips = [];
  List<dynamic> _users = [];
  
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:5000/api',
      headers: {'Authorization': 'Bearer ${widget.token}'}
    ));
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dashRes = await _dio.get('/admin/dashboard');
      final tripsRes = await _dio.get('/admin/trips');
      final usersRes = await _dio.get('/admin/users');
      
      if (mounted) {
        setState(() {
          _stats = dashRes.data;
          _trips = tripsRes.data['trips'] ?? [];
          _users = usersRes.data['users'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTrip(String id) async {
    try {
      await _dio.delete('/admin/trips/$id');
      _fetchData();
    } catch (e) {}
  }

  Future<void> _deleteUser(String id) async {
    try {
      await _dio.delete('/admin/users/$id');
      _fetchData();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        backgroundColor: const Color(0xFFE85D04),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.refresh, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedIndex == 0) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: _buildHeroBanner()),
                              const SizedBox(width: 24),
                              Expanded(flex: 1, child: _buildStatCard()),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Trips', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                              InkWell(
                                onTap: () => setState(() => _selectedIndex = 1),
                                child: Text('View All Records', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _trips.take(4).map((trip) {
                                return Container(
                                  width: 280,
                                  margin: const EdgeInsets.only(right: 24),
                                  child: _buildTripCard(trip),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                        
                        if (_selectedIndex == 1 || _selectedIndex == 2) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedIndex == 1 ? 'Trips Management' : 'Data Logs', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildContentTable(),
                          const SizedBox(height: 100),
                        ],

                        if (_selectedIndex == 3) ...[
                          Text('Users Management', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          const SizedBox(height: 24),
                          _buildUsersTable(),
                          const SizedBox(height: 100),
                        ],

                        if (_selectedIndex == 4) ...[
                          Text('Country Guides Repository', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          const SizedBox(height: 24),
                          _buildContentTable(),
                          const SizedBox(height: 100),
                        ],

                        if (_selectedIndex == 5) ...[
                          Text('System Notifications', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          const SizedBox(height: 24),
                          _buildContentTable(),
                          const SizedBox(height: 100),
                        ],
                        if (_selectedIndex == 6) ...[
                          Text('Traveler Journals', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          const SizedBox(height: 24),
                          _buildContentTable(),
                          const SizedBox(height: 100),
                        ],
                        if (_selectedIndex == 7) ...[
                          Text('Platform Analytics', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                          const SizedBox(height: 24),
                          _buildContentTable(),
                          const SizedBox(height: 100),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff, color: Color(0xFFE85D04), size: 24),
                const SizedBox(width: 16),
                Text('Wayfarer', style: GoogleFonts.outfit(color: const Color(0xFF1E2E46), fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('MANAGEMENT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueGrey, letterSpacing: 1.0)),
          ),
          const SizedBox(height: 12),
          _buildNavItem(0, Icons.grid_view, 'Dashboard'),
          _buildNavItem(1, Icons.business_center_outlined, 'Trips'),
          _buildNavItem(3, Icons.people_outline, 'Users'),
          _buildNavItem(4, Icons.map_outlined, 'Guides'),
          _buildNavItem(5, Icons.notifications_none_outlined, 'Alerts'),
          _buildNavItem(6, Icons.book_outlined, 'Journals'),
          _buildNavItem(7, Icons.favorite_border, 'Followers'),
          
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('ACCOUNT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueGrey, letterSpacing: 1.0)),
          ),
          const SizedBox(height: 12),
          _buildSignOutItem(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE2E8FF) : Colors.transparent, // Light blue pill
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF1E2E46) : const Color(0xFF475569), size: 20),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(color: active ? const Color(0xFF1E2E46) : const Color(0xFF475569), fontWeight: active ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignOutItem() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const AdminLoginScreen()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 20),
            const SizedBox(width: 16),
            Text('Sign Out', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.notifications_none, color: Color(0xFF475569), size: 22),
          const SizedBox(width: 24),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE2E8FF)), child: const Icon(Icons.person, color: Color(0xFF1E2E46), size: 16)),
              const SizedBox(width: 12),
              Text(widget.adminName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E2E46))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final activeUsers = _stats?['activeUsers'] ?? 0;
    final totalTrips = _stats?['totalTrips'] ?? 0;
    
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E46),
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1200'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF1E2E46).withValues(alpha: 0.85), BlendMode.multiply),
        )
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('SYSTEM OVERVIEW', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFFDBA74), letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Text('Welcome back, Admin', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Your platform currently hosts $activeUsers active travelers across\n$totalTrips planned trips.', style: GoogleFonts.inter(fontSize: 15, color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    final newUsers = _stats?['newUsersThisWeek'] ?? 0;
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFFFF0E5), shape: BoxShape.circle),
                child: const Icon(Icons.people, color: Color(0xFFE85D04), size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                child: Text('This Week', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
              ),
            ],
          ),
          const Spacer(),
          Text('$newUsers', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46), height: 1.0)),
          const SizedBox(height: 8),
          Text('New Registrations', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    String location = trip['destination'] ?? 'Unknown';
    String user = trip['userId']?['name'] ?? 'Unknown User';
    String status = (trip['status'] ?? 'PENDING').toString().toUpperCase();
    String imageUrl = (trip['coverImage'] != null && trip['coverImage'].toString().isNotEmpty) 
      ? trip['coverImage'] 
      : 'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?q=80&w=400';
    
    Color badgeBg = Colors.white;
    Color badgeText = const Color(0xFF1E2E46);
    if (status == 'PENDING') badgeBg = Colors.white.withValues(alpha: 0.9);
    if (status == 'COMPLETED') badgeBg = Colors.green.shade100;
    
    return Container(
      height: 280,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey)),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                    child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: badgeText, letterSpacing: 0.5)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: const Color(0xFFE2E8F0), backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${user.replaceAll(" ", "+")}&background=random')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), maxLines: 1),
                          Text(location, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)), maxLines: 1),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('TRIP ID: ${trip['_id'].toString().substring(0, 6)}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                    const Spacer(),
                    InkWell(
                      onTap: () => _deleteTrip(trip['_id']),
                      child: const Icon(Icons.delete, size: 16, color: Colors.red)
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('DESTINATION & USER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('BUDGET', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                SizedBox(width: 80, child: Text('ACTIONS', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ..._trips.map((trip) {
            return Column(
              children: [
                _buildTripTableRow(trip, () => _deleteTrip(trip['_id'])),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ]
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('NAME & EMAIL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('ROLE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
                SizedBox(width: 80, child: Text('ACTIONS', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ..._users.map((user) {
            return Column(
              children: [
                _buildUserTableRow(user, () => _deleteUser(user['_id'])),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ]
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTripTableRow(dynamic trip, VoidCallback onDelete) {
    String location = trip['destination'] ?? 'Unknown';
    String user = trip['userId']?['name'] ?? 'Unknown User';
    String status = (trip['status'] ?? 'PENDING').toString().toUpperCase();
    String budget = trip['budget']?.toString() ?? 'N/A';
    String img = (trip['coverImage'] != null && trip['coverImage'].toString().isNotEmpty) 
      ? trip['coverImage'] 
      : 'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?q=80&w=150';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(img, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 48, height: 48, color: Colors.grey))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), maxLines: 1),
                      Text(user, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE2E8FF), borderRadius: BorderRadius.circular(16)),
                child: Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
              ),
            )
          ),
          Expanded(
            flex: 2,
            child: Text('\$$budget', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserTableRow(dynamic user, VoidCallback onDelete) {
    String name = user['name'] ?? 'Unknown';
    String email = user['email'] ?? 'No Email';
    String role = (user['role'] ?? 'user').toString().toUpperCase();
    bool isActive = user['isActive'] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFE2E8F0), backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${name.replaceAll(" ", "+")}&background=random')),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), maxLines: 1),
                      Text(email, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: role == 'ADMIN' ? const Color(0xFFFEF08A) : const Color(0xFFE2E8FF), borderRadius: BorderRadius.circular(16)),
                child: Text(role, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
              ),
            )
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(16)),
                child: Text(isActive ? 'ACTIVE' : 'INACTIVE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF166534) : const Color(0xFF991B1B))),
              ),
            )
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
