import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() =>
      _ResidentProfileScreenState();
}

class _ResidentProfileScreenState
    extends State<ResidentProfileScreen> {

  final formKey = GlobalKey<FormState>();

  final nameController =
      TextEditingController();

  final cnicController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final buildingController =
      TextEditingController();

  final floorController =
      TextEditingController();

  final unitController =
      TextEditingController();

  bool loading = false;

  String residentType = 'owner';

  final supabase =
      Supabase.instance.client;

  List<Map<String, dynamic>>
      societies = [];

  String? selectedSocietyId;
  String? selectedSocietyAdminId;

  Map<String, dynamic>? resident;
  Map<String, dynamic>? society;

  bool joined = false;

  @override
  void initState() {
    super.initState();

    fetchSocieties();
    checkResident();
  }

  Future<void> checkResident() async {

    final user =
        supabase.auth.currentUser;

    try {

      final data = await supabase
          .from('residents')
          .select()
          .eq(
            'user_id',
            user?.id ?? '',
          )
          .maybeSingle();

      if (data != null) {

        resident = data;

        joined = true;

        society = await supabase
            .from('societies')
            .select()
            .eq(
              'admin_id',
              resident!['admin_id'],
            )
            .maybeSingle();
      }

    } catch (_) {}

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> leaveSociety() async {

    final user =
        supabase.auth.currentUser;

    try {

      await supabase
          .from('residents')
          .delete()
          .eq(
            'user_id',
            user?.id ?? '',
          );

      resident = null;
      society = null;
      joined = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            'You left the society',
          ),
        ),
      );

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> fetchSocieties() async {

    try {

      final data = await supabase
          .from('societies')
          .select(
            'id,name,admin_id',
          );

      societies =
          List<Map<String, dynamic>>
              .from(data);

      if (mounted) {
        setState(() {});
      }

    } catch (_) {}
  }

  Future<void> sendRequest() async {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() => loading = true);

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        throw 'User not logged in';
      }

      await supabase
          .from('profiles')
          .upsert({

        'id': user.id,

        'full_name':
            nameController.text.trim(),

        'email': user.email,

        'phone':
            phoneController.text.trim(),

        'cnic':
            cnicController.text.trim(),

        'role': 'resident',
      });

      await supabase
          .from('resident_requests')
          .insert({

        'user_id': user.id,

        'admin_id':
            selectedSocietyAdminId,

        'full_name':
            nameController.text.trim(),

        'cnic':
            cnicController.text.trim(),

        'phone':
            phoneController.text.trim(),

        'building_name':
            buildingController.text.trim(),

        'floor_number':
            floorController.text.trim(),

        'unit_number':
            unitController.text.trim(),

        'resident_type':
            residentType,

        'status': 'Pending',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Color(0xFF16A34A),

          content: Text(
            'Join request sent successfully',
          ),
        ),
      );

      nameController.clear();
      cnicController.clear();
      phoneController.clear();
      buildingController.clear();
      floorController.clear();
      unitController.clear();

      setState(() {

        residentType = 'owner';

        selectedSocietyId = null;

        selectedSocietyAdminId = null;
      });

    } catch (e) {

      if (!mounted) return;

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
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(30),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          header(),

          const SizedBox(height: 30),

          joined
              ? joinedCard()
              : formCard(),
        ],
      ),
    );
  }

  Widget joinedCard() {

    return Container(
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: const Color(
          0xFF0F172A,
        ),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: const Color(
            0xFF1E293B,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Row(
            children: [

              Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 34,
              ),

              SizedBox(width: 14),

              Text(
                'You Are In Society',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          info(
            'Society',
            society?['name'] ??
                'Unknown',
          ),

          info(
            'Resident Name',
            resident?['full_name'] ??
                '',
          ),

          info(
            'Unit Number',
            resident?['unit_number'] ??
                '',
          ),

          info(
            'Resident Type',
            resident?[
                    'resident_type'] ??
                '',
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: leaveSociety,

              icon: const Icon(
                Icons.logout_rounded,
              ),

              label: const Text(
                'Leave Society',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget info(
    String title,
    String value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),

      child: Row(
        children: [

          Text(
            '$title: ',

            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {

    return Container(
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1E3A8A),
          ],
        ),
      ),

      child: const Row(
        children: [

          Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 60,
          ),

          SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  'Society Management',

                  style: TextStyle(
                    fontSize: 34,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Manage your society membership professionally.',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formCard() {

    return Form(
      key: formKey,

      child: Container(
        padding:
            const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color:
              const Color(0xFF0F172A),

          borderRadius:
              BorderRadius.circular(24),

          border: Border.all(
            color:
                const Color(0xFF1E293B),
          ),
        ),

        child: Column(
          children: [

            Row(
              children: [

                Expanded(
                  child:
                      DropdownButtonFormField<
                          String>(
                    value:
                        selectedSocietyId,

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
                        inputDecoration(
                      'Select Society',
                    ),

                    items:
                        societies.map(
                      (society) {

                        return DropdownMenuItem<
                            String>(
                          value:
                              society['id'],

                          child: Text(
                            society[
                                'name'],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged:
                        (value) {

                      selectedSocietyId =
                          value;

                      final selectedSociety =
                          societies
                              .firstWhere(
                        (s) =>
                            s['id'] ==
                            value,
                      );

                      selectedSocietyAdminId =
                          selectedSociety[
                              'admin_id'];

                      setState(() {});
                    },

                    validator:
                        (value) {

                      if (value ==
                          null) {
                        return 'Please select society';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child: buildField(
                    'Full Name',
                    nameController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: buildField(
                    'CNIC / ID Card',
                    cnicController,
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child: buildField(
                    'Phone Number',
                    phoneController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: buildField(
                    'Building / Block',
                    buildingController,
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child: buildField(
                    'Floor Number',
                    floorController,
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child: buildField(
                    'Unit / Flat Number',
                    unitController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<
                String>(
              value: residentType,

              dropdownColor:
                  const Color(
                0xFF020617,
              ),

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  inputDecoration(
                'Resident Type',
              ),

              items: const [

                DropdownMenuItem(
                  value: 'owner',
                  child: Text(
                    'Owner',
                  ),
                ),

                DropdownMenuItem(
                  value: 'tenant',
                  child: Text(
                    'Tenant',
                  ),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  residentType =
                      value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 58,

              child:
                  ElevatedButton.icon(

                onPressed:
                    loading
                        ? null
                        : sendRequest,

                icon: loading
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
                        Icons
                            .send_rounded,
                      ),

                label: Text(
                  loading
                      ? 'Sending Request...'
                      : 'Send Join Request',

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2563EB,
                  ),

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController
        controller,
  ) {

    return TextFormField(
      controller: controller,

      style: const TextStyle(
        color: Colors.white,
      ),

      validator: (value) {

        if (value == null ||
            value.trim().isEmpty) {

          return '$label is required';
        }

        return null;
      },

      decoration:
          inputDecoration(label),
    );
  }

  InputDecoration inputDecoration(
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
            BorderRadius.circular(18),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide:
            const BorderSide(
          color: Color(0xFF1E293B),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide:
            const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }
}