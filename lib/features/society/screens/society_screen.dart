import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocietyScreen extends StatefulWidget {
  const SocietyScreen({super.key});

  @override
  State<SocietyScreen> createState() => _SocietyScreenState();
}

class _SocietyScreenState extends State<SocietyScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool saving = false;
  bool showForm = false;

  Map<String, dynamic>? existingSociety;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final buildingsController = TextEditingController();
  final floorsController = TextEditingController();
  final unitsController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final blockController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final infraController = TextEditingController();

  String? societyType;
  String? buildingType;
  String? unitType;

  static const societyTypes = ['Residential', 'Commercial', 'Mixed', 'Gated Community'];
  static const buildingTypes = ['Apartment Tower', 'Flats', 'Houses', 'Villas', 'Mixed Buildings'];
  static const unitTypes = ['Apartments', 'Flats', 'Houses', 'Mixed Units'];

  @override
  void initState() {
    super.initState();
    fetchSociety();
  }

  Future<void> fetchSociety() async {
    setState(() => loading = true);
    final user = supabase.auth.currentUser;

    try {
      final data = await supabase
          .from('societies')
          .select()
          .eq('admin_id', user?.id ?? '')
          .maybeSingle();

      existingSociety = data;
    } catch (_) {
      existingSociety = null;
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> saveSociety() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);

    final user = supabase.auth.currentUser;

    try {
      await supabase.from('profiles').upsert({
        'id': user?.id,
        'full_name': user?.userMetadata?['full_name'] ?? user?.email,
        'email': user?.email,
        'role': 'society_admin',
      });

      await supabase.from('societies').insert({
        'admin_id': user?.id,
        'name': nameController.text.trim(),
        'society_type': societyType,
        'building_type': buildingType,
        'unit_type': unitType,
        'total_buildings': int.tryParse(buildingsController.text) ?? 0,
        'total_floors': int.tryParse(floorsController.text) ?? 0,
        'total_units': int.tryParse(unitsController.text) ?? 0,
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'area': areaController.text.trim(),
        'latitude': double.tryParse(latController.text),
        'longitude': double.tryParse(lngController.text),
        'infrastructure_details':
            'Blocks: ${blockController.text.trim()}\n${infraController.text.trim()}',
        'is_active': true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Society registered successfully!'),
        ),
      );

      await fetchSociety();
      setState(() => showForm = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }

    if (mounted) setState(() => saving = false);
  }

  Future<void> deleteSociety(String id) async {
    try {
      await supabase.from('societies').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Society deleted successfully'),
        ),
      );
      await fetchSociety();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    // Society exists — show society profile card
    if (existingSociety != null && !showForm) {
      return _buildSocietyProfile();
    }

    // No society or admin clicked register new
    return _buildRegisterForm();
  }

  // ── SOCIETY PROFILE VIEW ──────────────────────────────────────
  Widget _buildSocietyProfile() {
    final s = existingSociety!;

    return ListView(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF0F172A)],
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 60),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['name'] ?? 'Society',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✓ Active',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s['society_type'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: () => _confirmDelete(s['id'].toString()),
                icon: const Icon(Icons.delete_rounded, color: Colors.white54),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Stats row
        Row(
          children: [
            _statTile('Buildings', s['total_buildings']?.toString() ?? '0', Icons.domain_rounded),
            const SizedBox(width: 16),
            _statTile('Floors', s['total_floors']?.toString() ?? '0', Icons.layers_rounded),
            const SizedBox(width: 16),
            _statTile('Units', s['total_units']?.toString() ?? '0', Icons.door_front_door_rounded),
          ],
        ),

        const SizedBox(height: 24),

        // Details card
        _infoCard('Society Details', [
          _infoRow(Icons.category_rounded, 'Building Type', s['building_type'] ?? '-'),
          _infoRow(Icons.home_rounded, 'Unit Type', s['unit_type'] ?? '-'),
          _infoRow(Icons.location_city_rounded, 'City', s['city'] ?? '-'),
          _infoRow(Icons.map_rounded, 'Area', s['area'] ?? '-'),
          _infoRow(Icons.location_on_rounded, 'Address', s['address'] ?? '-'),
        ]),

        const SizedBox(height: 16),

        _infoCard('Infrastructure', [
          _infoRow(
            Icons.construction_rounded,
            'Details',
            s['infrastructure_details'] ?? '-',
          ),
          if (s['latitude'] != null)
            _infoRow(
              Icons.my_location_rounded,
              'Coordinates',
              '${s['latitude']}, ${s['longitude']}',
            ),
        ]),

        const SizedBox(height: 24),

        // Register another society button
        OutlinedButton.icon(
          onPressed: () => setState(() => showForm = true),
          icon: const Icon(Icons.add_rounded, color: Color(0xFF38BDF8)),
          label: const Text(
            'Register Another Society',
            style: TextStyle(color: Color(0xFF38BDF8)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2563EB)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF38BDF8), size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Delete Society?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete your society. All linked data will remain.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSociety(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── REGISTER FORM ─────────────────────────────────────────────
  Widget _buildRegisterForm() {

  return Material(
    color: Colors.transparent,

    child: SizedBox.expand(
      child: Form(
        key: formKey,

        child: ListView(
          padding: EdgeInsets.zero,

          children: [

            // Header
            Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),

                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF0F172A),
                  ],
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.maps_home_work_rounded,
                    color: Colors.white,
                    size: 60,
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          'Register New Society',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Create a complete digital society profile.',

                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (existingSociety != null)
                    IconButton(
                      onPressed: () {

                        setState(() {
                          showForm = false;
                        });
                      },

                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BASIC INFO
            _sectionCard(
              title: 'Basic Information',
              icon: Icons.apartment_rounded,

              children: [

                Row(
                  children: [

                    Expanded(
                      child: _field(
                        'Society Name',
                        nameController,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _dropdown(
                        'Society Type',
                        societyType,
                        societyTypes,

                        (v) {

                          setState(() {
                            societyType = v;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: _dropdown(
                        'Building Type',
                        buildingType,
                        buildingTypes,

                        (v) {

                          setState(() {
                            buildingType = v;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _dropdown(
                        'Unit Type',
                        unitType,
                        unitTypes,

                        (v) {

                          setState(() {
                            unitType = v;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // STRUCTURE
            _sectionCard(
              title: 'Structure Details',
              icon: Icons.domain_rounded,

              children: [

                Row(
                  children: [

                    Expanded(
                      child: _field(
                        'Total Buildings',
                        buildingsController,
                        number: true,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _field(
                        'Total Floors',
                        floorsController,
                        number: true,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _field(
                        'Total Units',
                        unitsController,
                        number: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _field(
                  'Block Names / Sections',
                  blockController,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // LOCATION
            _sectionCard(
              title: 'Location',
              icon: Icons.location_on_rounded,

              children: [

                _field(
                  'Complete Address',
                  addressController,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: _field(
                        'City',
                        cityController,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _field(
                        'Area',
                        areaController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: _optionalField(
                        'Latitude',
                        latController,
                        number: true,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _optionalField(
                        'Longitude',
                        lngController,
                        number: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INFRASTRUCTURE
            _sectionCard(
              title: 'Infrastructure Details',
              icon: Icons.construction_rounded,

              children: [

                _optionalField(
                  'Security, CCTV, Lifts, Parking, etc.',
                  infraController,
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed:
                    saving ? null : saveSociety,

                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),

                label: Text(
                  saving
                      ? 'Saving...'
                      : 'Register Society',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}
  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF38BDF8)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {bool number = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
      decoration: _inputDecoration(label),
    );
  }

  Widget _optionalField(String label, TextEditingController controller, {bool number = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Colors.white),
      validator: (v) => v == null ? '$label is required' : null,
      decoration: _inputDecoration(label),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF020617),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}