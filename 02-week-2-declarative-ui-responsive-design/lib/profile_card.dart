// Praktikum 4: Layout Sederhana (Warm-up)
// Nama  : Mohammad Al Hafis Hidayatulloh
// NIM   : 254107023005

import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mohammad Al Hafis Hidayatulloh',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('254107023005@student.polinema.ac.id'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: Text('NIM')),
            Text('254107023005'),
          ]),
          const Row(children: [
            Expanded(child: Text('Kelas')),
            Text('TI-3G'),
          ]),
          const Row(children: [
            Expanded(child: Text('Semester')),
            Text('5'),
          ]),
        ],
      ),
    );
  }
}
