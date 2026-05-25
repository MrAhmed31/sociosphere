import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEmergencyScreen extends StatefulWidget {
  const AdminEmergencyScreen({super.key});

  @override
  State<AdminEmergencyScreen> createState() =>
      _AdminEmergencyScreenState();
}

class _AdminEmergencyScreenState
    extends State<AdminEmergencyScreen> {

  final supabase = Supabase.instance.client;

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  bool loading = false;

  String category = 'Security Guard';

  final categories = [
    'Security Guard',
    'Ambulance',
    'Fire Brigade',
    'Police',
    'Maintenance Staff',
    'Other',
  ];

  List<Map<String, dynamic>>
      contacts = [];

  @override
  void initState() {
    super.initState();

    fetchContacts();
  }

  Future<void> fetchContacts() async {

    final user =
        supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('emergency_contacts')
          .select()
          .eq(
            'admin_id',
            user?.id ?? '',
          )
          .order(
            'created_at',
            ascending: false,
          );

      contacts =
          List<Map<String, dynamic>>
              .from(data);

    } catch (_) {

      contacts = [];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> saveContact() async {

    setState(() => loading = true);

    final user =
        supabase.auth.currentUser;

    try {

      await supabase
          .from('emergency_contacts')
          .insert({

        'admin_id': user?.id,

        'name':
            nameController.text.trim(),

        'phone':
            phoneController.text.trim(),

        'category': category,
      });

      nameController.clear();
      phoneController.clear();

      category = 'Security Guard';

      fetchContacts();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Emergency contact saved',
          ),
        ),
      );

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red,

          content:
              Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> deleteContact(
    String id,
  ) async {

    await supabase
        .from('emergency_contacts')
        .delete()
        .eq('id', id);

    fetchContacts();
  }

  Color categoryColor(
    String value,
  ) {

    switch (value) {

      case 'Ambulance':
        return Colors.green;

      case 'Fire Brigade':
        return Colors.red;

      case 'Police':
        return Colors.blue;

      case 'Security Guard':
        return Colors.orange;

      default:
        return Colors.purple;
    }
  }

  IconData categoryIcon(
    String value,
  ) {

    switch (value) {

      case 'Ambulance':
        return Icons.medical_services;

      case 'Fire Brigade':
        return Icons.local_fire_department;

      case 'Police':
        return Icons.local_police;

      case 'Security Guard':
        return Icons.security;

      default:
        return Icons.support_agent;
    }
  }

  InputDecoration input(
    String label,
  ) {

    return InputDecoration(
      labelText: label,

      labelStyle:
          const TextStyle(
        color: Colors.white54,
      ),

      filled: true,

      fillColor:
          const Color(0xFF020617),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color: Color(0xFF1E293B),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide:
            const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        const Text(
          'Emergency Contacts',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),

            borderRadius:
                BorderRadius.circular(24),
          ),

          child: Column(
            children: [

              TextField(
                controller:
                    nameController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Contact Name'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    phoneController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Phone Number'),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: category,

                dropdownColor:
                    const Color(0xFF020617),

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Category'),

                items:
                    categories.map((c) {

                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );

                }).toList(),

                onChanged: (v) {

                  setState(() {
                    category = v!;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : saveContact,

                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,

                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,

                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),

                  label: Text(
                    loading
                        ? 'Saving...'
                        : 'Save Contact',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ...contacts.map((contact) {

          final cat =
              contact['category']
                  ?? 'Other';

          return Container(
            margin:
                const EdgeInsets.only(
              bottom: 18,
            ),

            padding:
                const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color:
                  const Color(0xFF0F172A),

              borderRadius:
                  BorderRadius.circular(
                24,
              ),

              border: Border.all(
                color:
                    const Color(0xFF1E293B),
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
                        categoryColor(cat)
                            .withOpacity(
                      0.15,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: Icon(
                    categoryIcon(cat),

                    color:
                        categoryColor(cat),

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
                        contact['name']
                            ?? '',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        contact['phone']
                            ?? '',

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              categoryColor(
                            cat,
                          ).withOpacity(
                            0.2,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child: Text(
                          cat,

                          style:
                              TextStyle(
                            color:
                                categoryColor(
                              cat,
                            ),

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () =>
                      deleteContact(
                    contact['id'],
                  ),

                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}