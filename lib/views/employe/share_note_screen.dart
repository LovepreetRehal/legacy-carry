import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareNoteScreen extends StatelessWidget {
  ShareNoteScreen({super.key});

  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1b645), Color(0xff7fc36c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back)),
                const SizedBox(width: 10),
                const Text("Share Note",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Write Note",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        hintText: "Enter Your Notes about shift......",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _greenButton("Save Note"),
                      _yellowButton("Cancel", () => Navigator.pop(context)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _greenButton(String txt) => ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 30)),
    onPressed: () {},
    child: Text(txt),
  );

  Widget _yellowButton(String txt, VoidCallback onTap) => ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffe1b645),
        padding: const EdgeInsets.symmetric(horizontal: 30)),
    onPressed: onTap,
    child: Text(txt),
  );
}
