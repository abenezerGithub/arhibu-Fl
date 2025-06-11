import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenEmailScreen extends StatelessWidget {
  final String email;

  const OpenEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A6FBA)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.email_outlined, size: 84, color: Color(0xFF0A6FBA)),
              const SizedBox(height: 20),
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A6FBA),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'To confirm your email address tap the button in the email we sent to',
                style: TextStyle(fontSize: 16, color: Color(0xFF0A6FBA)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                FirebaseAuth.instance.currentUser?.email ?? email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A6FBA),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Center(
                child: SizedBox(
                  width: 150, // Adjust width as needed for your text
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0A6FBA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'User not found. Please sign in again.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (user.emailVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your email is already verified.'),
                            ),
                          );
                          return;
                        }

                        await user.sendEmailVerification();

                        Navigator.pushReplacementNamed(context, '/verify');

                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: '',
                        );

                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open your email app.'),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String message;

                        switch (e.code) {
                          case 'too-many-requests':
                            message =
                                'Too many attempts. Please try again later.';
                            break;
                          case 'user-disabled':
                            message = 'This account has been disabled.';
                            break;
                          case 'user-not-found':
                            message = 'User does not exist.';
                            break;
                          default:
                            message = 'Authentication error: ${e.message}';
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unexpected error: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Open email app',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
