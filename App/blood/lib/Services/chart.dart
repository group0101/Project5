import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:math';

/// donor prediction
///
/// Guage chart for predicted probabilities
class GaugeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GaugeChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory GaugeChart.withSampleData() {
    return new GaugeChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Creates a [PieChart] with given data and transition.
  factory GaugeChart.withPredictions(double will, double wont) {
    return new GaugeChart(
      _createDataSegments(will, wont),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 35,
        startAngle: pi,
        arcLength: 2 * pi,
      ),
      animationDuration: Duration(milliseconds: 750),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData() {
    final data = [
      new GaugeSegment(segment: "Low", size: 75),
      new GaugeSegment(segment: 'Acceptable', size: 100),
      new GaugeSegment(segment: 'High', size: 50),
      new GaugeSegment(segment: 'Highly Unusual', size: 5),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        data: data,
      )
    ];
  }

  static List<charts.Series<GaugeSegment, String>> _createDataSegments(
      double will, double wont) {
    // create guage segments with probabilities
    final data = [
      // green guage segment
      new GaugeSegment(
        segment: 'Will Donaate',
        size: will,
        color: charts.Color(
          r: 55,
          g: 222,
          b: 132,
        ),
      ),
      // red guage segment
      new GaugeSegment(
        segment: 'Won\'t Donate',
        size: wont,
        color: charts.Color(
          r: 255,
          g: 23,
          b: 68,
        ),
      ),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => segment.color,
        data: data,
      )
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final double size;
  final charts.Color color;
  GaugeSegment({this.segment, this.size, this.color});
}
