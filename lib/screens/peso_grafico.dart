import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PesoGrafico extends StatelessWidget {
  final List<Map<String, dynamic>> medidas;

  PesoGrafico({required this.medidas});

  @override
  Widget build(BuildContext context) {
    if (medidas.isEmpty) {
      return Center(child: Text('Sem dados suficientes para gráfico'));
    }

    final spots = medidas.asMap().entries.map((entry) {
      int index = entry.key;
      final m = entry.value;
      return FlSpot(index.toDouble(), (m['peso'] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.5),
              ],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
