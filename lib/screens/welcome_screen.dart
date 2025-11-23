import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Custom homepage logo image
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Image.asset(
                    'homepagelogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                // Slogan
                Text(
                  "Kampüs'ün Ayağına geldi",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(flex: 1),
                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Giriş Yap",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Kayıt Ol",
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
