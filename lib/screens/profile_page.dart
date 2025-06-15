import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/auth_model.dart';
import '../providers/dio_provider.dart';
import 'package:doctor_appointment_app/main.dart';
import 'package:doctor_appointment_app/utils/config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _imagePath = 'assets/profile.jpg'; // Default image

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPath = prefs.getString('profile_image');
    if (savedPath != null && savedPath.isNotEmpty) {
      setState(() {
        _imagePath = savedPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> user =
        Provider.of<AuthModel>(context, listen: false).getUser;

    return Column(
      children: [
        // Header
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Config.primaryColor, Color(0xFF5A89FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 6),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _changeProfilePicture,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 55,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imagePath.startsWith('assets/')
                            ? AssetImage(_imagePath) as ImageProvider
                            : FileImage(File(_imagePath)),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${user['name']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '23 Years Old | Male',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.grey[100],
            child: Center(
              child: Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 10,
                shadowColor: Colors.black12,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1.2),
                      buildListTile(
                        icon: Icons.person_2_rounded,
                        title: 'Edit Profile',
                        color: Colors.blueAccent,
                        onTap: () {},
                      ),
                      buildListTile(
                        icon: Icons.history_edu,
                        title: 'Appointment History',
                        color: Colors.orangeAccent,
                        onTap: () {},
                      ),
                      buildListTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        color: Colors.redAccent,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('token') ?? '';

                          if (token.isNotEmpty) {
                            final response = await DioProvider().logout(token);
                            if (response == 200) {
                              await prefs.remove('token');
                              if (mounted) {
                                MyApp.navigatorKey.currentState!
                                    .pushReplacementNamed('/');
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<void> _changeProfilePicture() async {
    await _checkPermissions();

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  ListTile buildListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
