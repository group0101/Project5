import 'package:flutter/material.dart';

/// Bottom app bar buttons
///
/// home, data, map, profile.
class CustomBottomAppBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final Function changeTab;
  final IconData icon;

  CustomBottomAppBarItem({
    @required this.index,
    @required this.currentIndex,
    @required this.label,
    @required this.changeTab,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double _bottomAppBarHeight = MediaQuery.of(context).size.height * 0.07;
    bool _selected = currentIndex == index;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          changeTab(index);
        },
        borderRadius: BorderRadius.circular(5),
        child: Transform.scale(
          scale: _selected ? 1.1 : 1,
          child: Container(
            height: _bottomAppBarHeight * 5 / 7,
            width: _bottomAppBarHeight * 6 / 7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selected
                    ? Icon(
                        icon,
                        color: Colors.white,
                        size: _bottomAppBarHeight * 2.5 / 7,
                      )
                    : Icon(
                        icon,
                        color: Colors.purple[100],
                        size: _bottomAppBarHeight * 2.5 / 7,
                      ),
                Text(
                  label,
                  style: _selected
                      ? TextStyle(
                          color: Colors.white,
                          fontSize: _bottomAppBarHeight / 5,
                        )
                      : TextStyle(
                          color: Colors.purple[100],
                          fontSize: _bottomAppBarHeight / 5,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
