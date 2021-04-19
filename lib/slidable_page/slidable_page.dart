import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

double CHILD_ITEM_ASPECT_RATIO = 27.0 / 41.0;

double CHILD_ITEM_WRAPPER_ASPECT_RATIO = CHILD_ITEM_ASPECT_RATIO * 1.2;

typedef Builder<T> = Widget Function(T data);

class SlideWrapper<T> extends StatelessWidget {
  final double currentPage;
  final List<T> data;
  final Builder<T> builder;

  final double padding = 20.0;
  final double hiddenChildVerticalInset = 20.0;

  SlideWrapper(this.data, this.currentPage, {this.builder});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: CHILD_ITEM_WRAPPER_ASPECT_RATIO,
        child: LayoutBuilder(builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          double safeWidth = width - 2 * padding;
          double safeHeight = height - 2 * padding;

          double heightOfPrimaryChild = safeHeight;
          double widthOfPrimaryChild =
              heightOfPrimaryChild * CHILD_ITEM_ASPECT_RATIO;

          double primaryPosterLeft = safeWidth - widthOfPrimaryChild;
          double hiddenPosterHorizontalInset = primaryPosterLeft / 2;

          List<Widget> children = <Widget>[];
          for (int i = 0; i < data.length; i++) {
            final T url = data[i];
            double deltaFromCurrentPage = i - currentPage;
            bool isOnRight = deltaFromCurrentPage > 0;
            if (deltaFromCurrentPage > 1 || deltaFromCurrentPage < -4) {
              continue;
            }
            double opacity = 0.0;
            if (deltaFromCurrentPage < 0) {
              opacity = clamp(1 + 0.33 * deltaFromCurrentPage, 0, 1);
            } else if (deltaFromCurrentPage < 1) {
              opacity = clamp(
                  1 - 2 * (deltaFromCurrentPage - deltaFromCurrentPage.floor()),
                  0,
                  1);
            } else {
              opacity = 0;
            }

            double start = padding +
                max(
                    primaryPosterLeft -
                        hiddenPosterHorizontalInset *
                            -deltaFromCurrentPage *
                            (isOnRight ? 15 : 1),
                    0);

            children.add(Positioned.directional(
              top: padding +
                  hiddenChildVerticalInset * max(-deltaFromCurrentPage, 0.0),
              bottom: padding +
                  hiddenChildVerticalInset * max(-deltaFromCurrentPage, 0.0),
              start: start,
              textDirection: TextDirection.ltr,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: deltaFromCurrentPage < 0
                      ? BoxDecoration(color: Colors.white)
                      : BoxDecoration(),
                  child: Opacity(
                    opacity: opacity,
                    child: AspectRatio(
                      aspectRatio: CHILD_ITEM_ASPECT_RATIO,
                      child: builder(url),
                    ),
                  ),
                ),
              ),
            ));
          }

          return Stack(
            children: children,
          );
        }));
  }
}

class PagerGestureDetector extends StatefulWidget {
  final PagerChildBuilder builder;
  final double pageCount;
  final Duration interval;

  @override
  State createState() => PagerGestureDetectorState();

  PagerGestureDetector({this.builder, this.pageCount, this.interval});
}

typedef PagerChildBuilder = SlideWrapper Function(double);

class PagerGestureDetectorState extends State<PagerGestureDetector>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Timer _timer;
  double page = 0.0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _controller.addListener(() {
      _updatePage(_animation.value);
    });
    super.initState();
    _runTimer();
  }

  _runTimer() {
    _timer = Timer.periodic(widget.interval, (timer) {
      double _page = page;
      if (mounted) {
        if (_page == widget.pageCount)
          _page = 0.0;
        else if (_page < widget.pageCount) _page++;
        _animate(page, _page.roundToDouble());
      } else
        _timer.cancel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _animate(double current, double to) {
    _animation = _controller
        .drive(Tween(begin: current, end: clamp(to, 0, widget.pageCount)));
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (dt) {
          _timer.cancel();
          double width = context.size.width;
          _updatePage(this.page - (dt.primaryDelta / width));
        },
        onHorizontalDragEnd: (dt) {
          if (dt.primaryVelocity / context.size.width > 5) {
            _animate(page, (page - 0.5).roundToDouble());
          } else if (dt.primaryVelocity / context.size.width < -5) {
            _animate(page, (page + 0.5).roundToDouble());
          } else {
            _animate(page, (page).roundToDouble());
          }
          _runTimer();
        },
        child: Stack(children: [
          widget.builder.call(page),
        ]));
  }

  void _updatePage(double page) {
    double max = widget.pageCount;
    final double value = clamp(page, 0, max);
    if (value != this.page)
      setState(() {
        this.page = value;
      });
  }
}

double clamp(double val, double min, double max) {
  if (val < min) return min;
  if (val > max) return max;
  return val;
}
