import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:air_quality_monitor/providers/sensor_provider.dart';
import 'package:air_quality_monitor/widgets/air_quality_card.dart';
import 'package:air_quality_monitor/widgets/sensor_value_card.dart';
import 'package:air_quality_monitor/widgets/mini_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          final currentData = provider.currentData;
          
          return RefreshIndicator(
            onRefresh: () => provider.fetchData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Air Quality Monitor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.error != null)
                          ErrorBanner(error: provider.error!),
                        
                        const SizedBox(height: 16),
                        
                        if (currentData != null) ...[
                          _buildGauge(context, currentData.sensorValue, provider),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Current Readings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: AirQualityCard(
                                  value: currentData.sensorValue,
                                  status: provider.getAirQualityStatus(currentData.sensorValue),
                                  color: provider.getAirQualityColor(currentData.sensorValue),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SensorValueCard(
                                  title: 'ADC Value',
                                  value: currentData.adcValue.toStringAsFixed(0),
                                  icon: Icons.memory,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Recent Trend',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            height: 200,
                            child: MiniChart(data: provider.historicalData),
                          ),
                        ] else if (provider.isLoading) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ] else ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No data available. Pull down to refresh.'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<SensorProvider>(context, listen: false).fetchData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, double value, SensorProvider provider) {
    return SizedBox(
      height: 250,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 2000,
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 500,
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: 50,
                color: Colors.green,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 50,
                endValue: 100,
                color: Colors.lightGreen,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 100,
                endValue: 200,
                color: Colors.yellow,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 200,
                endValue: 300,
                color: Colors.orange,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 300,
                endValue: 500,
                color: Colors.red,
                startWidth: 10,
                endWidth: 10,
              ),
            ],
            pointers: [
              NeedlePointer(
                value: value,
                enableAnimation: true,
                animationDuration: 1000,
                needleColor: Theme.of(context).colorScheme.primary,
                knobStyle: const KnobStyle(
                  knobRadius: 0.09,
                  sizeUnit: GaugeSizeUnit.factor,
                ),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: provider.getAirQualityColor(value),
                      ),
                    ),
                    Text(
                      'PPM',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.getAirQualityStatus(value),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: provider.getAirQualityColor(value),
                      ),
                    ),
                  ],
                ),
                positionFactor: 0.5,
                angle: 90,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String error;

  const ErrorBanner({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

