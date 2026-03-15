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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
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
      final role = response.data['user']['role'];

      if (role == 'admin') {
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (ctx) => AdminDashboard(token: token))
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
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)), child: const Text('W', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24))),
              const SizedBox(height: 24),
              Text('Wayfarer Admin', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800)),
              Text('ENTER YOUR CREDENTIALS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 32),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final String token;
  const AdminDashboard({super.key, required this.token});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late final Dio _dio;
  
  bool _isLoading = false;
  List<dynamic> _users = [];
  Map<String, dynamic> _stats = {
    'totalUsers': '...',
    'activeTrips': '...',
    'totalTrips': '...',
    'newUsers': '...',
  };

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
      // Real API calls
      final statsRes = await _dio.get('/admin/dashboard');
      final usersRes = await _dio.get('/admin/users');
      
      setState(() {
        _stats = {
          'totalUsers': statsRes.data['totalUsers'].toString(),
          'activeTrips': statsRes.data['activeTrips'].toString(),
          'totalTrips': statsRes.data['totalTrips'].toString(),
          'newUsers': statsRes.data['newUsersThisWeek'].toString(),
        };
        _users = usersRes.data['users'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      // Fallback
      setState(() {
        _users = [
          {'name': 'Alex Rivera', 'email': 'alex@example.com', 'role': 'traveler', 'createdAt': '2023-10-12T00:00:00'},
          {'name': 'Elena Fischer', 'email': 'elena@example.com', 'role': 'admin', 'createdAt': '2023-06-05T00:00:00'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildUserManagement()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildSystemInfo()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildRecentTrips(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: const Text('W', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B)))),
                const SizedBox(width: 12),
                Text('Wayfarer', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSidebarItem(0, Icons.grid_view, 'Dashboard'),
          _buildSidebarItem(1, Icons.people_outline, 'Users'),
          _buildSidebarItem(2, Icons.folder_open, 'Content'),
          _buildSidebarItem(3, Icons.bar_chart, 'Reports'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListTile(
              leading: const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
              title: const Text('Admin Sarah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Logout', style: TextStyle(color: Colors.white54, fontSize: 11)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const AdminLoginScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(isSelected ? 1 : 0.6), size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(isSelected ? 1 : 0.6), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Command Center', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('Real-time synchronization with Wayfarer Core.', style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 14)),
        ]),
        Row(children: [
          Container(width: 300, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueGrey.shade200)), child: const TextField(decoration: InputDecoration(icon: Icon(Icons.search, size: 20), hintText: 'Search audit logs...', border: InputBorder.none))),
          const SizedBox(width: 16),
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh))
        ]),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('Total Users', _stats['totalUsers'], 'ACTIVE', true, Icons.people),
        const SizedBox(width: 20),
        _buildStatCard('Live Trips', _stats['activeTrips'], 'TRENDING', true, Icons.map),
        const SizedBox(width: 20),
        _buildStatCard('Total Journeys', _stats['totalTrips'], 'DATABASE', true, Icons.book),
        const SizedBox(width: 20),
        _buildStatCard('Growth (Week)', _stats['newUsers'], '+NEW', true, Icons.trending_up),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String tag, bool isUp, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey.shade50)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF1E293B), size: 20)),
          Text(tag, style: TextStyle(color: isUp ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _buildUserManagement() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey.shade50)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('User Activity Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Table(
          columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(2)},
          children: [
            TableRow(children: [ _tHeader('USER'), _tHeader('ROLE'), _tHeader('DATE'), _tHeader('ACTION') ]),
            ..._users.take(5).map((u) => _uRow(u['name'], u['email'], u['role'], u['createdAt'].toString().substring(0, 10))),
          ],
        ),
      ]),
    );
  }

  Widget _tHeader(String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade400)));

  TableRow _uRow(String n, String e, String r, String d) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(e, style: const TextStyle(fontSize: 11, color: Colors.blueGrey))])),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(r.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(d, style: const TextStyle(fontSize: 12))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: const Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Icon(Icons.delete_outline, size: 16, color: Colors.red)])),
    ]);
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey.shade50)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('System Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        _HRow('Core Engine', 'ACTIVE', Colors.green),
        SizedBox(height: 12),
        _HRow('Auth Provider', 'ACTIVE', Colors.green),
        SizedBox(height: 12),
        _HRow('Proxy Server', 'DEGRADED', Colors.orange),
      ]),
    );
  }

  Widget _buildRecentTrips() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recent Global Journeys', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Row(children: [
        _TCard('Japan', 'Kyoto Escape', 'https://images.unsplash.com/photo-1493976040372-50b510520638?q=80&w=400'),
        const SizedBox(width: 20),
        _TCard('France', 'Paris Nights', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=400'),
        const SizedBox(width: 20),
        _TCard('Morocco', 'Sahara Trek', 'https://images.unsplash.com/photo-1489749798305-4fea3ae63d43?q=80&w=400'),
      ]),
    ]);
  }

  Widget _TCard(String loc, String t, String img) {
    return Expanded(child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey.shade50)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(img, height: 100, width: double.infinity, fit: BoxFit.cover)),
        Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(loc.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))])),
      ]),
    ));
  }
}

class _HRow extends StatelessWidget {
  final String n, s; final Color c;
  const _HRow(this.n, this.s, this.c);
  @override Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(n, style: const TextStyle(fontSize: 13)), Text(s, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold))]);
  }
}
