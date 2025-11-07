import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  // Phone number & email
  final String phoneNumber = "+919999999999";
  final String email = "support@example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Center(
                  child: Text(
                    "Contact Support",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _supportCard(
                  context,
                  title: "Chat with Us",
                  subtitle: "Get instant help via our chatbot or live agent.",
                  buttonText: "Start Chat",
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const ChatScreen()),
                    // );
                  },
                ),
                const SizedBox(height: 15),
                _supportCard(
                  context,
                  title: "Call Helpline",
                  subtitle: "Speak directly with our support team.",
                  buttonText: "Call Now",
                  onTap: () async {
                    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
                    try {
                      await launchUrl(phoneUri);
                    } catch (e) {
                      // Handle error if dialer can't be opened
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to open phone dialer'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 15),
                _supportCard(
                  context,
                  title: "Email Support",
                  subtitle: "Send us your query & we'll reply within 24 hrs.",
                  buttonText: "Send Email",
                  onTap: () async {
                    final Uri emailUri = Uri.parse(
                        'mailto:$email?subject=Support Request&body=Hi, I need help regarding...');
                    try {
                      await launchUrl(emailUri);
                    } catch (e) {
                      // Handle error if email app can't be opened
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to open email app'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _supportCard(BuildContext context,
      {required String title,
      required String subtitle,
      required String buttonText,
      required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
