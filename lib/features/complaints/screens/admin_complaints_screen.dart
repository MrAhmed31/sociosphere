import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() =>
      _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState
    extends State<AdminComplaintsScreen> {

  final supabase = Supabase.instance.client;

  bool loading = false;

  List<Map<String, dynamic>>
      complaints = [];

  final statuses = [
    'Pending',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();

    fetchComplaints();
  }

  Future<void> fetchComplaints() async {

    setState(() => loading = true);

    final user =
        supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('complaints')
          .select()
          .eq(
            'admin_id',
            user?.id ?? '',
          )
          .order(
            'created_at',
            ascending: false,
          );

      complaints =
          List<Map<String, dynamic>>
              .from(data);

    } catch (_) {

      complaints = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> updateComplaint(
    String id,
    String status,
    String reply,
  ) async {

    await supabase
        .from('complaints')
        .update({

      'status': status,

      'admin_reply':
          reply.trim(),
    })
        .eq('id', id);

    fetchComplaints();
  }

  Color statusColor(
    String status,
  ) {

    switch (status) {

      case 'Resolved':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      case 'Rejected':
        return Colors.red;

      default:
        return Colors.amber;
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

  void openReplyDialog(
    Map<String, dynamic> complaint,
  ) {

    final replyController =
        TextEditingController(
      text:
          complaint['admin_reply'] ??
              '',
    );

    String selectedStatus =
        complaint['status'];

    showDialog(
      context: context,

      builder: (_) {

        return AlertDialog(
          backgroundColor:
              const Color(0xFF0F172A),

          title: const Text(
            'Manage Complaint',

            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: StatefulBuilder(
            builder:
                (context, setStateDialog) {

              return Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  DropdownButtonFormField<
                      String>(
                    value: selectedStatus,

                    dropdownColor:
                        const Color(
                      0xFF020617,
                    ),

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),

                    decoration:
                        input(
                      'Complaint Status',
                    ),

                    items:
                        statuses.map((s) {

                      return DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      );

                    }).toList(),

                    onChanged: (v) {

                      setStateDialog(() {
                        selectedStatus =
                            v!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller:
                        replyController,

                    maxLines: 4,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),

                    decoration:
                        input(
                      'Admin Reply',
                    ),
                  ),
                ],
              );
            },
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                await updateComplaint(
                  complaint['id'],
                  selectedStatus,
                  replyController.text,
                );

                if (!mounted) return;

                Navigator.pop(context);
              },

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
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
          'Complaint Ticket Center',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        if (loading)

          const Center(
            child:
                CircularProgressIndicator(),
          )

        else

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

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Row(
                    children: [

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
                                    Colors
                                        .white,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize: 22,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              c['ticket_id'] ??
                                  '',

                              style:
                                  const TextStyle(
                                color:
                                    Colors
                                        .white54,
                              ),
                            ),
                          ],
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
                          color:
                              statusColor(
                            status,
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
                          status,

                          style:
                              TextStyle(
                            color:
                                statusColor(
                              status,
                            ),

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children: [

                      chip(
                        Icons.category,
                        c['category'] ??
                            '',
                      ),

                      chip(
                        Icons.priority_high,
                        priority,

                        color:
                            priorityColor(
                          priority,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    c['description'] ??
                        '',

                    style: const TextStyle(
                      color:
                          Colors.white70,

                      height: 1.5,
                    ),
                  ),

                  if (c['admin_reply'] !=
                          null &&
                      c['admin_reply']
                          .toString()
                          .isNotEmpty)

                    Container(
                      margin:
                          const EdgeInsets
                              .only(
                        top: 20,
                      ),

                      padding:
                          const EdgeInsets
                              .all(18),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF020617,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          const Text(
                            'Admin Reply',

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .white,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            c['admin_reply'],

                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,

                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 22),

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child:
                        ElevatedButton.icon(
                      onPressed: () =>
                          openReplyDialog(
                        c,
                      ),

                      icon: const Icon(
                        Icons.reply,
                      ),

                      label: const Text(
                        'Manage Ticket',
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

  Widget chip(
    IconData icon,
    String text, {
    Color color =
        const Color(0xFF2563EB),
  }) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(0.15),

        borderRadius:
            BorderRadius.circular(
          18,
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
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}