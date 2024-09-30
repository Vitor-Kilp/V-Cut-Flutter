import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget topChild;
  final AppBar appBar;

  const CustomAppBar(
      {Key? key,
      this.height = 90.0,
      required this.topChild,
      required this.appBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              spreadRadius: 0.3,
              blurRadius: 5,
              // changes position of shadow
            ),
          ]),
      child: Row(
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 60, maxWidth: windowSize.width - 150),
              child: MoveWindow(child: appBar)),
          SizedBox(width: 150, height: 60, child: topChild),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
