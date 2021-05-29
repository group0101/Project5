import 'package:flutter/material.dart';

// Custom Expansion tile for
// blood donation types in
// data tab
class CustomExpansionTile extends StatelessWidget {
  final String info;
  final String title;
  final bool expand;
  CustomExpansionTile({this.expand, this.title, this.info});
  @override
  Widget build(BuildContext context) {
    Color _cardColor = Theme.of(context).dividerColor;
    Size _size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _size.width * 0.045,
          ),
        ),
        initiallyExpanded: expand,
        childrenPadding: const EdgeInsets.all(8.0),
        children: [
          Text(
            info,
            style: TextStyle(
              fontSize: _size.width * 0.045,
            ),
          )
        ],
      ),
    );
  }
}
