import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentComplaintsScreen extends StatefulWidget {
  const ResidentComplaintsScreen({super.key});

  @override
  State<ResidentComplaintsScreen> createState() =>
      _ResidentComplaintsScreenState();
}

class _ResidentComplaintsScreenState
    extends State<ResidentComplaintsScreen> {

  final supabase = Supabase.instance.client;

  final descriptionController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool formLoading = false;
  bool listLoading = false;

  List<Map<String, dynamic>>
      complaints = [];

  String selectedCategory =
      'Cleaning Issue';

  String selectedPriority =
      'Medium';

  final categories = [
    'Cleaning Issue',
    'Security Issue',
    'Maintenance Problem',
    'Electricity Issue',
    'Water Supply Issue',
    'Parking Issue',
    'Noise Complaint',
    'Other',
  ];

  final priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();

    fetchComplaints();
  }

  Future<void> fetchComplaints() async {

    setState(() => listLoading = true);

    final user =
        supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('complaints')
          .select()
          .eq(
            'user_id',
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
      setState(() => listLoading = false);
    }
  }

  Future<void> submitComplaint() async {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() => formLoading = true);

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

      if (resident == null) {
        throw 'Please join a society first';
      }

      final ticketId =
          'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      await supabase
          .from('complaints')
          .insert({

        'admin_id':
            resident['admin_id'],

        'user_id': user?.id,

        'resident_name':
            resident['full_name'],

        'category':
            selectedCategory,

        'priority':
            selectedPriority,

        'description':
            descriptionController.text
                .trim(),

        'status': 'Pending',

        'ticket_id': ticketId,
      });

      descriptionController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Complaint submitted successfully',
          ),
        ),
      );

      await fetchComplaints();

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
      setState(() => formLoading = false);
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
          'My Support Tickets',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Track complaint status and communicate with society management.',

          style: TextStyle(
            color: Colors.white54,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        /// FORM
        Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),

            borderRadius:
                BorderRadius.circular(24),

            border: Border.all(
              color:
                  const Color(0xFF1E293B),
            ),
          ),

          child: Form(
            key: formKey,

            child: Column(
              children: [

                DropdownButtonFormField<
                    String>(
                  value: selectedCategory,

                  dropdownColor:
                      const Color(
                    0xFF0F172A,
                  ),

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),

                  decoration:
                      input(
                    'Complaint Category',
                  ),

                  items:
                      categories.map((e) {

                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );

                  }).toList(),

                  onChanged: (v) {

                    setState(() {
                      selectedCategory =
                          v!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<
                    String>(
                  value: selectedPriority,

                  dropdownColor:
                      const Color(
                    0xFF0F172A,
                  ),

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),

                  decoration:
                      input(
                    'Priority',
                  ),

                  items:
                      priorities.map((e) {

                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );

                  }).toList(),

                  onChanged: (v) {

                    setState(() {
                      selectedPriority =
                          v!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      descriptionController,

                  maxLines: 5,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),

                  decoration:
                      input(
                    'Describe your issue',
                  ),

                  validator: (v) {

                    if (v == null ||
                        v.trim().isEmpty) {

                      return 'Please describe your complaint';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        formLoading
                            ? null
                            : submitComplaint,

                    icon: formLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,

                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors
                                      .white,

                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                          ),

                    label: Text(
                      formLoading
                          ? 'Submitting...'
                          : 'Submit Complaint',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        /// TICKETS
        if (listLoading)

          const Center(
            child:
                CircularProgressIndicator(),
          )

        else if (complaints.isEmpty)

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
                  Icons.support_agent,
                  color: Colors.white38,
                  size: 70,
                ),

                SizedBox(height: 18),

                Text(
                  'No complaints submitted yet',

                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
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
                              c['category']
                                  ?? '',

                              style:
                                  const TextStyle(
                                color:
                                    Colors
                                        .white,

                                fontSize: 22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              c['ticket_id']
                                      ?.toString() ??
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
                    c['description']
                        ?? '',

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

                          const Row(
                            children: [

                              Icon(
                                Icons.reply,
                                color:
                                    Colors.blue,
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Text(
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
                            ],
                          ),

                          const SizedBox(
                            height: 14,
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