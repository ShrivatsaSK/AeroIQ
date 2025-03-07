import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:air_quality_monitor/models/sensor_data.dart';

class MiniChart extends StatelessWidget {
  final List<SensorData> data;

  const MiniChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    // Only show the last 20 readings for the mini chart
    final displayData = data.length > 20 
        ? data.sublist(data.length - 20) 
        : data;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        minX: 0,
        maxX: (displayData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(displayData),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              displayData.length,
              (index) => FlSpot(
                index.toDouble(),
                displayData[index].sensorValue,
              ),
            ),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  double _getMaxY(List<dynamic> data) {
    if (data.isEmpty) return 100;
    double maxValue = 0;
    for (var item in data) {
      if (item.sensorValue > maxValue) {
        maxValue = item.sensorValue;
      }
    }
    return (maxValue * 1.2).ceilToDouble(); // Add 20% padding
  }
}

