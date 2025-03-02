import 'package:flutter/material.dart';
import 'package:studenthouse/pages/login.dart';
import 'package:studenthouse/services/api_service.dart';
import 'package:studenthouse/services/auth_storage.dart';
import 'package:studenthouse/services/user_repository.dart';
import 'package:studenthouse/pages/home.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<List<Map<String, dynamic>>> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UserRepository.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg1.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Main content with SafeArea
          SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  List<Map<String, dynamic>> users = snapshot.data ?? [];
                  return Column(
                    children: [
                      // Welcome Text
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "\nLogin with your academia account",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // User Circles
                      Flexible(
                        flex: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          height: 100,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...users.map((user) => _buildUserCircle(user, context)).toList(),
                              _buildAddUserCircle(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle user switch
  Future<void> switchUser(String email, BuildContext context, String regNumber) async {
    print("Switching user: $email");
    String? token = await AuthStorage.getUserToken(email);
    print("Token: $token");
    if (token == null || token.isEmpty) {
      // If no token, redirect to login page
      print("No token found, redirecting to login page");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      try {
        print("Token found, setting current user id");
        await UserRepository.setCurrentUserId(regNumber);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        // Handle error if attendance fetching fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch attendance: $e")),
        );
      }
    }
  }

  // User Circle - Clickable with First Letter
  Widget _buildUserCircle(Map<String, dynamic> user, BuildContext context) {
    String email = user['email'] ?? 'U'; // Get email or default to 'U'
    String regNumber = user['reg_number'] ?? 'U'; // Get regNumber or default to 'U'
    String firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U'; // Get first letter

    return GestureDetector(
      onTap: () => switchUser(email, context, regNumber), // Call switchUser on tap
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Add User Circle - Clickable
  Widget _buildAddUserCircle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
