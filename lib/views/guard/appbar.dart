import 'package:flutter/material.dart';

AppBar buildAppBar(String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: const Icon(Icons.arrow_back, color: Colors.black),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
