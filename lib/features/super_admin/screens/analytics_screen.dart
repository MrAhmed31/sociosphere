import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsScreen
    extends StatefulWidget {

  const AnalyticsScreen({
    super.key,
  });

  @override
  State<AnalyticsScreen>
      createState() =>
          _AnalyticsScreenState();
}

class _AnalyticsScreenState
    extends State<
        AnalyticsScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  int totalSocieties = 0;
  int approvedSocieties = 0;
  int pendingSocieties = 0;

  int totalResidents = 0;
  int totalAdmins = 0;

  int totalComplaints = 0;
  int resolvedComplaints = 0;
  int pendingComplaints = 0;

  int totalVehicles = 0;
  int approvedVehicles = 0;

  double resolutionRate = 0;

  @override
  void initState() {
    super.initState();

    loadAnalytics();
  }

  Future<void> loadAnalytics() async {

    try {

      final societies =
          await supabase
              .from('societies')
              .select();

      final residents =
          await supabase
              .from('residents')
              .select();

      final admins =
          await supabase
              .from('profiles')
              .select()
              .eq(
                'role',
                'society_admin',
              );

      final complaints =
          await supabase
              .from('complaints')
              .select();

      final vehicles =
          await supabase
              .from('vehicles')
              .select();

      totalSocieties =
          societies.length;

      approvedSocieties =
          societies
              .where(
                (e) =>
                    e['status'] ==
                    'approved',
              )
              .length;

      pendingSocieties =
          societies
              .where(
                (e) =>
                    e['status'] ==
                    'pending',
              )
              .length;

      totalResidents =
          residents.length;

      totalAdmins =
          admins.length;

      totalComplaints =
          complaints.length;

      resolvedComplaints =
          complaints
              .where(
                (e) =>
                    e['status'] ==
                    'Resolved',
              )
              .length;

      pendingComplaints =
          complaints
              .where(
                (e) =>
                    e['status'] !=
                    'Resolved',
              )
              .length;

      totalVehicles =
          vehicles.length;

      approvedVehicles =
          vehicles
              .where(
                (e) =>
                    e['status'] ==
                    'Approved',
              )
              .length;

      if (totalComplaints > 0) {

        resolutionRate =
            (resolvedComplaints /
                    totalComplaints) *
                100;
      }

    } catch (e) {

      debugPrint(
        'Analytics Error: $e',
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget analyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {

    return Container(
      padding:
          const EdgeInsets.all(28),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,

          colors: [

            color.withOpacity(0.22),

            const Color(
              0xFF0F172A,
            ),
          ],
        ),

        border: Border.all(
          color:
              color.withOpacity(
            0.25,
          ),
        ),

        boxShadow: [

          BoxShadow(
            color:
                color.withOpacity(
              0.12,
            ),

            blurRadius: 28,
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
                    0.15,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 30,
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

  Widget insightCard({
    required String title,
    required String value,
    required Color color,
  }) {

    return Container(
      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color:
            const Color(0xFF0F172A),

        borderRadius:
            BorderRadius.circular(
          26,
        ),

        border: Border.all(
          color:
              color.withOpacity(
            0.2,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style:
                TextStyle(
              color: color,
              fontSize: 34,
              fontWeight:
                  FontWeight.bold,
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
                        Icons.analytics,
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
                            'Platform Healthy',

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
                  'Executive Analytics Dashboard',

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
                  'Enterprise intelligence, growth metrics and ecosystem monitoring for the complete SocioSphere platform.',

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

          /// ANALYTICS GRID
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

                childAspectRatio: 1.2,

                children: [

                  analyticsCard(
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
                        'Registered across platform',
                  ),

                  analyticsCard(
                    title:
                        'Approved Societies',

                    value:
                        approvedSocieties
                            .toString(),

                    icon:
                        Icons.verified,

                    color:
                        Colors.green,

                    subtitle:
                        'Operational and active',
                  ),

                  analyticsCard(
                    title:
                        'Residents',

                    value:
                        totalResidents
                            .toString(),

                    icon:
                        Icons.people,

                    color:
                        Colors.purple,

                    subtitle:
                        'Connected ecosystem users',
                  ),

                  analyticsCard(
                    title:
                        'Complaints',

                    value:
                        totalComplaints
                            .toString(),

                    icon:
                        Icons.report_problem,

                    color:
                        Colors.orange,

                    subtitle:
                        'Platform-wide issues',
                  ),

                  analyticsCard(
                    title:
                        'Society Admins',

                    value:
                        totalAdmins
                            .toString(),

                    icon:
                        Icons.admin_panel_settings,

                    color:
                        Colors.teal,

                    subtitle:
                        'Managing communities',
                  ),

                  analyticsCard(
                    title:
                        'Pending Societies',

                    value:
                        pendingSocieties
                            .toString(),

                    icon:
                        Icons.pending,

                    color:
                        Colors.amber,

                    subtitle:
                        'Waiting approval workflow',
                  ),

                  analyticsCard(
                    title:
                        'Resolved Complaints',

                    value:
                        resolvedComplaints
                            .toString(),

                    icon:
                        Icons.task_alt,

                    color:
                        Colors.green,

                    subtitle:
                        'Successfully resolved',
                  ),

                  analyticsCard(
                    title:
                        'Approved Vehicles',

                    value:
                        approvedVehicles
                            .toString(),

                    icon:
                        Icons.directions_car,

                    color:
                        Colors.cyan,

                    subtitle:
                        'Verified transport records',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          /// SMART INSIGHTS
          const Text(
            'Platform Insights',

            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder:
                (context, constraints) {

              int count = 3;

              if (constraints.maxWidth <
                  1000) {
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

                  insightCard(
                    title:
                        'Complaint Resolution Rate',

                    value:
                        '${resolutionRate.toStringAsFixed(1)}%',

                    color:
                        Colors.green,
                  ),

                  insightCard(
                    title:
                        'Pending Complaint Count',

                    value:
                        pendingComplaints
                            .toString(),

                    color:
                        Colors.orange,
                  ),

                  insightCard(
                    title:
                        'Vehicle Approval Ratio',

                    value:
                        '$approvedVehicles / $totalVehicles',

                    color:
                        Colors.cyan,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}