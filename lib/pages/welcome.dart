import 'package:flutter/material.dart';
import 'package:studenthouse/widgets/custom_scarfold.dart';
import 'package:studenthouse/widgets/profiles.dart';
import 'package:studenthouse/pages/login.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: 100,
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Profiles(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
