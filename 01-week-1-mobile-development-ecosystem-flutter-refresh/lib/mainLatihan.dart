import 'package:flutter/material.dart';
import 'latihan.dart';

void main() {
  final luas = hitungLuasPersegiPanjang(10.0, 5.0);

  final profil = Profil(
    nama: 'Mohammad Al Hafis Hidayatulloh',
    nim: '254107023005',
    email: null,
  );

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Luas: $luas'),
              Text('Nama: ${profil.nama}'),
              Text('NIM: ${profil.nim}'),
              Text('Email: ${profil.email ?? 'Email belum diisi'}'),
            ],
          ),
        ),
      ),
    ),
  );
}
