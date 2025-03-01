import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String courseTitle;
  final String facultyName;
  final String attendancePercentage;

  const AttendanceCard({
    required this.courseTitle,
    required this.facultyName,
    required this.attendancePercentage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      facultyName,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            double.parse(attendancePercentage) < 75
                                ? Colors.red.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              double.parse(attendancePercentage) < 75
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "$attendancePercentage%",
                      style: TextStyle(
                        color:
                            double.parse(attendancePercentage) < 75
                                ? Colors.red
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
