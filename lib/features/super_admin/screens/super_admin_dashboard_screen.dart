import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuperAdminDashboardScreen
    extends StatefulWidget {

  const SuperAdminDashboardScreen({
    super.key,
  });

  @override
  State<SuperAdminDashboardScreen>
      createState() =>
          _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends State<
        SuperAdminDashboardScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  int totalSocieties = 0;
  int totalAdmins = 0;
  int totalResidents = 0;
  int totalComplaints = 0;

  List<Map<String, dynamic>>
      societies = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    try {

      final societiesData =
          await supabase
              .from('societies')
              .select();

      final adminsData =
          await supabase
              .from('profiles')
              .select()
              .eq(
                'role',
                'society_admin',
              );

      final residentsData =
          await supabase
              .from('residents')
              .select();

      final complaintsData =
          await supabase
              .from('complaints')
              .select();

      totalSocieties =
          societiesData.length;

      totalAdmins =
          adminsData.length;

      totalResidents =
          residentsData.length;

      totalComplaints =
          complaintsData.length;

      societies =
          List<Map<String, dynamic>>
              .from(societiesData);

    } catch (e) {

      debugPrint(
        'Super Admin Error: $e',
      );
    }

    if (mounted) {

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> updateSocietyStatus(
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

      await loadData();

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

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 300,
      ),

      padding:
          const EdgeInsets.all(28),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [

            color.withOpacity(0.22),

            const Color(
              0xFF0F172A,
            ),
          ],
        ),

        border: Border.all(
          color:
              color.withOpacity(0.25),
        ),

        boxShadow: [

          BoxShadow(
            color:
                color.withOpacity(
              0.12,
            ),

            blurRadius: 30,
            spreadRadius: 1,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    0.16,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),

              Icon(
                Icons.trending_up,
                color:
                    Colors.greenAccent
                        .shade200,
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight:
                  FontWeight.bold,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,

            style:
                const TextStyle(
              color:
                  Colors.white54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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

          /// PREMIUM HEADER
          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(
              36,
            ),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                34,
              ),

              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [

                  Color(0xFF2563EB),

                  Color(0xFF1E40AF),

                  Color(0xFF0F172A),
                ],
              ),

              boxShadow: [

                BoxShadow(
                  color:
                      Colors.blue
                          .withOpacity(
                    0.25,
                  ),

                  blurRadius: 40,
                  offset:
                      const Offset(
                    0,
                    20,
                  ),
                ),
              ],
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
                              .all(18),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white
                                .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: const Icon(
                        Icons.admin_panel_settings,
                        color:
                            Colors.white,
                        size: 42,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.green
                                .withOpacity(
                          0.18,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: const Row(
                        children: [

                          Icon(
                            Icons.circle,
                            color:
                                Colors.greenAccent,
                            size: 12,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'System Active',

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Super Admin Control Center',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Enterprise platform governance, analytics and complete ecosystem monitoring for SocioSphere.',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          /// ANALYTICS CARDS
          LayoutBuilder(
            builder:
                (context, constraints) {

              int count = 4;

              if (constraints.maxWidth <
                  1200) {
                count = 2;
              }

              if (constraints.maxWidth <
                  700) {
                count = 1;
              }

              return GridView.count(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisCount: count,

                crossAxisSpacing: 20,
                mainAxisSpacing: 20,

                childAspectRatio: 1.25,

                children: [

                  statCard(
                    title:
                        'Total Societies',

                    value:
                        totalSocieties
                            .toString(),

                    icon:
                        Icons.apartment,

                    color:
                        Colors.blue,

                    subtitle:
                        'Registered across the platform',
                  ),

                  statCard(
                    title:
                        'Society Admins',

                    value:
                        totalAdmins
                            .toString(),

                    icon:
                        Icons.admin_panel_settings,

                    color:
                        Colors.purple,

                    subtitle:
                        'Managing societies actively',
                  ),

                  statCard(
                    title:
                        'Residents',

                    value:
                        totalResidents
                            .toString(),

                    icon:
                        Icons.people_alt_rounded,

                    color:
                        Colors.teal,

                    subtitle:
                        'Connected to SocioSphere',
                  ),

                  statCard(
                    title:
                        'Complaints',

                    value:
                        totalComplaints
                            .toString(),

                    icon:
                        Icons.report_problem_rounded,

                    color:
                        Colors.orange,

                    subtitle:
                        'Platform-wide reported issues',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          /// SOCIETY SECTION
          const Text(
            'Registered Societies',

            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          ...societies.map((society) {

            final status =
                society['status'] ??
                    'pending';

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 20,
              ),

              padding:
                  const EdgeInsets.all(
                28,
              ),

              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFF0F172A,
                ),

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),

                border: Border.all(
                  color:
                      const Color(
                    0xFF1E293B,
                  ),
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                        Colors.black
                            .withOpacity(
                      0.22,
                    ),

                    blurRadius: 18,
                    offset:
                        const Offset(
                      0,
                      10,
                    ),
                  ),
                ],
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Container(
                    padding:
                        const EdgeInsets
                            .all(18),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.blue
                              .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: const Icon(
                      Icons.apartment,
                      color:
                          Color(
                        0xFF38BDF8,
                      ),
                      size: 34,
                    ),
                  ),

                  const SizedBox(width: 22),

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

                            height: 1.5,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        Text(
                          'City: ${society['city'] ?? '-'}',

                          style:
                              const TextStyle(
                            color:
                                Colors.white54,
                          ),
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
                          horizontal: 16,
                          vertical: 10,
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

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: [

                          ElevatedButton(
                            onPressed: () =>
                                updateSocietyStatus(
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
                                updateSocietyStatus(
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
                                updateSocietyStatus(
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
}