import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() =>
      _AdminNoticesScreenState();
}

class _AdminNoticesScreenState
    extends State<AdminNoticesScreen> {

  final supabase = Supabase.instance.client;

  final titleController =
      TextEditingController();

  final messageController =
      TextEditingController();

  bool loading = false;

  String priority = 'Normal';

  final priorities = [
    'Normal',
    'Important',
    'Urgent',
    'Emergency',
  ];

  List<Map<String, dynamic>>
      notices = [];

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {

    final user = supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('notices')
          .select()
          .eq('admin_id', user?.id ?? '')
          .order(
            'created_at',
            ascending: false,
          );

      notices =
          List<Map<String, dynamic>>
              .from(data);

    } catch (_) {

      notices = [];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> publishNotice() async {

    final user = supabase.auth.currentUser;

    setState(() => loading = true);

    try {

      await supabase
          .from('notices')
          .insert({

        'admin_id': user?.id,

        'title':
            titleController.text.trim(),

        'message':
            messageController.text.trim(),

        'priority': priority,

'is_emergency':
    priority == 'Emergency',
      });

      titleController.clear();
      messageController.clear();

      priority = 'Normal';

      fetchNotices();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Notice published',
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

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> deleteNotice(
    String id,
  ) async {

    await supabase
        .from('notices')
        .delete()
        .eq('id', id);

    fetchNotices();
  }

  Color priorityColor(
    String value,
  ) {

    switch (value) {

      case 'Emergency':
        return Colors.red;

      case 'Urgent':
        return Colors.orange;

      case 'Important':
        return Colors.amber;

      default:
        return Colors.blue;
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
          'Notice Control Center',

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
                    titleController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Notice Title'),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: priority,

                dropdownColor:
                    const Color(0xFF020617),

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Priority'),

                items:
                    priorities.map((p) {

                  return DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  );

                }).toList(),

                onChanged: (v) {

                  setState(() {
                    priority = v!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    messageController,

                maxLines: 4,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    input('Notice Message'),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : publishNotice,

                  child: Text(
                    loading
                        ? 'Publishing...'
                        : 'Publish Notice',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ...notices.map((notice) {

          final p =
              notice['priority']
                  ?? 'Normal';

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
                        notice['title']
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
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            priorityColor(
                          p,
                        ).withOpacity(0.2),

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        p,

                        style:
                            TextStyle(
                          color:
                              priorityColor(
                            p,
                          ),

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  notice['message']
                      ?? '',

                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment:
                      Alignment.centerRight,

                  child: IconButton(
                    onPressed: () =>
                        deleteNotice(
                      notice['id'],
                    ),

                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
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