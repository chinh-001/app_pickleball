import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/menu_function_screen/View/menu_function_screen.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String? heroTag;

  const CustomFloatingActionButton({super.key, this.heroTag = 'mainFab'});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MenuFunctionScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            maintainState: false,
          ),
        );
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add_circle, color: Colors.white),
    );
  }
}
