import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentMaintenanceScreen extends StatefulWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  State<ResidentMaintenanceScreen> createState() =>
      _ResidentMaintenanceScreenState();
}

class _ResidentMaintenanceScreenState
    extends State<ResidentMaintenanceScreen> {

  final supabase = Supabase.instance.client;

  bool loading = false;

  List<Map<String, dynamic>> bills = [];

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {

    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('maintenance_bills')
          .select()
          .eq('user_id', user?.id ?? '')
          .order('created_at', ascending: false);

      bills = List<Map<String, dynamic>>
          .from(data);

    } catch (_) {

      bills = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> markAsPaid(String id) async {

    await supabase
        .from('maintenance_bills')
        .update({
          'payment_status':
              'Verification Pending',
        })
        .eq('id', id);

    fetchBills();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Payment submitted for verification',
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        const Text(
          'My Maintenance Bills',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        if (loading)
          const Center(
            child: CircularProgressIndicator(),
          )

        else if (bills.isEmpty)

          Container(
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius:
                  BorderRadius.circular(24),
            ),

            child: const Center(
              child: Text(
                'No maintenance bills found',

                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          )

        else

          ...bills.map((bill) {

            final status =
                bill['payment_status']
                    ?? 'Unpaid';

            return Container(
              margin: const EdgeInsets.only(
                bottom: 18,
              ),

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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          'Bill for Unit ${bill['unit_number']}',

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: statusColor(
                            status,
                          ).withOpacity(0.2),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Text(
                          status,

                          style: TextStyle(
                            color: statusColor(
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
                    'Amount: Rs. ${bill['amount']}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Due Date: ${bill['due_date']}',

                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Payment Details',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Bank: ${bill['bank_name'] ?? '-'}',

                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Account Title: ${bill['account_title'] ?? '-'}',

                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Account Number: ${bill['account_number'] ?? '-'}',

                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'IBAN: ${bill['iban'] ?? '-'}',

                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (status == 'Unpaid')
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: () =>
                            markAsPaid(
                          bill['id'],
                        ),

                        icon: const Icon(
                          Icons.payment_rounded,
                        ),

                        label: const Text(
                          'I Have Paid',
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
}