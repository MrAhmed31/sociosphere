import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  State<AdminMaintenanceScreen> createState() =>
      _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState
    extends State<AdminMaintenanceScreen> {

  final supabase = Supabase.instance.client;

  final amountController =
      TextEditingController();

  final dueDateController =
      TextEditingController();

  final bankController =
      TextEditingController();

  final titleController =
      TextEditingController();

  final accountController =
      TextEditingController();

  final ibanController =
      TextEditingController();

  final notesController =
      TextEditingController();

  bool loading = false;

  List<Map<String, dynamic>> bills = [];

  List<Map<String, dynamic>> residents = [];

  Map<String, dynamic>? selectedResident;

  @override
  void initState() {
    super.initState();

    fetchResidents();
    fetchBills();
  }

  Future<void> fetchResidents() async {

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('residents')
          .select()
          .eq('admin_id', user?.id ?? '');

      residents =
          List<Map<String, dynamic>>
              .from(data);

    } catch (_) {

      residents = [];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchBills() async {

    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('maintenance_bills')
          .select()
          .eq('admin_id', user?.id ?? '')
          .order(
            'created_at',
            ascending: false,
          );

      bills =
          List<Map<String, dynamic>>
              .from(data);

    } catch (_) {

      bills = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> generateBill() async {

    if (selectedResident == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please select resident',
          ),
        ),
      );

      return;
    }

    final user = supabase.auth.currentUser;

    try {

      await supabase
          .from('maintenance_bills')
          .insert({

        'admin_id': user?.id,

        'user_id':
            selectedResident!['user_id'],

        'resident_name':
            selectedResident!['full_name'],

        'unit_number':
            selectedResident!['unit_number'],

        'amount':
            amountController.text.trim(),

        'due_date':
            dueDateController.text.trim(),

        'bank_name':
            bankController.text.trim(),

        'account_title':
            titleController.text.trim(),

        'account_number':
            accountController.text.trim(),

        'iban':
            ibanController.text.trim(),

        'notes':
            notesController.text.trim(),

        'payment_status':
            'Unpaid',
      });

      amountController.clear();
      dueDateController.clear();
      bankController.clear();
      titleController.clear();
      accountController.clear();
      ibanController.clear();
      notesController.clear();

      selectedResident = null;

      fetchBills();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Bill generated successfully',
          ),
        ),
      );

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> verifyPayment(
    String id,
    String status,
  ) async {

    await supabase
        .from('maintenance_bills')
        .update({
          'payment_status': status,
        })
        .eq('id', id);

    fetchBills();
  }

  Color statusColor(String status) {

    switch (status) {

      case 'Paid':
        return Colors.green;

      case 'Verification Pending':
        return Colors.orange;

      case 'Rejected':
        return Colors.red;

      default:
        return Colors.redAccent;
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
          'Maintenance Control Center',

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

              DropdownButtonFormField<
                  Map<String, dynamic>>(
                value: selectedResident,

                dropdownColor:
                    const Color(0xFF020617),

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Select Resident'),

                items:
                    residents.map((resident) {

                  return DropdownMenuItem(
                    value: resident,

                    child: Text(
                      '${resident['full_name']} • ${resident['unit_number']}',
                    ),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {
                    selectedResident =
                        value;
                  });
                },
              ),

              const SizedBox(height: 16),

              if (selectedResident != null)

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF020617,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(18),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        'Resident Name: ${selectedResident!['full_name']}',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Unit: ${selectedResident!['unit_number']}',

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    amountController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Amount'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    dueDateController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Due Date'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    bankController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Bank Name'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    titleController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Account Title'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    accountController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Account Number'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    ibanController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('IBAN'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    notesController,

                maxLines: 3,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Notes'),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: generateBill,

                  child: const Text(
                    'Generate Bill',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ...bills.map((bill) {

          final status =
              bill['payment_status']
                  ?? 'Unpaid';

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

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        bill['resident_name']
                            ?? '',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: statusColor(
                          status,
                        ).withOpacity(0.2),

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        status,

                        style:
                            TextStyle(
                          color:
                              statusColor(
                            status,
                          ),

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  'Unit: ${bill['unit_number']}',

                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Amount: Rs. ${bill['amount']}',

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Due Date: ${bill['due_date']}',

                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 18),

                if (status ==
                    'Verification Pending')

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              verifyPayment(
                            bill['id'],
                            'Paid',
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,
                          ),

                          child: const Text(
                            'Verify Payment',
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              verifyPayment(
                            bill['id'],
                            'Rejected',
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.red,
                          ),

                          child: const Text(
                            'Reject',
                          ),
                        ),
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