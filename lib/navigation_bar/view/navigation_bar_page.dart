import 'package:calling_app/pages/dash_board.dart';
import 'package:flutter/material.dart';

import '../../pages/home_page.dart';
import '../cubit/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({Key? key}) : super(key: key);

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _initialIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  static final List<Widget> _widgetOptions = <Widget>[
    const MyHomePage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Flutter Call App'),
            ),
            body: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _widgetOptions,
            ),
            bottomNavigationBar: Container(
              child: BottomNavigationBar(
                currentIndex: state,
                onTap: (index) {
                  context
                      .read<NavigationCubit>()
                      .onItemTapped(index);
                  changeTab(index);
                },
                elevation: 0,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                backgroundColor: Colors.white,
                items: [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon: Icon(Icons.home),
                  ),
                  BottomNavigationBarItem(
                    label: 'Profile',
                    icon: Icon(Icons.person),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void changeTab(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
