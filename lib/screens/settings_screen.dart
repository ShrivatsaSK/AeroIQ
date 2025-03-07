import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_quality_monitor/providers/sensor_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ipController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(
      text: Provider.of<SensorProvider>(context, listen: false).ipAddress,
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESP32 Connection',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          labelText: 'ESP32 IP Address',
                          hintText: 'e.g. 192.168.1.100',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.wifi),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an IP address';
                          }

                          // Simple IP validation
                          final ipRegex = RegExp(
                              r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

                          if (!ipRegex.hasMatch(value)) {
                            return 'Please enter a valid IP address';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Settings'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('AeroIQ'),
                      subtitle: Text('Version 1.0.1'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.device_hub),
                      title: Text('ESP32 MQ-135 Sensor'),
                      subtitle: Text('Monitors air quality in PPM'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Test Connection'),
                      subtitle: const Text('Check if ESP32 is reachable'),
                      onTap: _testConnection,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SensorProvider>(context, listen: false);
      provider.setIpAddress(_ipController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testConnection() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing connection...'),
          duration: Duration(seconds: 1),
        ),
      );

      final provider = Provider.of<SensorProvider>(context, listen: false);
      await provider.setIpAddress(_ipController.text);
      await provider.fetchData();

      if (provider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}
