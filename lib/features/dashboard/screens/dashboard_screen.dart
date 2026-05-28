import 'package:flutter/material.dart';
import 'package:sociosphere/features/auth/screens/login_screen.dart';
import 'package:sociosphere/features/auth/services/auth_service.dart';
import 'package:sociosphere/features/society/screens/society_screen.dart';
import 'package:sociosphere/features/residents/screens/residents_screen.dart';
import 'package:sociosphere/features/complaints/screens/admin_complaints_screen.dart';
import 'package:sociosphere/features/complaints/screens/resident_complaints_screen.dart';
import 'package:sociosphere/features/maintenance/screens/admin_maintenance_screen.dart';
import 'package:sociosphere/features/maintenance/screens/resident_maintenance_screen.dart';
import 'package:sociosphere/features/vehicles/screens/admin_vehicles_screen.dart';
import 'package:sociosphere/features/vehicles/screens/resident_vehicles_screen.dart';
import 'package:sociosphere/features/notices/screens/admin_notices_screen.dart';
import 'package:sociosphere/features/notices/screens/resident_notices_screen.dart';
import 'package:sociosphere/features/emergency/screens/admin_emergency_screen.dart';
import 'package:sociosphere/features/emergency/screens/resident_emergency_screen.dart';
import 'package:sociosphere/features/resident_profile/screens/resident_profile_screen.dart';
import 'package:sociosphere/features/super_admin/screens/super_admin_dashboard_screen.dart';
import 'package:sociosphere/features/super_admin/screens/society_management_screen.dart';
import 'package:sociosphere/features/super_admin/screens/admin_management_screen.dart';
import 'package:sociosphere/features/super_admin/screens/global_complaints_screen.dart';
import 'package:sociosphere/features/super_admin/screens/analytics_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Widget screen;

  const MenuItemData({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

class _DashboardScreenState extends State<DashboardScreen> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  bool loading = true;
  int selectedIndex = 0;
  String role = 'resident';
  String societyStatus = 'approved';
  List<MenuItemData> menuItems = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

  await authService.ensureUserProfile();

  role = await authService.getUserRole();

  final user =
      supabase.auth.currentUser;

  /// CHECK ADMIN SOCIETY STATUS
  if (role == 'society_admin') {

    try {

      final society =
          await supabase
              .from('societies')
              .select()
              .eq(
                'admin_id',
                user?.id ?? '',
              )
              .maybeSingle();

      if (society != null) {

        societyStatus =
            society['status'] ??
                'pending';
      }

    } catch (e) {

      debugPrint(
        'Society Status Error: $e',
      );
    }
  }

  buildMenu();

  if (mounted) {
    setState(() => loading = false);
  }
}

  bool get isSuperAdmin => role == 'super_admin';

bool get isAdmin =>
    role == 'society_admin';

 void buildMenu() {

  /// SUPER ADMIN
  if (isSuperAdmin) {

 menuItems = [

  MenuItemData(
    title: 'Super Dashboard',

    icon:
        Icons.space_dashboard_rounded,

    screen:
        const SuperAdminDashboardScreen(),
  ),

  MenuItemData(
    title: 'Society Management',

    icon:
        Icons.apartment_rounded,

    screen:
        const SocietyManagementScreen(),
  ),

  MenuItemData(
    title: 'Admin Management',

    icon:
        Icons.admin_panel_settings_rounded,

    screen:
        const AdminManagementScreen(),
  ),

  MenuItemData(
    title: 'Global Complaints',

    icon:
        Icons.report_problem_rounded,

    screen:
        const GlobalComplaintsScreen(),
  ),

  MenuItemData(
    title: 'Analytics',

    icon:
        Icons.analytics_rounded,

    screen:
        const AnalyticsScreen(),
  ),
];

  }


  /// SOCIETY ADMIN
  else if (isAdmin &&
    societyStatus == 'approved') {

    menuItems = const [

      MenuItemData(
        title: 'Overview',
        icon: Icons.dashboard_rounded,
        screen: OverviewView(),
      ),

      MenuItemData(
        title: 'Society',
        icon: Icons.apartment_rounded,
        screen: SocietyScreen(),
      ),

      MenuItemData(
        title: 'Residents',
        icon: Icons.people_alt_rounded,
        screen: ResidentsScreen(),
      ),

      MenuItemData(
        title: 'Complaints',
        icon:
            Icons.report_problem_rounded,
        screen:
            AdminComplaintsScreen(),
      ),

      MenuItemData(
        title: 'Maintenance',
        icon: Icons.payments_rounded,
        screen:
            AdminMaintenanceScreen(),
      ),

      MenuItemData(
        title: 'Vehicles',
        icon:
            Icons.directions_car_rounded,
        screen:
            AdminVehiclesScreen(),
      ),

      MenuItemData(
        title: 'Notices',
        icon: Icons.campaign_rounded,
        screen:
            AdminNoticesScreen(),
      ),

      MenuItemData(
        title: 'Emergency',
        icon:
            Icons.emergency_rounded,
        screen:
            AdminEmergencyScreen(),
      ),
    ];

  }
  /// PENDING / BLOCKED ADMIN
else if (isAdmin &&
    societyStatus != 'approved') {

  menuItems = [

    MenuItemData(
      title: 'Approval Status',

      icon:
          Icons.pending_actions_rounded,

      screen: SocietyStatusScreen(
        status: societyStatus,
      ),
    ),
  ];
}

  /// RESIDENT
  else {

    menuItems = const [

      MenuItemData(
        title: 'Overview',
        icon: Icons.dashboard_rounded,
        screen:
            ResidentOverviewView(),
      ),

      MenuItemData(
        title: 'Join Society',
        icon:
            Icons.home_work_rounded,
        screen:
            ResidentProfileScreen(),
      ),

      MenuItemData(
        title: 'My Complaints',
        icon:
            Icons.report_problem_rounded,
        screen:
            ResidentComplaintsScreen(),
      ),

      MenuItemData(
        title: 'My Vehicles',
        icon:
            Icons.directions_car_rounded,
        screen:
            ResidentVehiclesScreen(),
      ),

      MenuItemData(
        title: 'My Bills',
        icon:
            Icons.payments_rounded,
        screen:
            ResidentMaintenanceScreen(),
      ),

      MenuItemData(
        title: 'Notices',
        icon:
            Icons.campaign_rounded,
        screen:
            ResidentNoticesScreen(),
      ),

      MenuItemData(
        title: 'Emergency',
        icon:
            Icons.emergency_rounded,
        screen:
            ResidentEmergencyScreen(),
      ),
    ];
  }
}

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return isMobile ? _buildMobileLayout(user) : _buildDesktopLayout(user);
  }

  // ── MOBILE LAYOUT ──────────────────────────────────────────────
  Widget _buildMobileLayout(user) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: Color(0xFF38BDF8), size: 26),
            SizedBox(width: 8),
            Text(
              'SocioSphere',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                (user?.email ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            color: const Color(0xFF0F172A),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: logout,
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: menuItems[selectedIndex].screen,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex >= menuItems.take(5).length ? 0 : selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: menuItems
              .take(5)
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.title,
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── DESKTOP LAYOUT ─────────────────────────────────────────────
  Widget _buildDesktopLayout(user) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(right: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.apartment_rounded, color: Color(0xFF38BDF8), size: 34),
                    SizedBox(width: 12),
                    Text(
                      'SocioSphere',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSuperAdmin
    ? 'Super Admin'
    : isAdmin
        ? 'Society Admin'
        : 'Resident',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final active = selectedIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF2563EB) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, color: active ? Colors.white : Colors.white60),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: active ? Colors.white : Colors.white60,
                                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: logout,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          menuItems[selectedIndex].title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          (user?.email ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'Welcome to SocioSphere',
                    style: const TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  Expanded(child: menuItems[selectedIndex].screen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OVERVIEW WIDGETS (kept from original) ──────────────────────────

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  Future<int> countRows(String table, {String? filterColumn, String? filterValue}) async {
    try {
      var query = Supabase.instance.client.from(table).select('id');
      final data = filterColumn == null
          ? await query
          : await query.eq(filterColumn, filterValue ?? '');
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return FutureBuilder(
      future: Future.wait([
        countRows('residents', filterColumn: 'admin_id', filterValue: user?.id),
        countRows('complaints', filterColumn: 'admin_id', filterValue: user?.id),
        countRows('vehicles', filterColumn: 'admin_id', filterValue: user?.id),
        countRows('maintenance_bills', filterColumn: 'admin_id', filterValue: user?.id),
      ]),
      builder: (context, snapshot) {
        final values = snapshot.data ?? [0, 0, 0, 0];
        return SingleChildScrollView(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 4;
                  if (constraints.maxWidth < 1200) count = 2;
                  if (constraints.maxWidth < 700) count = 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: count,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 2.2,
                    children: [
                      StatCard(title: 'Residents', value: values[0].toString(), icon: Icons.people_alt_rounded),
                      StatCard(title: 'Complaints', value: values[1].toString(), icon: Icons.report_problem_rounded),
                      StatCard(title: 'Vehicles', value: values[2].toString(), icon: Icons.directions_car_rounded),
                      StatCard(title: 'Bills', value: values[3].toString(), icon: Icons.payments_rounded),
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              const WelcomePanel(),
            ],
          ),
        );
      },
    );
  }
}

class ResidentOverviewView extends StatefulWidget {
  const ResidentOverviewView({super.key});

  @override
  State<ResidentOverviewView> createState() =>
      _ResidentOverviewViewState();
}

class _ResidentOverviewViewState
    extends State<ResidentOverviewView> {

  final supabase = Supabase.instance.client;

  bool loading = true;

  Map<String, dynamic>? resident;
  Map<String, dynamic>? society;
  Map<String, dynamic>? emergencyNotice;

  int complaints = 0;
  int vehicles = 0;
  int pendingBills = 0;
  int notices = 0;

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  Future<void> loadDashboard() async {

    final user = supabase.auth.currentUser;

    try {

      resident = await supabase
          .from('residents')
          .select()
          .eq('user_id', user?.id ?? '')
          .maybeSingle();

      if (resident != null) {

        society = await supabase
            .from('societies')
            .select()
            .eq(
              'admin_id',
              resident!['admin_id'],
            )
            .maybeSingle();

        final complaintsData =
            await supabase
                .from('complaints')
                .select()
                .eq(
                  'user_id',
                  user?.id ?? '',
                );

        complaints =
            complaintsData.length;

        final vehiclesData =
            await supabase
                .from('vehicles')
                .select()
                .eq(
                  'user_id',
                  user?.id ?? '',
                )
                .eq(
                  'status',
                  'Approved',
                );

        vehicles =
            vehiclesData.length;

        final billsData =
            await supabase
                .from(
                  'maintenance_bills',
                )
                .select()
                .eq(
                  'user_id',
                  user?.id ?? '',
                )
                .neq(
                  'payment_status',
                  'Paid',
                );

        pendingBills =
            billsData.length;

        final noticesData =
            await supabase
                .from('notices')
                .select()
                .eq(
                  'admin_id',
                  resident!['admin_id'],
                );

        notices =
            noticesData.length;

        emergencyNotice =
            await supabase
                .from('notices')
                .select()
                .eq(
                  'admin_id',
                  resident!['admin_id'],
                )
                .eq(
                  'is_emergency',
                  true,
                )
                .order(
                  'created_at',
                  ascending: false,
                )
                .limit(1)
                .maybeSingle();
      }

    } catch (e) {

      debugPrint(
        'Resident Overview Error: $e',
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: const Color(
            0xFF1E293B,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              16,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(
                0xFF2563EB,
              ).withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Icon(
              icon,
              color:
                  const Color(
                0xFF38BDF8,
              ),
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  value,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final user =
        supabase.auth.currentUser;

    if (loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [

          /// EMERGENCY ALERT
          if (emergencyNotice != null)

            Container(
              width: double.infinity,

              margin:
                  const EdgeInsets.only(
                bottom: 24,
              ),

              padding:
                  const EdgeInsets.all(
                28,
              ),

              decoration: BoxDecoration(
                color:
                    Colors.red.withOpacity(
                  0.12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
                ),

                border: Border.all(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Row(
                    children: [

                      Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 34,
                      ),

                      SizedBox(width: 14),

                      Text(
                        'Emergency Alert',

                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    emergencyNotice!['title']
                        ?? '',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    emergencyNotice!['message']
                        ?? '',

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          /// PROFILE CARD
          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(
              32,
            ),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF0F172A),
                ],
              ),
            ),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 42,

                  backgroundColor:
                      Colors.white
                          .withOpacity(0.15),

                  child: Text(
                    (resident?['full_name']
                                ??
                            'R')[0]
                        .toUpperCase(),

                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 22),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        resident?[
                                'full_name'] ??
                            'Resident',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 34,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        user?.email ?? '',

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,

                        children: [

                          chip(
                            Icons.apartment,
                            society?[
                                    'society_name'] ??
                                'No Society',
                          ),

                          chip(
                            Icons.home,
                            resident?[
                                    'unit_number'] ??
                                'No Unit',
                          ),

                          chip(
                            Icons.badge,
                            resident?[
                                    'resident_type'] ??
                                'Resident',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// STATS
          LayoutBuilder(
            builder:
                (context, constraints) {

              int count = 4;

              if (constraints.maxWidth <
                  1200) {
                count = 2;
              }

              if (constraints.maxWidth <
                  700) {
                count = 1;
              }

              return GridView.count(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisCount: count,

                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                childAspectRatio: 2.2,

                children: [

                  infoCard(
                    title: 'Complaints',

                    value:
                        complaints.toString(),

                    icon: Icons
                        .report_problem_rounded,
                  ),

                  infoCard(
                    title:
                        'Approved Vehicles',

                    value:
                        vehicles.toString(),

                    icon: Icons
                        .directions_car_rounded,
                  ),

                  infoCard(
                    title:
                        'Pending Bills',

                    value:
                        pendingBills
                            .toString(),

                    icon:
                        Icons.payments,
                  ),

                  infoCard(
                    title: 'Notices',

                    value:
                        notices.toString(),

                    icon:
                        Icons.campaign,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          /// WELCOME PANEL
          const WelcomePanel(
            title:
                'Resident Smart Portal',

            subtitle:
                'Track complaints, vehicles, notices, maintenance bills and emergency alerts from your personalized dashboard.',
          ),
        ],
      ),
    );
  }

  Widget chip(
    IconData icon,
    String text,
  ) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.1,
        ),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            text,

            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF38BDF8), size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePanel extends StatelessWidget {
  final String title;
  final String subtitle;

  const WelcomePanel({
    super.key,
    this.title = 'Smart Society Control Center',
    this.subtitle = 'Manage residents, complaints, vehicles, bills and society notices from one premium dashboard.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 16),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.2)),
        ],
      ),
    );
  }
}
class SocietyStatusScreen
    extends StatelessWidget {

  final String status;

  const SocietyStatusScreen({
    super.key,
    required this.status,
  });

  Color statusColor() {

    switch (status) {

      case 'approved':
        return Colors.green;

      case 'blocked':
        return Colors.red;

      case 'rejected':
        return Colors.orange;

      default:
        return Colors.amber;
    }
  }

  String statusTitle() {

    switch (status) {

      case 'blocked':
        return 'Society Blocked';

      case 'rejected':
        return 'Society Rejected';

      default:
        return 'Approval Pending';
    }
  }

  String statusMessage() {

    switch (status) {

      case 'blocked':

        return 'Your society has been blocked by Super Admin. Please contact platform support.';

      case 'rejected':

        return 'Your society registration was rejected by Super Admin.';

      default:

        return 'Your society is waiting for approval from Super Admin.';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 700,
        ),

        padding:
            const EdgeInsets.all(40),

        decoration: BoxDecoration(
          color:
              const Color(0xFF0F172A),

          borderRadius:
              BorderRadius.circular(
            30,
          ),

          border: Border.all(
            color:
                statusColor(),
            width: 1.5,
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Icon(
              Icons.admin_panel_settings,

              color:
                  statusColor(),

              size: 90,
            ),

            const SizedBox(height: 26),

            Text(
              statusTitle(),

              style: TextStyle(
                color:
                    statusColor(),

                fontSize: 34,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              statusMessage(),

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                color:
                    Colors.white70,

                fontSize: 16,

                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color:
                    statusColor()
                        .withOpacity(
                  0.15,
                ),

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Text(
                status.toUpperCase(),

                style: TextStyle(
                  color:
                      statusColor(),

                  fontWeight:
                      FontWeight.bold,

                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}