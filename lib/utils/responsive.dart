import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late double width;

  Responsive(this.context) {
    width = MediaQuery.of(context).size.width;
  }

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  int get gridCount {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  double get imageHeight {
    if (isDesktop) return 240;
    if (isTablet) return 210;
    return 180;
  }

  double get titleFont {
    if (isDesktop) return 16;
    if (isTablet) return 15;
    return 14;
  }

  EdgeInsets get padding {
    if (isDesktop) return const EdgeInsets.all(24);
    if (isTablet) return const EdgeInsets.all(18);
    return const EdgeInsets.all(12);
  }

  double get aspectRatio {
    if (isDesktop) return 0.65;
    if (isTablet) return 0.55;
    return 0.45;
  }
}
