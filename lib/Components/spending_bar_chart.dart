import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../Models/category_spending.dart';

class SpendingBarChart extends StatelessWidget {
  final List<CategorySpending> data;

  const SpendingBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<CategorySpending, String>> series = [
      charts.Series(
        id: 'Spending',
        data: data,
        domainFn: (CategorySpending spending, _) => spending.category,
        measureFn: (CategorySpending spending, _) => spending.amount,
        // colorFn: (_, __) => charts.MaterialPalette.deepPurple.shadeDefault,
      ),
    ];

    return charts.BarChart(
      series,
      animate: true,
    );
  }
}