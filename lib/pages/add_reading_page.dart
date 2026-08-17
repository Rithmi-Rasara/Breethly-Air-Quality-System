import 'package:flutter/material.dart';
import '../services/air_quality_service.dart';

class AddReadingPage extends StatefulWidget {
  const AddReadingPage({super.key});

  @override
  State<AddReadingPage> createState() => _AddReadingPageState();
}

class _AddReadingPageState extends State<AddReadingPage> {
  final _aqiController = TextEditingController();
  final _humidityController = TextEditingController();
  final _temperatureController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _aqiController.dispose();
    _humidityController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final aqiText = _aqiController.text.trim();
    final humidityText = _humidityController.text.trim();
    final temperatureText = _temperatureController.text.trim();

    if (aqiText.isEmpty || humidityText.isEmpty || temperatureText.isEmpty) {
      setState(() => _error = "Fields okkoma fill karanna");
      return;
    }

    final aqi = int.tryParse(aqiText);
    final humidity = num.tryParse(humidityText);
    final temperature = num.tryParse(temperatureText);

    if (aqi == null || humidity == null || temperature == null) {
      setState(() => _error = "Numbers witharak danna");
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await AirQualityService.saveReading(
        aqi: aqi,
        condition: AirQualityService.conditionForAqi(aqi),
        humidity: humidity,
        temperature: temperature,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Reading saved!")));
      _aqiController.clear();
      _humidityController.clear();
      _temperatureController.clear();
    } catch (e) {
      setState(() => _error = "Save failed: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060D1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Reading",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field("AQI", _aqiController, "e.g. 86"),
            const SizedBox(height: 16),
            _field("Humidity (%)", _humidityController, "e.g. 64"),
            const SizedBox(height: 16),
            _field("Temperature (°C)", _temperatureController, "e.g. 27"),
            const SizedBox(height: 10),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A9EFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save reading",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0D1628),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
