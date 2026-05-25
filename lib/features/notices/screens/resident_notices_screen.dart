import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentNoticesScreen extends StatefulWidget {
  const ResidentNoticesScreen({super.key});

  @override
  State<ResidentNoticesScreen> createState() =>
      _ResidentNoticesScreenState();
}

class _ResidentNoticesScreenState
    extends State<ResidentNoticesScreen> {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>>
      notices = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {

    final user = supabase.auth.currentUser;

    try {

      final resident = await supabase
          .from('residents')
          .select()
          .eq('user_id', user?.id ?? '')
          .maybeSingle();

      if (resident == null) {

        notices = [];

      } else {

        final data = await supabase
            .from('notices')
            .select()
            .eq(
              'admin_id',
              resident['admin_id'],
            )
            .order(
              'created_at',
              ascending: false,
            );

        notices =
            List<Map<String, dynamic>>
                .from(data);
      }

    } catch (_) {

      notices = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
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

  IconData priorityIcon(
    String value,
  ) {

    switch (value) {

      case 'Emergency':
        return Icons.warning_rounded;

      case 'Urgent':
        return Icons.notifications_active;

      case 'Important':
        return Icons.priority_high;

      default:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        const Text(
          'Society Notices',

          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Latest announcements and important alerts from your society.',

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

        else if (notices.isEmpty)

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
                  Icons.notifications_off,
                  color: Colors.white38,
                  size: 70,
                ),

                SizedBox(height: 18),

                Text(
                  'No notices available',

                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )

        else

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

                      Container(
                        padding:
                            const EdgeInsets
                                .all(14),

                        decoration:
                            BoxDecoration(
                          color:
                              priorityColor(
                            p,
                          ).withOpacity(0.15),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),

                        child: Icon(
                          priorityIcon(p),

                          color:
                              priorityColor(
                            p,
                          ),

                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 18,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              notice['title']
                                  ?? '',

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,

                                fontSize: 22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
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
                                p,

                                style:
                                    TextStyle(
                                  color:
                                      priorityColor(
                                    p,
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
                    ],
                  ),

                  const SizedBox(height: 22),

                  Text(
                    notice['message']
                        ?? '',

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
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