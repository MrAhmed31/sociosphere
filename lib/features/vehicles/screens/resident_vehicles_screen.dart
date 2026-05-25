import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentVehiclesScreen extends StatefulWidget {
  const ResidentVehiclesScreen({super.key});

  @override
  State<ResidentVehiclesScreen> createState() =>
      _ResidentVehiclesScreenState();
}

class _ResidentVehiclesScreenState
    extends State<ResidentVehiclesScreen> {

  final supabase = Supabase.instance.client;

  final ownerController = TextEditingController();
  final modelController = TextEditingController();
  final brandController = TextEditingController();
  final plateController = TextEditingController();
  final colorController = TextEditingController();

  bool loading = false;

  List<Map<String, dynamic>> vehicles = [];

  String category = 'Car';

  final categories = [
    'Car',
    'Bike',
    'Bicycle',
    'Scooter',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('vehicles')
          .select()
          .eq('user_id', user?.id ?? '')
          .order('created_at', ascending: false);

      vehicles = List<Map<String, dynamic>>.from(data);

    } catch (_) {

      vehicles = [];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> registerVehicle() async {

    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    try {

      final resident = await supabase
          .from('resident_requests')
          .select()
          .eq('user_id', user?.id ?? '')
          .maybeSingle();

      if (resident == null) {
        throw 'Please join a society first';
      }

      await supabase.from('vehicles').insert({

        'admin_id': resident['admin_id'],
        'user_id': user?.id,

        'owner_name':
            ownerController.text.trim(),

        'category': category,

        'model_name':
            modelController.text.trim(),

        'brand':
            brandController.text.trim(),

        'plate_number':
            plateController.text.trim(),

        'color':
            colorController.text.trim(),

        'status': 'Pending',
      });

      ownerController.clear();
      modelController.clear();
      brandController.clear();
      plateController.clear();
      colorController.clear();

      fetchVehicles();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Vehicle registration submitted',
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          'My Vehicles',

          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
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

            border: Border.all(
              color: const Color(0xFF1E293B),
            ),
          ),

          child: Column(
            children: [

              TextField(
                controller: ownerController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Owner Name'),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: category,

                dropdownColor:
                    const Color(0xFF0F172A),

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Category'),

                items: categories.map((e) {

                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );

                }).toList(),

                onChanged: (v) {
                  setState(() => category = v!);
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: modelController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Model Name'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: brandController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Brand'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: plateController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Number Plate'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: colorController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Vehicle Color'),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed:
                      loading ? null : registerVehicle,

                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,

                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.directions_car,
                        ),

                  label: Text(
                    loading
                        ? 'Registering...'
                        : 'Register Vehicle',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ...vehicles.map((v) {

          final status =
              v['status'] ?? 'Pending';

          return Container(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),

              borderRadius:
                  BorderRadius.circular(24),

              border: Border.all(
                color: const Color(0xFF1E293B),
              ),
            ),

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

                const SizedBox(height: 10),

                Text(
                  '${v['brand']} • ${v['model_name']}',

                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Category: ${v['category']}',

                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 14),

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
              ],
            ),
          );
        }),
      ],
    );
  }

  InputDecoration input(String label) {

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

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: Color(0xFF1E293B),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }
}