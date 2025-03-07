import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:air_quality_monitor/providers/sensor_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Data'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chart'),
            Tab(text: 'Readings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HistoryChart(),
          HistoryList(),
        ],
      ),
    );
  }
}

class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        final historicalData = provider.historicalData;
        
        if (historicalData.isEmpty) {
          return const Center(
            child: Text('No historical data available yet'),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Air Quality Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Last ${historicalData.length} readings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 50,
                      verticalInterval: 5,
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
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 10,
                          getTitlesWidget: (value, meta) {
                            if (value % 10 != 0 || value >= historicalData.length) {
                              return const SizedBox.shrink();
                            }
                            final index = value.toInt();
                            if (index < 0 || index >= historicalData.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat('HH:mm:ss').format(historicalData[index].timestamp),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    minX: 0,
                    maxX: (historicalData.length - 1).toDouble(),
                    minY: 0,
                    maxY: _getMaxY(historicalData),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          historicalData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            historicalData[index].sensorValue,
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
                ),
              ),
            ],
          ),
        );
      },
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

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        final historicalData = provider.historicalData;
        
        if (historicalData.isEmpty) {
          return const Center(
            child: Text('No historical data available yet'),
          );
        }
        
        // Reverse the list to show newest first
        final reversedData = historicalData.reversed.toList();
        
        return ListView.builder(
          itemCount: reversedData.length,
          itemBuilder: (context, index) {
            final data = reversedData[index];
            final quality = provider.getAirQualityStatus(data.sensorValue);
            final color = provider.getAirQualityColor(data.sensorValue);
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(Icons.air, color: color),
                ),
                title: Text(
                  '${data.sensorValue.toStringAsFixed(1)} PPM',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'ADC: ${data.adcValue.toInt()} | Quality: $quality',
                ),
                trailing: Text(
                  DateFormat('HH:mm:ss').format(data.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

