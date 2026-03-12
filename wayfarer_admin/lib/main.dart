import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wayfarer Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppTheme.lightCard,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.flight, color: AppTheme.primaryColor, size: 32),
                      const SizedBox(width: 12),
                      Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Admin Panel', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavItem(0, Icons.dashboard, 'Dashboard Analytics'),
                _buildNavItem(1, Icons.people, 'User Management'),
                _buildNavItem(2, Icons.map, 'Trips Overview'),
                _buildNavItem(3, Icons.warning_amber, 'API Health'),
                const Spacer(),
                const Divider(),
                _buildNavItem(4, Icons.logout, 'Admin Logout'),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: AppTheme.lightBg,
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary),
      title: Text(title, style: GoogleFonts.inter(color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Top Navbar
        Container(
          height: 80,
          color: AppTheme.lightCard,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getTabTitle(), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.textSecondary),
                  const SizedBox(width: 24),
                  const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                  const SizedBox(width: 24),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  String _getTabTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard Overview';
      case 1: return 'User Management';
      case 2: return 'Trips & Bookings Overview';
      case 3: return 'API Services Health Map';
      default: return 'Wayfarer Admin';
    }
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardOverview();
      case 1: return _buildUserManagement();
      case 2: return _buildTripsOverview();
      case 3: return _buildApiHealth();
      default: return const Center(child: Text('Not Implemented'));
    }
  }

  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('Total Users', '12,450', '+12%', Icons.people),
              const SizedBox(width: 24),
              _buildStatCard('Active Trips', '842', '+5%', Icons.flight_takeoff),
              const SizedBox(width: 24),
              _buildStatCard('Journals Created', '3,210', '+18%', Icons.book),
              const SizedBox(width: 24),
              _buildStatCard('Avg Response Time', '120ms', '-3%', Icons.speed),
            ],
          ),
          const SizedBox(height: 32),
          
          // Demo Users Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Travelers', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: const Text('View All Users')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: AppTheme.lightBorder), borderRadius: BorderRadius.circular(8)),
                    child: DataTable(
                      headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        _buildUserRow('Alex Rivers', 'alex@example.com', 'User', 'Active'),
                        _buildUserRow('Sarah Chen', 'sarah@example.com', 'User', 'Active'),
                        _buildUserRow('System Admin', 'admin@wayfarer.com', 'Admin', 'Active'),
                        _buildUserRow('John Doe', 'john@example.com', 'User', 'Suspended'),
                      ],
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

  Widget _buildUserManagement() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Card(
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.all(24),
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Registered Users', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Add User'))
                  ],
                ),
             ),
             const Divider(height: 1),
             Expanded(
               child: ListView(
                 padding: const EdgeInsets.all(24),
                 children: [
                   Container(
                    decoration: BoxDecoration(border: Border.all(color: AppTheme.lightBorder), borderRadius: BorderRadius.circular(8)),
                    child: DataTable(
                      headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        _buildUserRow('Alex Rivers', 'alex@example.com', 'User', 'Active'),
                        _buildUserRow('Sarah Chen', 'sarah@example.com', 'User', 'Active'),
                        _buildUserRow('System Admin', 'admin@wayfarer.com', 'Admin', 'Active'),
                        _buildUserRow('John Doe', 'john@example.com', 'User', 'Suspended'),
                        _buildUserRow('Emma Watson', 'emma@wayfarer.com', 'User', 'Active'),
                        _buildUserRow('Chris Evans', 'chris@wayfarer.com', 'User', 'Pending'),
                        _buildUserRow('Developer Test', 'dev@wayfarer.com', 'User', 'Active'),
                      ],
                    ),
                  ),
                 ]
               ),
             )
          ],
        )
      ),
    );
  }

  Widget _buildTripsOverview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Trips Overview', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Global map of active trips will appear here.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
        ],
      )
    );
  }
  
  Widget _buildApiHealth() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3rd Party API Status', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildApiRow('Open Meteo (Weather)', 'Operational', '99.9%', '24ms'),
                const Divider(),
                _buildApiRow('MongoDB Database', 'Operational', '100%', '12ms'),
                const Divider(),
                _buildApiRow('RestCountries & Teleport', 'Warning', '98.2%', '1240ms'),
                const Divider(),
                _buildApiRow('MapTiler / OSM', 'Operational', '99.8%', '85ms'),
              ]
            )
        )
      )
    );
  }

  Widget _buildApiRow(String name, String status, String uptime, String latency) {
    bool isOp = status == 'Operational';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Icon(isOp ? Icons.check_circle : Icons.warning, color: isOp ? AppTheme.successColor : AppTheme.warningColor),
               const SizedBox(width: 12),
               Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              Text('Uptime: $uptime', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              const SizedBox(width: 24),
              Text('Latency: $latency', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isOp ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Text(status, style: GoogleFonts.inter(fontSize: 12, color: isOp ? AppTheme.successColor : AppTheme.warningColor, fontWeight: FontWeight.w600))
              )
            ]
          )
        ]
      )
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon) {
    bool isPositive = change.startsWith('+');
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                  Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: isPositive ? AppTheme.successColor : AppTheme.errorColor),
                  const SizedBox(width: 4),
                  Text(change, style: GoogleFonts.inter(fontSize: 12, color: isPositive ? AppTheme.successColor : AppTheme.errorColor)),
                  Text(' vs last month', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildUserRow(String name, String email, String role, String status) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
        DataCell(Text(email, style: GoogleFonts.inter(color: AppTheme.textSecondary))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: role == 'Admin' ? AppTheme.warningColor.withValues(alpha: 0.1) : AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(role, style: GoogleFonts.inter(fontSize: 12, color: role == 'Admin' ? AppTheme.warningColor : AppTheme.infoColor)),
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Active' ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status, style: GoogleFonts.inter(fontSize: 12, color: status == 'Active' ? AppTheme.successColor : AppTheme.errorColor)),
        )),
        DataCell(Row(
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}, color: AppTheme.textMuted),
            IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () {}, color: AppTheme.errorColor),
          ],
        )),
      ],
    );
  }
}
