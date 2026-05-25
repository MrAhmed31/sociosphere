import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  bool loading = false;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> residents = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    final user = Supabase.instance.client.auth.currentUser;

    try {
      final reqData = await Supabase.instance.client
          .from('resident_requests')
          .select()
          .eq('admin_id', user?.id ?? '')
          .order('created_at', ascending: false);

      final resData = await Supabase.instance.client
          .from('residents')
          .select()
          .eq('admin_id', user?.id ?? '')
          .order('created_at', ascending: false);

      requests = List<Map<String, dynamic>>.from(reqData);
      residents = List<Map<String, dynamic>>.from(resData);
    } catch (_) {
      requests = [];
      residents = [];
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> approveRequest(Map<String, dynamic> request) async {
    try {
      await Supabase.instance.client.from('residents').insert({
        'admin_id': request['admin_id'],
        'user_id': request['user_id'],
        'full_name': request['full_name'],
        'cnic': request['cnic'],
        'phone': request['phone'],
        'building_name': request['building_name'],
        'floor_number': request['floor_number'],
        'unit_number': request['unit_number'],
        'resident_type': request['resident_type'],
      });

      await Supabase.instance.client
          .from('resident_requests')
          .update({'status': 'Approved'}).eq('id', request['id']);

      await fetchData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Resident approved successfully'),
        ),
      );
    } catch (e) {
      showError(e);
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      await Supabase.instance.client
          .from('resident_requests')
          .update({'status': 'Rejected'}).eq('id', id);

      await fetchData();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> removeResident(String id) async {
    try {
      await Supabase.instance.client.from('residents').delete().eq('id', id);
      await fetchData();
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        header(),
        const SizedBox(height: 24),
        requestsCard(),
        const SizedBox(height: 24),
        residentsCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0F172A)],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.white, size: 60),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resident Requests & Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Approve resident join requests and manage active residents.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget requestsCard() {
    final pending = requests.where((r) => r['status'] == 'Pending').toList();

    return card(
      title: 'Pending Join Requests',
      icon: Icons.pending_actions_rounded,
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : pending.isEmpty
              ? empty('No pending requests')
              : Column(
                  children: pending.map((r) {
                    return tile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: r['full_name'] ?? 'Resident',
                      subtitle:
                          'Unit: ${r['unit_number'] ?? '-'} • ${r['building_name'] ?? '-'} • ${r['resident_type'] ?? '-'}',
                      actions: [
                        actionButton(
                          'Approve',
                          const Color(0xFF16A34A),
                          () => approveRequest(r),
                        ),
                        const SizedBox(width: 10),
                        actionButton(
                          'Reject',
                          const Color(0xFFEF4444),
                          () => rejectRequest(r['id']),
                        ),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  Widget residentsCard() {
    return card(
      title: 'Active Residents Directory',
      icon: Icons.groups_rounded,
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : residents.isEmpty
              ? empty('No active residents yet')
              : Column(
                  children: residents.map((r) {
                    return tile(
                      icon: Icons.person_rounded,
                      title: r['full_name'] ?? 'Resident',
                      subtitle:
                          'CNIC: ${r['cnic'] ?? '-'} • Phone: ${r['phone'] ?? '-'} • Unit: ${r['unit_number'] ?? '-'}',
                      actions: [
                        IconButton(
                          onPressed: () => removeResident(r['id']),
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  Widget card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: fetchData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.2),
            child: Icon(icon, color: const Color(0xFF38BDF8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }

  Widget actionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(text),
    );
  }

  Widget empty(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(text, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF1E293B)),
    );
  }
}