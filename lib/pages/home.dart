import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studenthouse/services/user_repository.dart';
import '../components/attandence_card.dart';
import '../services/api_service.dart';
import 'package:studenthouse/pages/splash_screen.dart';
import 'package:studenthouse/pages/welcome.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _attendanceFuture;

  get prefs => SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _attendanceFuture = ApiService.fetchAttendance();
  }

  void _reloadAttendance() {
    setState(() {
      _attendanceFuture = ApiService.fetchAttendance(forceReload: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadAttendance,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final attendanceResponse = snapshot.data!;
            final List<dynamic> attendanceList =
                attendanceResponse["attendance"] ?? [];
            final String lastUpdated =
                attendanceResponse["lastUpdated"] ?? "Not available";

            return Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Last Updated: $lastUpdated",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _reloadAttendance,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.purple.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: const Text(
                              "Reload",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(2),
                    itemCount: attendanceList.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 10),
                    // Inside your ListView.separated's itemBuilder:
                    itemBuilder: (context, index) {
                      final record =
                          attendanceList[index] as Map<String, dynamic>;

                      // Extract values from the enriched record.
                      final String courseTitle =
                          record["course_title"] ?? "Course Name Not Available";
                      final String courseCode = record["course_code"] ?? "N/A";
                      final String category =
                          record["category"] ?? "T"; // Default to T (theory)
                      final int hoursConducted = record["hours_conducted"] ?? 0;
                      final int hoursAbsent = record["hours_absent"] ?? 0;

                      return EnhancedAttendanceCard(
                        courseTitle: courseTitle,
                        courseCode: courseCode,
                        category: category,
                        hoursConducted: hoursConducted,
                        hoursAbsent: hoursAbsent,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await ApiService().logout(
                            await UserRepository.getUserEmail(
                              await UserRepository.getCurrentUserId(),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await UserRepository.removeCurrentUserId();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text("Switch User"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No attendance data available."));
          }
        },
      ),
    );
  }
}
