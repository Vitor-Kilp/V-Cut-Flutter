import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowsControls extends StatelessWidget {
  const WindowsControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(

      color: Theme.of(context).colorScheme.surface,
      child: WindowTitleBarBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MoveWindow()),
            Row(
              
              children: [
                MinimizeWindowButton(
                  colors: WindowButtonColors(
                      iconNormal: Theme.of(context).primaryColor,
                      iconMouseOver: Theme.of(context).primaryColor,
                      mouseOver: Theme.of(context).colorScheme.surfaceVariant),
                ),
                MaximizeWindowButton(
                  colors: WindowButtonColors(
                      iconMouseOver: Theme.of(context).primaryColor,
                      iconNormal: Theme.of(context).primaryColor,
                      mouseOver: Theme.of(context).colorScheme.surfaceVariant),
                ),
                CloseWindowButton(
                    colors: WindowButtonColors(
                        iconNormal: Theme.of(context).primaryColor,
                        mouseOver: Colors.redAccent)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
