import 'dart:convert';

import 'package:arhibu/features/account_setup/presentation/cubit/profile_setup_cubit.dart';
import 'package:arhibu/features/account_setup/presentation/screens/account_setup_screen.dart';
import 'package:arhibu/global_service/firebase_secrvices.dart';
import 'package:arhibu/global_service/request_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _bioController;
  bool _isEditingBio = false;
  User? currentUser;

  bool? isProfileComplete;
  dynamic fullUserDataFromServer;
  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    // Load the current logged-in user from Firebase
    final user = FirebaseServices.getLoggeduser();
    if (user == null) {
      dataMissSignout();
    }
    getUserProfile();
    setState(() {
      currentUser = user;
    });
  }

  void getUserProfile() async {
    try {
      final response = await RequestConfig.secureGet(
        "/user",
      );

      final body = jsonDecode(response.body);
      final userDataFromServer = body['user'];
      final profile = userDataFromServer["profile"];
      if (profile == null) {
        setState(() {
          isProfileComplete = false;
        });
      } else {
        setState(() {
          isProfileComplete = true;
        });
      }
      setState(() {
        fullUserDataFromServer = userDataFromServer;
      });
      print('userDataFromServer: $userDataFromServer');
    } catch (err) {
      // TODO: Handle fetch error
      print(err);
    }
  }

  void dataMissSignout() {}
  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEditBio(BuildContext context) {
    setState(() {
      _isEditingBio = !_isEditingBio;
      if (!_isEditingBio) {
        context.read<ProfileSetupCubit>().updateFormData({
          'room_preferences': {'description': _bioController.text},
        });
      } else {
        final currentBio = context
                .read<ProfileSetupCubit>()
                .state
                .formData['room_preferences']?['description'] ??
            '';
        _bioController.text = currentBio;
      }
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileSetupCubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
            child: Image.asset(
              'images/Logowhite.png',
              width: 50,
              height: 50,
              color: const Color.fromARGB(255, 10, 89, 224),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have been logged out.'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
          builder: (context, state) {
            if (state.isProfileComplete) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Profile Setup Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your profile information will be displayed here.',
                    ),
                  ],
                ),
              );
            } else if (currentUser != null) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: const Color(0xFF0A6FBA),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(16.0, -50.0),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                              child: currentUser?.photoURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        currentUser?.photoURL ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -40.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  currentUser?.displayName ?? 'User Name',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Image.asset(
                                        'images/facebook.png',
                                        width: 38,
                                        height: 38,
                                      ),
                                      onPressed: () => _launchURL(
                                          'https://facebook.com/yourprofile'),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'images/insta.jpeg',
                                        width: 38,
                                        height: 38,
                                      ),
                                      onPressed: () => _launchURL(
                                          'https://instagram.com/yourprofile'),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'images/linkedin.png',
                                        width: 38,
                                        height: 38,
                                      ),
                                      onPressed: () => _launchURL(
                                        'https://linkedin.com/in/yourprofile',
                                      ),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'images/x.png',
                                        width: 27,
                                        height: 27,
                                      ),
                                      onPressed: () => _launchURL(
                                          'https://twitter.com/yourprofile'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentUser?.email ?? 'User email',
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'My Bio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _isEditingBio
                                            ? TextField(
                                                controller: _bioController,
                                                maxLines: null,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                decoration:
                                                    const InputDecoration
                                                        .collapsed(
                                                  hintText:
                                                      'Add a few words about yourself.',
                                                ),
                                              )
                                            : Text(
                                                state.formData[
                                                            'room_preferences']
                                                        ?['description'] ??
                                                    'Tell us about yourself...',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isEditingBio
                                              ? Icons.check
                                              : Icons.edit,
                                        ),
                                        onPressed: () =>
                                            _toggleEditBio(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    isProfileComplete == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : isProfileComplete == false
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Your profile is not complete.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AccountSetUp(),
                                          ),
                                        );
                                      },
                                      child:
                                          const Text('Complete Profile Setup'),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User Profile Detailed information',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.email,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Email:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fullUserDataFromServer['email'] ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Phone Number:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fullUserDataFromServer[
                                                    'phoneNumber'] ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Display Name:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fullUserDataFromServer[
                                                    'displayName'] ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.account_circle,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Full Name:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fullUserDataFromServer['profile']
                                                    ?['fullname'] ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
