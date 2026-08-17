import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final DatabaseReference _currentRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://airqualitysystem-151e4-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('air_monitor/current');

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade600;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.redAccent;
    return Colors.purple;
  }

  String _aqiAdvice(int aqi) {
    if (aqi <= 50) return "Air quality is excellent. Safe for all activities.";
    if (aqi <= 100) return "Air quality is acceptable for indoor activities.";
    if (aqi <= 150) return "Sensitive groups may be affected. Limit exposure.";
    if (aqi <= 200) return "Unhealthy! Reduce prolonged outdoor activities.";
    return "Hazardous! Stay indoors and use air purifiers.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060D1F),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Breethly Air",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: StreamBuilder<DatabaseEvent>(
        stream: _currentRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading data: ${snapshot.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          final raw = snapshot.data?.snapshot.value;
          if (raw == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_off, color: Colors.white38, size: 64),
                  SizedBox(height: 18),
                  Text(
                    "Waiting for AEROGUARD device...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Make sure the NodeMCU is powered\nand connected to WiFi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final data = Map<String, dynamic>.from(raw as Map);

          final int airQuality = (data['aqi'] as num?)?.toInt() ?? 0;
          final String airQualityStatus =
              (data['condition'] as String?) ?? "Unknown";
          final num humidityNum = (data['humidity'] as num?) ?? 0;
          final num temperatureNum = (data['temperature'] as num?) ?? 0;
          final String humidity = "${humidityNum.toStringAsFixed(1)}%";
          final String temperature = "${temperatureNum.toStringAsFixed(1)}°C";

          final bool fanOn = (data['fan'] as bool?) ?? false;
          final bool buzzerOn = (data['buzzer'] as bool?) ?? false;
          final bool purifierOn = (data['purifier'] as bool?) ?? false;
          final bool dehumidifierOn = (data['dehumidifier'] as bool?) ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF13233F), Color(0xFF0D1628)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF1D3B66),
                        child: Icon(Icons.air, color: Colors.white, size: 32),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Indoor Air Quality",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Live data from AEROGUARD device",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Air Quality",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1628),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Current AQI",
                        style: TextStyle(color: Colors.white70, fontSize: 17),
                      ),
                      const SizedBox(height: 18),
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: const Color(0xFF13233F),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$airQuality",
                              style: TextStyle(
                                color: _aqiColor(airQuality),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              airQualityStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _aqiAdvice(airQuality),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Environment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: infoCard(
                        "Humidity",
                        humidity,
                        Icons.water_drop,
                        Colors.cyan,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: infoCard(
                        "Temperature",
                        temperature,
                        Icons.thermostat,
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                const Text(
                  "Device Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1628),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      _deviceRow(
                        icon: Icons.air,
                        label: "Fan",
                        active: fanOn,
                        activeColor: Colors.lightBlueAccent,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      _deviceRow(
                        icon: Icons.notifications_active,
                        label: "Buzzer Alert",
                        active: buzzerOn,
                        activeColor: Colors.redAccent,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      _deviceRow(
                        icon: Icons.cleaning_services,
                        label: "Air Purifier",
                        active: purifierOn,
                        activeColor: Colors.greenAccent,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      _deviceRow(
                        icon: Icons.water,
                        label: "Dehumidifier",
                        active: dehumidifierOn,
                        activeColor: Colors.cyanAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1628),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: buzzerOn
                            ? Colors.red.withOpacity(0.2)
                            : const Color(0xFF17311B),
                        child: Icon(
                          buzzerOn ? Icons.warning_amber : Icons.favorite,
                          color: buzzerOn ? Colors.redAccent : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          buzzerOn
                              ? "⚠️ ALERT: Air quality or temperature is at a dangerous level! Take action immediately."
                              : _aqiAdvice(airQuality),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          } else {
            setState(() {
              currentIndex = 0;
            });
          }
        },
        backgroundColor: const Color(0xFF0D1628),
        selectedItemColor: const Color(0xFF4A9EFF),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }

  static Widget _deviceRow({
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? activeColor.withOpacity(0.18)
              : Colors.white10,
          child: Icon(icon, color: active ? activeColor : Colors.white38),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.18) : Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            active ? "ON" : "OFF",
            style: TextStyle(
              color: active ? activeColor : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  static Widget infoCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1628),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
