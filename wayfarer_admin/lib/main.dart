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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_getViewTitle(), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          Row(
            children: [
              IconButton(onPressed: _refreshAll, icon: const Icon(Icons.refresh, color: Colors.blueGrey)),
              const SizedBox(width: 20),
              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getViewTitle() {
    switch (_selectedIndex) {
      case 0: return 'System Overview';
      case 1: return 'User Directory';
      case 2: return 'Global Expeditions';
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
              Expanded(flex: 3, child: _buildRecentUsersCard()),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildSystemStatusCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('Total Entities', _stats['totalUsers']?.toString() ?? '0', 'Users', Icons.people_outline),
        const SizedBox(width: 24),
        _buildStatCard('Active Flows', _stats['activeTrips']?.toString() ?? '0', 'Trips', Icons.airplanemode_active),
        const SizedBox(width: 24),
        _buildStatCard('Documentation', _stats['totalJournalEntries']?.toString() ?? '0', 'Journals', Icons.book_outlined),
        const SizedBox(width: 24),
        _buildStatCard('Weekly Surge', _stats['newUsersThisWeek']?.toString() ?? '0', 'New Users', Icons.trending_up),
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
              Text('Registered Identities', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(subtitle.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
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
          _buildNavItem(0, Icons.dashboard_outlined, 'Control Center'),
          _buildNavItem(1, Icons.people_outline, 'Identity Manager'),
          _buildNavItem(2, Icons.map_outlined, 'Global Expeditions'),
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

  Widget _buildRecentUsersCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity Feed', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ..._users.take(5).map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF1F5F9), child: Text(u['name'][0], style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A), fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text(u['email'], style: const TextStyle(fontSize: 11, color: Colors.blueGrey))])),
                Text(u['role'].toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
          )),
        ],
      ),
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
