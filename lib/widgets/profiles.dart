import 'package:flutter/material.dart';

class Profiles extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const Profiles({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: users.map((user) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade200,
            child: Text(
              user['name']?.toString().substring(0, 1) ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}