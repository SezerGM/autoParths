import 'dart:math';

import 'package:flutter/material.dart';



class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(width: 5)),
              labelText: 'Найти',
              labelStyle: TextStyle(color: Colors.greenAccent)
            ),
          ),
        ),
      ),
    );
  }
}