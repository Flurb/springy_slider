import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFFFF6688),
          scaffoldBackgroundColor: Colors.white),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isOnLight ? Theme.of(context).primaryColor : Colors.white),
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {},
            ),
            actions: <Widget>[_buildTextButton('settings'.toUpperCase(), true)],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SpringySlider(
                    markCount: 12,
                    positiveColor: Theme.of(context).primaryColor,
                    negativeColor: Theme.of(context).scaffoldBackgroundColor),
              ),
              Container(
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    _buildTextButton('more', false),
                    Expanded(
                      child: Container(),
                    ),
                    _buildTextButton('stats', false)
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class SpringySlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringySlider({this.markCount, this.positiveColor, this.negativeColor});

  @override
  _SpringySliderState createState() => _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  double sliderPercent = 0.50;
  double startDragY;
  double startDragPercent;

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = sliderPercent;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height;
    final dragPercent = dragDistance / sliderHeight;

    setState(() {
      sliderPercent = startDragPercent + dragPercent;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      startDragY = null;
      startDragPercent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: <Widget>[
          SliderMarks(
              markCount: widget.markCount,
              color: widget.positiveColor,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom),
          ClipPath(
            clipper: SliderClipper(
                sliderPercent: sliderPercent,
                paddingTop: paddingTop,
                paddingBottom: paddingBottom),
            child: Stack(
              children: <Widget>[
                Container(color: widget.positiveColor),
                SliderMarks(
                    markCount: widget.markCount,
                    color: widget.negativeColor,
                    paddingTop: paddingTop,
                    paddingBottom: paddingBottom)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final height = constraints.maxHeight;
                final sliderY = height * (1.0 - sliderPercent);
                final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
                final pointsYouHave = 100 - pointsYouNeed;
                return Stack(children: <Widget>[
                  Positioned(
                    left: 30.0,
                    top: sliderY - 50.0,
                    child: FractionalTranslation(
                        translation: Offset(0.0, -1.0),
                        child: Points(
                          points: pointsYouNeed,
                          isAboveSlider: true,
                          isPointsYouNeed: true,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                  Positioned(
                    left: 30.0,
                    top: sliderY + 50.0,
                    child: Points(
                      points: pointsYouHave,
                      isAboveSlider: false,
                      isPointsYouNeed: false,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  )
                ]);
              },
            ),
          )
        ],
      ),
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks(
      {this.markCount, this.color, this.paddingTop, this.paddingBottom});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SliderMarksPainter(
          markCount: markCount,
          color: color,
          markThickness: 2.0,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          paddingRight: 20.0),
      child: Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;

  final int markCount;
  final Color color;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;

  SliderMarksPainter(
      {this.markCount,
      this.color,
      this.markThickness,
      this.paddingTop,
      this.paddingBottom,
      this.paddingRight})
      : markPaint = Paint()
          ..color = color
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        markWidth = lerpDouble(smallMarkWidth, largeMarkWidth, 0.5);
      }

      final markY = i * gap + paddingTop;

      canvas.drawLine(Offset(size.width - paddingRight - markWidth, markY),
          Offset(size.width - paddingRight, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SliderClipper extends CustomClipper<Path> {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({this.sliderPercent, this.paddingTop, this.paddingBottom});

  @override
  Path getClip(Size size) {
    Path rect = Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromBottom = 1.0 - sliderPercent;

    rect.addRect(Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  Points(
      {this.points,
      this.isAboveSlider = true,
      this.isPointsYouNeed = true,
      this.color});

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);

    return Row(
      crossAxisAlignment:
          isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        FractionalTranslation(
          translation: Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: Text('$points',
              style: TextStyle(fontSize: pointTextSize, color: color)),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text('POINTS',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color)),
              ),
              Text(
                isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              )
            ],
          ),
        )
      ],
    );
  }
}
