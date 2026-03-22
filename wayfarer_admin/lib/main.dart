import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF0F172A),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))]
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
              Text('SECURE ADMINISTRATIVE ACCESS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade300, letterSpacing: 1.5)),
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
                    elevation: 0
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Authorize Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
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
  late final Dio _dio;
  
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<dynamic> _users = [];
  List<dynamic> _trips = [];

  bool _isSystemHealthy = true;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:5000/api',
      headers: {'Authorization': 'Bearer ${widget.token}'}
    ));
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await _dio.get('/admin/dashboard');
      final usersRes = await _dio.get('/admin/users');
      final tripsRes = await _dio.get('/admin/trips');
      
      try {
        final health = await _dio.get('/health');
        _isSystemHealthy = health.data['status'] == 'OK';
      } catch (_) {
        _isSystemHealthy = false;
      }
      
      setState(() {
        _stats = statsRes.data;
        _users = usersRes.data['users'];
        _trips = tripsRes.data['trips'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Sync Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: _buildCurrentView(),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selectedIndex == 0 ? 'All-in-One Dashboard' : _getViewTitle(), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(_selectedIndex == 0 ? 'Welcome back, ${widget.adminName.split(' ')[0]}. Here\'s what\'s happening today.' : 'Manage your system records', style: GoogleFonts.inter(fontSize: 14, color: Colors.blueGrey)),
            ],
          ),
          Row(
            children: [
              Container(
                width: 300,
                height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search data...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.blueGrey.shade300),
                    prefixIcon: Icon(Icons.search, size: 18, color: Colors.blueGrey.shade300),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Quick Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getViewTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Users';
      case 2: return 'Content';
      case 3: return 'Reports';
      default: return 'Wayfarer Admin';
    }
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0: return _buildOverview();
      case 1: return _buildUserList();
      case 2: return _buildTripList();
      default: return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserManagementGrid(),
                  const SizedBox(height: 32),
                  _buildRecentUserTrips(),
                ],
              )),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSystemStatusCard(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                ],
              )),
            ],
          ),
          const SizedBox(height: 32),
          _buildEstablishmentsTable(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('Active Users', _stats['totalUsers']?.toString() ?? '0', '+12%', Icons.people_outline, positive: true),
        const SizedBox(width: 24),
        _buildStatCard('Total Trips', _stats['activeTrips']?.toString() ?? '0', '+5.4%', Icons.map_outlined, positive: true),
        const SizedBox(width: 24),
        _buildStatCard('Revenue [MTD]', '\$412,850', '+21%', Icons.attach_money, positive: true),
        const SizedBox(width: 24),
        _buildStatCard('Server Uptime', '99.98%', 'Stable', Icons.bolt, positive: false),
      ],
    );
  }

  Widget _buildUserList() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Management', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Export CSV')),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, __) => const Divider(height: 32, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, i) => _buildUserRow(_users[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2
            ),
            itemCount: _trips.length,
            itemBuilder: (ctx, i) => _buildTripCard(_trips[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(dynamic trip) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                trip['coverImage'] ?? 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?q=80&w=400',
                width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trip['destination'] ?? 'Undefined', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildStatusChip(trip['status'] ?? 'unknown'),
                  ],
                ),
                const SizedBox(height: 4),
                Text('By ${trip['userId']['name']}', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text('${trip['partySize']} members', style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    Text('\$${trip['budget']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final newStatus = trip['status'] == 'active' ? 'completed' : 'active';
                        await _dio.put('/admin/trips/${trip['_id']}', data: {'status': newStatus});
                        _refreshAll();
                      }, 
                      icon: const Icon(Icons.swap_horiz, size: 14),
                      label: Text(trip['status'] == 'active' ? 'Mark Completed' : 'Make Active', style: const TextStyle(fontSize: 11)),
                    ),
                    IconButton(
                      onPressed: () async {
                        final confirmed = await _showConfirmDelete();
                        if (confirmed) {
                          await _dio.delete('/admin/trips/${trip['_id']}');
                          _refreshAll();
                        }
                      }, 
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.blue;
    if (status == 'active') color = Colors.green;
    if (status == 'completed') color = Colors.deepPurple;
    if (status == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUserRow(dynamic user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF0F172A),
          child: Text(user['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(user['email'], style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
          child: Text(user['role'].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        ),
        const SizedBox(width: 40),
        Text(user['createdAt'].toString().substring(0, 10), style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
        const SizedBox(width: 40),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                final newRole = user['role'] == 'admin' ? 'user' : 'admin';
                await _dio.put('/admin/users/${user['_id']}', data: {'role': newRole});
                _refreshAll();
              }, 
              icon: Icon(
                user['role'] == 'admin' ? Icons.verified_user : Icons.shield_outlined, 
                size: 20, 
                color: user['role'] == 'admin' ? Colors.green : Colors.blue
              )
            ),
            IconButton(
              onPressed: () async {
                final confirmed = await _showConfirmDelete();
                if (confirmed) {
                  await _dio.delete('/admin/users/${user['_id']}');
                  _refreshAll();
                }
              }, 
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red)
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _showConfirmDelete() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('This will permanently erase the user and all linked data. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Erase Permanently')),
        ],
      ),
    ) ?? false;
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, {bool positive = true}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: positive || subtitle.startsWith('+') ? Colors.green.withOpacity(0.1) : const Color(0xFFF1F5F9), 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(subtitle, style: TextStyle(color: positive || subtitle.startsWith('+') ? Colors.green : Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), 
                  child: const Text('W', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 20))
                ),
                const SizedBox(width: 16),
                Text('Wayfarer', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNavItem(0, Icons.home_outlined, 'Dashboard'),
          _buildNavItem(1, Icons.people_outline, 'Users'),
          _buildNavItem(2, Icons.library_books_outlined, 'Content'),
          _buildNavItem(3, Icons.bar_chart_outlined, 'Reports'),
          const Spacer(),
          _buildAdminProfile(),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: Text(widget.adminName[0].toUpperCase())),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.adminName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const Text('Root Administrator', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const AdminLoginScreen())),
            icon: const Icon(Icons.logout, color: Colors.white54, size: 18)
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementGrid() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Management', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [Text('All Roles', style: GoogleFonts.inter(fontSize: 12)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, size: 16)]),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(flex: 2, child: Text('User', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              Expanded(child: Text('Role', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              Expanded(child: Text('Join Date', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              const SizedBox(width: 100, child: Text('Actions', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            ],
          ),
          const Divider(height: 32),
          ..._users.take(3).map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(flex: 2, child: Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF1F5F9), child: Text(u['name'][0], style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A), fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text(u['email'], style: const TextStyle(fontSize: 11, color: Colors.blueGrey))])),
                  ],
                )),
                Expanded(child: Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: u['role'] == 'admin' ? Colors.blue.withOpacity(0.1) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: Text(u['role'] == 'admin' ? 'ADMIN' : 'Traveler', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: u['role'] == 'admin' ? Colors.blue : const Color(0xFF475569))),
                  ),
                )),
                Expanded(child: Text(u['createdAt'].toString().substring(0, 10), style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13))),
                SizedBox(width: 100, child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                    const SizedBox(width: 8),
                    const Text('Suspend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(width: 8),
                    const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                )),
              ],
            ),
          )),
          const Divider(height: 32),
          Center(child: TextButton(onPressed: () {}, child: const Text('View All Users', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildActivityItem('User Marcus Thorne created trip "Amalfi Escape"', '2 minutes ago', Colors.blue),
          _buildActivityItem('Database backup initiated automatically', '45 minutes ago', Colors.orange),
          _buildActivityItem('System: Failed login attempt from IP 192.x.x.x', '1 hour ago', Colors.red),
          _buildActivityItem('Sarah J. updated pricing for "Kyoto Stay"', '3 hours ago', Colors.blue),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('VIEW AUDIT LOGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6, right: 12), width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildRecentUserTrips() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent User Trips', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Monitor and moderate latest community content', style: GoogleFonts.inter(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                child: Text('Moderate All', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSmallTripCard('Amalfi Escape', 'ITALY', 'Marcus T.', 'https://images.unsplash.com/photo-1534448552109-183610931af9?q=80&w=300')),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallTripCard('Kyoto Temples', 'JAPAN', 'Yuki S.', 'https://images.unsplash.com/photo-1493976040372-50b510520638?q=80&w=300')),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallTripCard('Glacier Trek', 'ICELAND', 'Ben J.', 'https://images.unsplash.com/photo-1548186178-577e384eb1eb?q=80&w=300')),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallTripCard('Sahara Sands', 'MOROCCO', 'Sarah L.', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=300')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallTripCard(String title, String subtitle, String by, String image) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(image, height: 80, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('By $by', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstablishmentsTable() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTab('Dining', true),
                  const SizedBox(width: 24),
                  _buildTab('Accommodations', false),
                  const SizedBox(width: 24),
                  _buildTab('Transport', false),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add New Entry'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(flex: 2, child: Text('Establishment', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Category', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Location', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Rating', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(width: 80, child: Text('Actions', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(height: 32),
          _buildEstRow('The Golden Noodle', 'Casual Dining', 'Tokyo, JP', '4.8'),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          _buildEstRow('Le Petit Bistro', 'Fine Dining', 'Paris, FR', '4.5'),
          const Divider(height: 32),
          Center(child: TextButton(onPressed: () {}, child: const Text('View All Dining Entries', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
        ],
      ),
    );
  }

  Widget _buildEstRow(String name, String cat, String loc, String rating) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(child: Text(cat, style: const TextStyle(color: Colors.blueGrey, fontSize: 13))),
        Expanded(child: Text(loc, style: const TextStyle(color: Colors.blueGrey, fontSize: 13))),
        Expanded(child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))])),
        SizedBox(width: 80, child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(Icons.edit_outlined, size: 16, color: Colors.blueGrey),
            SizedBox(width: 12),
            Icon(Icons.delete_outline, size: 16, color: Colors.blueGrey),
          ],
        )),
      ],
    );
  }

  Widget _buildTab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? const Color(0xFF0F172A) : Colors.transparent, width: 2))),
      child: Text(label, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFF0F172A) : Colors.blueGrey)),
    );
  }

  Widget _buildSystemStatusCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Core Integrity', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildHealthRow('Primary Engine', _isSystemHealthy ? 'OPTIMAL' : 'OFFLINE', _isSystemHealthy ? Colors.green : Colors.red),
        const SizedBox(height: 16),
        _buildHealthRow('Identity Vault', _isSystemHealthy ? 'SYNCHRONIZED' : 'LOCKED', _isSystemHealthy ? Colors.green : Colors.orange),
        const SizedBox(height: 16),
        _buildHealthRow('Vector Records', _isSystemHealthy ? 'STABLE' : 'UNREACHABLE', _isSystemHealthy ? Colors.green : Colors.grey),
        const SizedBox(height: 16),
        _buildHealthRow('External Relays', _isSystemHealthy ? 'ACTIVE' : 'DEGRADED', _isSystemHealthy ? Colors.green : Colors.orange),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.terminal, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Text('Uptime: 142.5 hours', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }
}
