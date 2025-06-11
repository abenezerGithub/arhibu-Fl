import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 13),
                  const Text(
                    'Verify Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF0A6FBA),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'We need to verify your email address we\n',
                      style: TextStyle(color: Color(0xFF0A6FBA)),
                    ),
                    const TextSpan(
                      text: 'have sent an email to\n',
                      style: TextStyle(color: Color(0xFF0A6FBA)),
                    ),
                    TextSpan(
                      text: FirebaseAuth.instance.currentUser?.email ?? widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A6FBA),
                      ),
                    ),
                    const TextSpan(
                      text: ' containing\n',
                      style: TextStyle(color: Color(0xFF0A6FBA)),
                    ),
                    const TextSpan(
                      text: 'a 6 digit code which expire in 15 minutes\n',
                      style: TextStyle(color: Color(0xFF0A6FBA)),
                    ),
                    const TextSpan(
                      text: 'please enter the code in below.',
                      style: TextStyle(color: Color(0xFF0A6FBA)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Code input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF0A6FBA),
                            width: 2,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 50),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A6FBA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await user.reload(); // Refresh the user's data
                      user = FirebaseAuth.instance.currentUser;

                      if (user!.emailVerified) {
                        // Email is verified, navigate to home page
                        Navigator.pushNamed(context, '/');
                      } else {
                        // Email not verified, show message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please verify your email before continuing by following email link.')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text:
                            'Don\'t receive the email? try checking your junk\n',
                      ),
                      TextSpan(text: 'and spam folders. '),
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
