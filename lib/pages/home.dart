import 'package:flutter/material.dart';
import '../components/attandence_card.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = ApiService.fetchAttendance();
  }

  void _reloadAttendance() {
    setState(() {
      _attendanceFuture = ApiService.fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Records")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final attendanceResponse = snapshot.data!;
            final List<dynamic> attendanceList = attendanceResponse["attendance"] ?? [];
            final String lastUpdated = attendanceResponse["lastUpdated"] ?? "Not available";

            return Column(
              children: [
                Container(
                  color: Colors.blue[100],
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Last Updated: $lastUpdated"),
                      ElevatedButton(
                        onPressed: _reloadAttendance,
                        child: const Text("Reload"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final record = attendanceList[index] as Map<String, dynamic>;
                      final String courseCode = record["course_code"] ?? "";
                      final String slot = record["slot"] ?? "";
                      final String courseTitle = slot.isNotEmpty ? "$courseCode ($slot)" : courseCode;
                      final String facultyName = record["faculty"] ?? "";
                      final String attendancePercentage = record.containsKey("attendance_percent")
                          ? record["attendance_percent"].toString()
                          : "N/A";
                      return AttendanceCard(
                        courseTitle: courseTitle,
                        facultyName: facultyName,
                        attendancePercentage: attendancePercentage,
                      );
                    },
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
