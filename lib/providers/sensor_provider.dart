import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:air_quality_monitor/models/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  String _ipAddress = '192.168.1.1'; // Default IP address
  SensorData? _currentData;
  List<SensorData> _historicalData = [];
  Timer? _timer;
  bool _isLoading = false;
  String? _error;

  SensorProvider() {
    _loadIpAddress();
    startDataFetching();
  }

  String get ipAddress => _ipAddress;
  SensorData? get currentData => _currentData;
  List<SensorData> get historicalData => _historicalData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString('ip_address') ?? _ipAddress;
    notifyListeners();
  }

  Future<void> setIpAddress(String ip) async {
    _ipAddress = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_address', ip);
    notifyListeners();
    
    // Restart data fetching with new IP
    stopDataFetching();
    startDataFetching();
  }

  void startDataFetching() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchData());
  }

  void stopDataFetching() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('http://$_ipAddress/data'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newData = SensorData(
          sensorValue: data['sensor_value'].toDouble(),
          adcValue: data['adc_value'].toDouble(),
          timestamp: DateTime.now(),
        );
        
        _currentData = newData;
        _historicalData.add(newData);
        
        // Keep only the last 100 readings
        if (_historicalData.length > 100) {
          _historicalData.removeAt(0);
        }
        
        _error = null;
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getAirQualityStatus(double ppm) {
    if (ppm < 50) return 'Excellent';
    if (ppm < 100) return 'Good';
    if (ppm < 200) return 'Moderate';
    if (ppm < 300) return 'Poor';
    return 'Hazardous';
  }

  Color getAirQualityColor(double ppm) {
    if (ppm < 50) return Colors.green;
    if (ppm < 100) return Colors.lightGreen;
    if (ppm < 200) return Colors.yellow;
    if (ppm < 300) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    stopDataFetching();
    super.dispose();
  }
}

