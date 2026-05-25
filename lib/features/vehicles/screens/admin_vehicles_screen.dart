import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  State<AdminVehiclesScreen> createState() =>
      _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState
    extends State<AdminVehiclesScreen> {

  final supabase = Supabase.instance.client;

  bool loading = false;

  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {

    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('vehicles')
          .select()
          .eq('admin_id', user?.id ?? '')
          .order('created_at', ascending: false);

      vehicles = List<Map<String, dynamic>>.from(data);

    } catch (_) {

      vehicles = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(
    String id,
    String status,
  ) async {

    await supabase
        .from('vehicles')
        .update({
          'status': status,
        })
        .eq('id', id);

    fetchVehicles();
  }

  Future<void> deleteVehicle(String id) async {

    await supabase
        .from('vehicles')
        .delete()
        .eq('id', id);

    fetchVehicles();
  }

  Color statusColor(String status) {

    switch (status) {

      case 'Approved':
        return Colors.green;

      case 'Rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        const Text(
          'Vehicle Management',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Approve or reject resident vehicle registrations.',

          style: TextStyle(
            color: Colors.white54,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        if (loading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (vehicles.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
            ),

            child: const Center(
              child: Text(
                'No vehicles registered yet',

                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          )
        else
          ...vehicles.map((v) {

            final status = v['status'] ?? 'Pending';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius:
                    BorderRadius.circular(24),

                border: Border.all(
                  color: const Color(0xFF1E293B),
                ),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB)
                          .withOpacity(0.15),

                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: Color(0xFF38BDF8),
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          v['plate_number'] ?? '',

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${v['owner_name']} • ${v['brand']} ${v['model_name']}',

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Category: ${v['category'] ?? '-'}',

                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Color: ${v['color'] ?? '-'}',

                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,

                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: statusColor(status)
                              .withOpacity(0.2),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Text(
                          status,

                          style: TextStyle(
                            color:
                                statusColor(status),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          IconButton(
                            onPressed: () =>
                                updateStatus(
                              v['id'],
                              'Approved',
                            ),

                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),

                          IconButton(
                            onPressed: () =>
                                updateStatus(
                              v['id'],
                              'Rejected',
                            ),

                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),

                          IconButton(
                            onPressed: () =>
                                deleteVehicle(
                              v['id'],
                            ),

                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}