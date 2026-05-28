import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalComplaintsScreen
    extends StatefulWidget {

  const GlobalComplaintsScreen({
    super.key,
  });

  @override
  State<GlobalComplaintsScreen>
      createState() =>
          _GlobalComplaintsScreenState();
}

class _GlobalComplaintsScreenState
    extends State<
        GlobalComplaintsScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      complaints = [];

  final statuses = [
    'Pending',
    'In Progress',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();

    fetchComplaints();
  }

  Future<void> fetchComplaints() async {

    setState(() => loading = true);

    try {

      final data =
          await supabase
              .from('complaints')
              .select()
              .order(
                'created_at',
                ascending: false,
              );

      complaints =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(
        'Global Complaints Error: $e',
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
          .from('complaints')
          .update({
            'status': status,
          })
          .eq('id', id);

      await fetchComplaints();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Complaint marked as $status',
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

  Future<void> deleteComplaint(
    String id,
  ) async {

    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(
          backgroundColor:
              const Color(
            0xFF0F172A,
          ),

          title: const Text(
            'Delete Complaint',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: const Text(
            'Are you sure you want to permanently remove this complaint?',
            style: TextStyle(
              color:
                  Colors.white70,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),

              child:
                  const Text('Cancel'),
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

              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {

      await supabase
          .from('complaints')
          .delete()
          .eq('id', id);

      await fetchComplaints();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Complaint deleted',
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

      case 'Resolved':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      default:
        return Colors.red;
    }
  }

  Color priorityColor(
    String priority,
  ) {

    switch (priority) {

      case 'Urgent':
        return Colors.red;

      case 'High':
        return Colors.orange;

      case 'Medium':
        return Colors.amber;

      default:
        return Colors.green;
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
                  'Global Complaints Control',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'Monitor all resident complaints, complaint priorities and unresolved issues across the entire platform.',

                  style: TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          ...complaints.map((c) {

            final status =
                c['status'] ??
                    'Pending';

            final priority =
                c['priority'] ??
                    'Medium';

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

                  CircleAvatar(
                    radius: 32,

                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),

                    child: Text(
                      (c['resident_name']
                                  ??
                              'R')[0]
                          .toUpperCase(),

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize: 26,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          c['resident_name']
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
                          height: 8,
                        ),

                        Text(
                          c['description']
                                  ?.toString() ??
                              '',

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,

                            height: 1.5,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,

                          children: [

                            chip(
                              Icons.category,
                              c['category'] ??
                                  '-',
                            ),

                            chip(
                              Icons.priority_high,
                              priority,
                              color:
                                  priorityColor(
                                priority,
                              ),
                            ),

                            chip(
                              Icons.info,
                              status,
                              color:
                                  statusColor(
                                status,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .end,

                    children: [

                      ...statuses.map((s) {

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),

                          child:
                              ElevatedButton(
                            onPressed: () =>
                                updateStatus(
                              c['id'],
                              s,
                            ),

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  statusColor(
                                s,
                              ),
                            ),

                            child: Text(s),
                          ),
                        );
                      }),

                      ElevatedButton(
                        onPressed: () =>
                            deleteComplaint(
                          c['id'],
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
    String text, {
    Color color = Colors.white,
  }) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(
          0.12,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            text,

            style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}