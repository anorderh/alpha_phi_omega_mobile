///
/// Page transitions
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route getScaleTransition(Widget page) {
  return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      reverseTransitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleTween = Tween(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutExpo));
        var fadeTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.ease));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      });
}

Route getSlideTransition(Widget page, String direction) {
  return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      reverseTransitionDuration: Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var slideTween = Tween(
            begin: Offset(direction == "right" ? -1 : 1, 0),
            end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        );
      });
}

Route getFadeTransition(Widget page) {
  return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 150),
      reverseTransitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.ease));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        );
      });
}

void pushToNew(
    {required BuildContext context,
      required bool withNavBar,
      required Widget page,
      required String transition}) {
  if (transition == "scale") {
    Navigator.of(context, rootNavigator: !withNavBar)
        .push(getScaleTransition(page));
  } else if (transition == "fade") {
    Navigator.of(context, rootNavigator: !withNavBar)
        .push(getFadeTransition(page));
  } else if (transition.contains("slide")) {
    Navigator.of(context, rootNavigator: !withNavBar)
        .push(getSlideTransition(page, transition.split(" ")[1]));
  } else {
    Navigator.of(context, rootNavigator: !withNavBar)
        .push(MaterialPageRoute(builder: (context) => page));
  }
}
