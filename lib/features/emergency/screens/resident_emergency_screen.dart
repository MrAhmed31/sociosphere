import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentEmergencyScreen extends StatefulWidget {
  const ResidentEmergencyScreen({super.key});

  @override
  State<ResidentEmergencyScreen> createState() =>
      _ResidentEmergencyScreenState();
}

class _ResidentEmergencyScreenState
    extends State<ResidentEmergencyScreen> {

  final supabase = Supabase.instance.client;

  bool loading = true;

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

      final resident = await supabase
          .from('residents')
          .select()
          .eq(
            'user_id',
            user?.id ?? '',
          )
          .maybeSingle();

      if (resident != null) {

        final data = await supabase
            .from('emergency_contacts')
            .select()
            .eq(
              'admin_id',
              resident['admin_id'],
            )
            .order(
              'created_at',
              ascending: false,
            );

        contacts =
            List<Map<String, dynamic>>
                .from(data);
      }

    } catch (_) {

      contacts = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
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

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        const Text(
          'Emergency Support',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Quick access to important emergency contacts in your society.',

          style: TextStyle(
            color: Colors.white54,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        if (loading)

          const Center(
            child:
                CircularProgressIndicator(),
          )

        else if (contacts.isEmpty)

          Container(
            padding:
                const EdgeInsets.all(40),

            decoration: BoxDecoration(
              color:
                  const Color(0xFF0F172A),

              borderRadius:
                  BorderRadius.circular(
                24,
              ),
            ),

            child: const Column(
              children: [

                Icon(
                  Icons.contact_phone,
                  color: Colors.white38,
                  size: 70,
                ),

                SizedBox(height: 18),

                Text(
                  'No emergency contacts available',

                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )

        else

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
                      const Color(
                    0xFF1E293B,
                  ),
                ),
              ),

              child: Row(
                children: [

                  Container(
                    padding:
                        const EdgeInsets
                            .all(16),

                    decoration:
                        BoxDecoration(
                      color:
                          categoryColor(
                        cat,
                      ).withOpacity(0.15),

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child: Icon(
                      categoryIcon(cat),

                      color:
                          categoryColor(
                        cat,
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

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          contact['phone']
                              ?? '',

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
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(14),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.green
                              .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child: const Icon(
                      Icons.phone,
                      color: Colors.green,
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