import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EnhancedAttendanceCard extends StatelessWidget {
  final String courseTitle;
  final String courseCode;
  final String category; // "T" or "P"
  final int hoursConducted;
  final int hoursAbsent;

  const EnhancedAttendanceCard({
    Key? key,
    required this.courseTitle,
    required this.courseCode,
    required this.category,
    required this.hoursConducted,
    required this.hoursAbsent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate attended classes
    final int attendedClasses = hoursConducted - hoursAbsent;
    // Calculate required extra classes to achieve at least 75% attendance.
    // If already at or above 75%, then 0 extra classes are needed.
    final int requiredExtraClasses =
        (4 * hoursAbsent - hoursConducted) > 0
            ? (4 * hoursAbsent - hoursConducted)
            : 0;

    double attendancePercentage =
        hoursConducted > 0
            ? ((attendedClasses / hoursConducted) * 100)
            : 100; // Default to 100% if no classes conducted yet.
    attendancePercentage = attendancePercentage.clamp(
      0,
      100,
    ); // Ensure percentage is within 0-100 range.

    Color percentageColor;
    if (attendancePercentage >= 75) {
      percentageColor = Colors.green;
    } else if (attendancePercentage >= 60) {
      percentageColor = Colors.orange;
    } else {
      percentageColor = Colors.red;
    }

    final int skippableClassesMargin = max(
      0,
      ((0.25 * hoursConducted) - hoursAbsent).floor(),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$category | $courseCode",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: attendancePercentage / 100,
                  center: Text(
                    "${attendancePercentage.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: percentageColor,
                      fontSize: 16,
                    ),
                  ),
                  progressColor: percentageColor,
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceInfo(
                  context,
                  "Total",
                  hoursConducted.toString(),
                  Colors.blue.shade300,
                ),
                _buildAttendanceInfo(
                  context,
                  "Attended",
                  attendedClasses.toString(),
                  Colors.green.shade300,
                ),
                _buildAttendanceInfo(
                  context,
                  "Absent",
                  hoursAbsent.toString(),
                  Colors.orange.shade300,
                ),
                if (requiredExtraClasses > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Required $requiredExtraClasses",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                if (attendancePercentage >= 75)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Margin: $skippableClassesMargin",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo(
    BuildContext context,
    String title,
    String value,
    Color iconColor,
  ) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
