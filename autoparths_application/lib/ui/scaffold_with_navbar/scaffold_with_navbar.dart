
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(boxShadow: [
          
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            fixedColor: Colors.black,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 2,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home), // Замена для 'Каталог'
                label: 'Гланая',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), // Замена для 'Главная'
                label: 'Категории',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), // Замена для 'Профиль'
                label: 'Профиль',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('24'),
                  textStyle: TextStyle(),
                  backgroundColor: Colors.black,
                  largeSize: 12,
                  child: Icon(Icons.shopping_bag_outlined), // Замена для 'Корзина'
                ),
                label: 'Корзина',
              ),
            ],
            currentIndex: navigationShell.currentIndex,
            onTap: (int index) => navigationShell.goBranch(index),
          ),
        ),
      ),
    );
  }
}