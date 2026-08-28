import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),

              Text('Mohammad Al Hafis Hidayatulloh', style: TextStyle(fontSize: 24)),

              // Text('NIM: 254107023005'),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Icon(Icons.calendar_today, size: 18),
              //     SizedBox(width: 8),
              //     Text('Semester: 5'),
              //   ],
              // ),

              // SizedBox(height: 8),

              Text('Pemrograman Mobile \u2014 Minggu 1'),
            ],
          ),
        ),
      ),
    );
  }
}
