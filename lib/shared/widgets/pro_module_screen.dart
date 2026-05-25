import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FieldConfig {
  final String keyName;
  final String label;
  final bool number;
  final int maxLines;
  final List<String>? options;

  const FieldConfig({
    required this.keyName,
    required this.label,
    this.number = false,
    this.maxLines = 1,
    this.options,
  });
}

class ProModuleScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String table;
  final String buttonText;
  final List<FieldConfig> fields;
  final Map<String, dynamic> extraData;

  const ProModuleScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.table,
    required this.buttonText,
    required this.fields,
    this.extraData = const {},
  });

  @override
  State<ProModuleScreen> createState() => _ProModuleScreenState();
}

class _ProModuleScreenState extends State<ProModuleScreen> {
  final formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();

  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> dropdownValues = {};

  bool loading = false;
  bool listLoading = false;
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();

    for (final field in widget.fields) {
      if (field.options == null) {
        controllers[field.keyName] = TextEditingController();
      } else {
        dropdownValues[field.keyName] = field.options!.first;
      }
    }

    fetchRecords();
  }

  Future<void> fetchRecords() async {

  setState(() => listLoading = true);

  final user = Supabase.instance.client.auth.currentUser;

  try {

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user?.id ?? '')
        .single();

    final role = profile['role'];

    dynamic data;

    /// ADMIN VIEW
    if (role == 'society_admin' ||
        role == 'super_admin') {

      data = await Supabase.instance.client
          .from(widget.table)
          .select()
          .eq('admin_id', user?.id ?? '')
          .order('created_at', ascending: false);

    } else {

      /// RESIDENT VIEW
      data = await Supabase.instance.client
          .from(widget.table)
          .select()
          .eq('user_id', user?.id ?? '')
          .order('created_at', ascending: false);
    }

    records =
        List<Map<String, dynamic>>.from(data);

  } catch (_) {

    records = [];
  }

  if (mounted) {
    setState(() => listLoading = false);
  }
}
  Future<void> saveData() async {

  if (!formKey.currentState!.validate()) return;

  setState(() => loading = true);

  final user =
      Supabase.instance.client.auth.currentUser;

  try {

    String? adminId;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user?.id ?? '')
        .single();

    final role = profile['role'];

    /// ADMIN
    if (role == 'society_admin' ||
        role == 'super_admin') {

      adminId = user?.id;

    } else {

      /// RESIDENT
      final resident = await Supabase.instance.client
          .from('resident_requests')
          .select()
          .eq('user_id', user?.id ?? '')
          .maybeSingle();

      adminId = resident?['admin_id'];
    }

    final Map<String, dynamic> data = {

      'admin_id': adminId,

      'user_id': user?.id,

      ...widget.extraData,
    };

    for (final field in widget.fields) {

      if (field.options == null) {

        final value =
        controllers[field.keyName]!.text.trim();

        data[field.keyName] =
        field.number
            ? num.tryParse(value) ?? 0
            : value;

      } else {

        data[field.keyName] =
        dropdownValues[field.keyName];
      }
    }

    await Supabase.instance.client
        .from(widget.table)
        .insert(data);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFF16A34A),

        content: Text(
          '${widget.title} saved successfully',
        ),
      ),
    );

    for (final c in controllers.values) {
      c.clear();
    }

    await fetchRecords();

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString()),
      ),
    );
  }

  if (mounted) {
    setState(() => loading = false);
  }
}

  Future<void> deleteRecord(String id) async {
    try {
      await Supabase.instance.client.from(widget.table).delete().eq('id', id);
      await fetchRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Record deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) return records;

    return records.where((record) {
      return record.values.any(
        (value) => value.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        header(),
        const SizedBox(height: 24),
        formCard(),
        const SizedBox(height: 24),
        recordsCard(),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: Colors.white, size: 60),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formCard() {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: cardDecoration(),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;

                return Wrap(
                  spacing: 16,
                  runSpacing: 18,
                  children: widget.fields.map((field) {
                    final width = isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                    return SizedBox(
                      width: field.maxLines > 1 ? constraints.maxWidth : width,
                      child: field.options == null
                          ? textField(field)
                          : dropdownField(field),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : saveData,
                icon: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  loading ? 'Saving...' : widget.buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recordsCard() {
    final data = filteredRecords;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded, color: Color(0xFF38BDF8)),
              const SizedBox(width: 10),
              const Text(
                'Saved Records',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: fetchRecords,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration('Search records...').copyWith(
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 20),
          if (listLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (data.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No records found',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Column(
              children: data.map(recordTile).toList(),
            ),
        ],
      ),
    );
  }

  Widget recordTile(Map<String, dynamic> record) {
    final visibleFields = widget.fields.take(4).toList();

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
            child: Icon(widget.icon, color: const Color(0xFF38BDF8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 20,
              runSpacing: 8,
              children: visibleFields.map((field) {
                return SizedBox(
                  width: 220,
                  child: Text(
                    '${field.label}: ${record[field.keyName] ?? '-'}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            onPressed: () => deleteRecord(record['id'].toString()),
            icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget textField(FieldConfig field) {
    return TextFormField(
      controller: controllers[field.keyName],
      maxLines: field.maxLines,
      keyboardType: field.number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: (v) =>
          v == null || v.trim().isEmpty ? '${field.label} is required' : null,
      decoration: inputDecoration(field.label),
    );
  }

  Widget dropdownField(FieldConfig field) {
    return DropdownButtonFormField<String>(
      value: dropdownValues[field.keyName],
      dropdownColor: const Color(0xFF0F172A),
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(field.label),
      items: field.options!
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => dropdownValues[field.keyName] = value);
      },
    );
  }

  InputDecoration inputDecoration(String label) {
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

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF1E293B)),
    );
  }
}
