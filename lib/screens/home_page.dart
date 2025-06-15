import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_appointment_app/components/appointment_card.dart';
import 'package:doctor_appointment_app/components/doctor_card.dart';
import 'package:doctor_appointment_app/models/auth_model.dart';
import 'package:doctor_appointment_app/utils/config.dart';
// import 'package:doctor_appointment_app/pages/doctor_details_page.dart'; // لو عندك صفحة التفاصيل

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> doctor = {};
  List<dynamic> favList = [];
  bool isDark = false;
  String? _imagePath;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> medCat = [
    {"icon": FontAwesomeIcons.userDoctor, "category": "General"},
    {"icon": FontAwesomeIcons.heartPulse, "category": "Cardiology"},
    {"icon": FontAwesomeIcons.lungs, "category": "Respirations"},
    {"icon": FontAwesomeIcons.hand, "category": "Dermatology"},
    {"icon": FontAwesomeIcons.personPregnant, "category": "Gynecology"},
    {"icon": FontAwesomeIcons.teeth, "category": "Dental"},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (mounted && path != null) {
      setState(() => _imagePath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    user = Provider.of<AuthModel>(context).getUser;
    doctor = Provider.of<AuthModel>(context).getAppointment;
    favList = Provider.of<AuthModel>(context).getFav;

    final List<Map<String, dynamic>> doctorList =
        (user['doctor'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final List<Map<String, dynamic>> filteredDoctors = doctorList.where((doc) {
      final name = doc['doctor_name']?.toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: user.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : const AssetImage('assets/profile.jpg')
                      as ImageProvider,
                    ),
                  ],
                ),
                Config.spaceMedium,

                // Search
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctor by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Config.spaceMedium,

                // Category
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                SizedBox(
                  height: Config.heightSize * 0.05,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: medCat.length,
                    itemBuilder: (context, index) {
                      final item = medCat[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Coming Soon'),
                              content: const Text(
                                  'This category will be available soon.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(right: 20),
                          color: Config.primaryColor,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              FaIcon(item['icon'], color: Colors.white),
                              const SizedBox(width: 16),
                              Text(
                                item['category'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Config.spaceSmall,

                // Appointment
                const Text(
                  'Appointment Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                doctor.isNotEmpty
                    ? AppointmentCard(
                  doctor: doctor,
                  color: Config.primaryColor,
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No Appointment Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Config.spaceSmall,

                // Top Doctors
                const Text(
                  'Top Doctors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,

                filteredDoctors.isEmpty
                    ? const Center(
                  child: Text(
                    'No doctors found.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : Column(
                  children: filteredDoctors.map<Widget>((doc) => DoctorCard(
                      doctor: doc,
                      isFav: favList.contains(doc['doc_id']),
                      onFavToggle: () {
                        setState(() {
                          favList.contains(doc['doc_id'])
                              ? favList.remove(doc['doc_id'])
                              : favList.add(doc['doc_id']);
                        });
                      },

                    )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}