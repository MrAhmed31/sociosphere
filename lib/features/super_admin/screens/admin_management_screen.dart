import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManagementScreen
    extends StatefulWidget {

  const AdminManagementScreen({
    super.key,
  });

  @override
  State<AdminManagementScreen>
      createState() =>
          _AdminManagementScreenState();
}

class _AdminManagementScreenState
    extends State<
        AdminManagementScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      admins = [];

  @override
  void initState() {
    super.initState();

    fetchAdmins();
  }

  Future<void> fetchAdmins() async {

    setState(() => loading = true);

    try {

      final profiles =
          await supabase
              .from('profiles')
              .select()
              .eq(
                'role',
                'society_admin',
              );

      List<Map<String, dynamic>>
          loadedAdmins = [];

      for (final admin
          in profiles) {

        final society =
            await supabase
                .from('societies')
                .select()
                .eq(
                  'admin_id',
                  admin['id'],
                )
                .maybeSingle();

        loadedAdmins.add({

          ...admin,

          'society':
              society,
        });
      }

      admins =
          loadedAdmins;

    } catch (e) {

      debugPrint(
        'Admin Error: $e',
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> suspendAdmin(
    String id,
  ) async {

    try {

      await supabase
          .from('profiles')
          .update({
            'is_suspended': true,
          })
          .eq('id', id);

      await fetchAdmins();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.orange,

          content: Text(
            'Admin suspended',
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

  Future<void> activateAdmin(
    String id,
  ) async {

    try {

      await supabase
          .from('profiles')
          .update({
            'is_suspended': false,
          })
          .eq('id', id);

      await fetchAdmins();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Admin activated',
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

  Future<void> deleteAdmin(
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
            'Delete Admin',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: const Text(
            'Are you sure you want to permanently remove this admin?',
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
          .from('profiles')
          .delete()
          .eq('id', id);

      await fetchAdmins();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,

          content: Text(
            'Admin deleted',
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
            CrossAxisAlignment
                .start,

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
                  'Admin Management',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'Monitor, suspend, activate and manage all society administrators across the platform.',

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

          ...admins.map((admin) {

            final society =
                admin['society'];

            final suspended =
                admin[
                        'is_suspended'] ==
                    true;

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
                    CrossAxisAlignment
                        .start,

                children: [

                  CircleAvatar(
                    radius: 34,

                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),

                    child: Text(
                      (admin['email']
                                  ??
                              'A')[0]
                          .toUpperCase(),

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize: 28,

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
                          admin['full_name'] ??
                              'Admin',

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
                          admin['email'] ??
                              '',

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,

                          children: [

                            chip(
                              Icons.apartment,
                              society?['name'] ??
                                  'No Society',
                            ),

                            chip(
                              Icons.location_city,
                              society?['city'] ??
                                  '-',
                            ),

                            chip(
                              Icons.verified_user,
                              suspended
                                  ? 'Suspended'
                                  : 'Active',
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

                      ElevatedButton(
                        onPressed: () {

                          if (suspended) {

                            activateAdmin(
                              admin['id'],
                            );

                          } else {

                            suspendAdmin(
                              admin['id'],
                            );
                          }
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              suspended
                                  ? Colors.green
                                  : Colors.orange,
                        ),

                        child: Text(
                          suspended
                              ? 'Activate'
                              : 'Suspend',
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            deleteAdmin(
                          admin['id'],
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