import 'package:flutter/material.dart';
import 'package:frontend/widgets/menu_tab_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return MenuTabBar();
  }
}
