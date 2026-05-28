import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocietyManagementScreen
    extends StatefulWidget {

  const SocietyManagementScreen({
    super.key,
  });

  @override
  State<SocietyManagementScreen>
      createState() =>
          _SocietyManagementScreenState();
}

class _SocietyManagementScreenState
    extends State<
        SocietyManagementScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      societies = [];

  @override
  void initState() {
    super.initState();

    fetchSocieties();
  }

  Future<void> fetchSocieties() async {

    setState(() => loading = true);

    try {

      final data =
          await supabase
              .from('societies')
              .select()
              .order(
                'created_at',
                ascending: false,
              );

      societies =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(
        'Society Error: $e',
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(
    String id,
    String status,
  ) async {

    try {

      await supabase
          .from('societies')
          .update({
            'status': status,
          })
          .eq('id', id);

      await fetchSocieties();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Society marked as $status',
          ),
        ),
      );

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
  }

  Future<void> deleteSociety(
    String id,
  ) async {

    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(
          backgroundColor:
              const Color(0xFF0F172A),

          title: const Text(
            'Delete Society',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: const Text(
            'Are you sure you want to permanently delete this society?',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {

      await supabase
          .from('societies')
          .delete()
          .eq('id', id);

      await fetchSocieties();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Society deleted',
          ),
        ),
      );

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
  }

  Color statusColor(
    String status,
  ) {

    switch (status) {

      case 'approved':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'blocked':
        return Colors.red;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          /// HEADER
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

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  'Society Management',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'Approve, reject, block and manage all registered societies from one enterprise control center.',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          ...societies.map((society) {

            final status =
                society['status'] ??
                    'pending';

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 18,
              ),

              padding:
                  const EdgeInsets.all(
                24,
              ),

              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFF0F172A,
                ),

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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Container(
                    padding:
                        const EdgeInsets
                            .all(16),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF2563EB,
                      ).withOpacity(0.15),

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child: const Icon(
                      Icons.apartment,
                      color:
                          Color(
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
                          society['name']
                              ?? '',

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontSize: 24,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          society['address']
                                  ?.toString() ??
                              'No address',

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,

                          children: [

                            chip(
                              Icons.location_city,
                              society['city'] ??
                                  '-',
                            ),

                            chip(
                              Icons.domain,
                              society['society_type'] ??
                                  '-',
                            ),

                            chip(
                              Icons.home_work,
                              '${society['total_units'] ?? 0} Units',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,

                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              statusColor(
                                status,
                              ).withOpacity(
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
                                statusColor(
                              status,
                            ),

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children: [

                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(
                              society['id'],
                              'approved',
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green,
                            ),

                            child: const Text(
                              'Approve',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(
                              society['id'],
                              'rejected',
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orange,
                            ),

                            child: const Text(
                              'Reject',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(
                              society['id'],
                              'blocked',
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red,
                            ),

                            child: const Text(
                              'Block',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                deleteSociety(
                              society['id'],
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red.shade900,
                            ),

                            child: const Text(
                              'Delete',
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
          0.06,
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
            color: Colors.white70,
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