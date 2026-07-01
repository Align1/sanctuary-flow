import 'package:flutter/material.dart';

/// Custom page transition with fade effect
class FadePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;

  FadePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}

/// Custom page transition with slide effect
class SlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;
  final Offset begin;

  SlidePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.begin = const Offset(1.0, 0.0), // Slide from right
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}

/// Custom page transition with scale effect
class ScalePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;

  ScalePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}

/// Combined fade and slide transition
class FadeSlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Duration duration;

  FadeSlidePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 350),
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}
