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

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {

    return Container(
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

      child: Row(
        children: [

          Container(
            padding:
                const EdgeInsets.all(
              16,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(
                0xFF2563EB,
              ).withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Icon(
              icon,
              color:
                  const Color(
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
                  value,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                ),
              ],
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
                  'Super Admin Control Center',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'Monitor platform analytics, societies, residents and overall system management.',

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

          /// STATS
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

                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                childAspectRatio: 2.2,

                children: [

                  statCard(
                    title:
                        'Total Societies',

                    value:
                        totalSocieties
                            .toString(),

                    icon:
                        Icons.apartment,
                  ),

                  statCard(
                    title:
                        'Society Admins',

                    value:
                        totalAdmins
                            .toString(),

                    icon:
                        Icons.admin_panel_settings,
                  ),

                  statCard(
                    title:
                        'Residents',

                    value:
                        totalResidents
                            .toString(),

                    icon:
                        Icons.people_alt_rounded,
                  ),

                  statCard(
                    title:
                        'Complaints',

                    value:
                        totalComplaints
                            .toString(),

                    icon:
                        Icons.report_problem_rounded,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Registered Societies',

            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          ...societies.map((society) {

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
                          society['address']
                                  ?.toString() ??
                              'No address',

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
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
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.green
                              .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child: const Text(
                      'Active',

                      style: TextStyle(
                        color:
                            Colors.green,

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
      ),
    );
  }
}