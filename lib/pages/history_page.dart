import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int currentIndex = 1;

  final CollectionReference _historyCollection = FirebaseFirestore.instance
      .collection('history');

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade600;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.redAccent;
    return Colors.purple;
  }

  String _formatDate(DateTime dt) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }

  String _formatTime(DateTime dt) {
    final hour24 = dt.hour;
    final period = hour24 >= 12 ? "PM" : "AM";
    int hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour12:$minute $period";
  }

  Map<String, dynamic> _mapDoc(Map<String, dynamic> raw) {
    final int aqi = (raw['aqi'] as num?)?.toInt() ?? 0;
    final String status = (raw['condition'] as String?) ?? "Unknown";

    // Humidity and temperature can arrive as num or string
    String _fmt(dynamic v, String unit) {
      if (v == null) return '--$unit';
      final n = num.tryParse(v.toString());
      return n != null ? '${n.toStringAsFixed(1)}$unit' : '$v$unit';
    }

    final String humidity    = _fmt(raw['humidity'],    '%');
    final String temperature = _fmt(raw['temperature'], '°C');

    DateTime dt;

    // Priority 1: Firestore server Timestamp (set by app's AddReadingPage)
    final ts = raw['timestamp'];
    if (ts is Timestamp) {
      dt = ts.toDate();
    }
    // Priority 2: Unix epoch integer written by Arduino (field: ts_epoch)
    else if (raw['ts_epoch'] is num) {
      dt = DateTime.fromMillisecondsSinceEpoch(
        ((raw['ts_epoch'] as num).toInt()) * 1000,
      );
    }
    // Priority 3: dateTime string written by Arduino ("YYYY-MM-DD HH:MM:SS")
    else if (raw['dateTime'] is String) {
      try {
        // Arduino writes "2025-08-17 09:30:00" — replace space with T for parse
        dt = DateTime.parse(
          (raw['dateTime'] as String).replaceFirst(' ', 'T'),
        );
      } catch (_) {
        dt = DateTime(2000);
      }
    }
    // Fallback
    else {
      dt = DateTime(2000);
    }

    return {
      "date": _formatDate(dt),
      "time": _formatTime(dt),
      "aqi": "$aqi",
      "status": status,
      "humidity": humidity,
      "temperature": temperature,
      "color": _aqiColor(aqi),
      "_sortKey": dt,
    };
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
          "History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _historyCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading history: ${snapshot.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No history yet.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final history =
              docs
                  .map((d) => _mapDoc(d.data() as Map<String, dynamic>))
                  .toList()
                ..sort(
                  (a, b) => (b["_sortKey"] as DateTime).compareTo(
                    a["_sortKey"] as DateTime,
                  ),
                ); // newest first

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailPage(data: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1628),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: item["color"],
                          child: const Icon(Icons.air, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["date"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "AQI ${item["aqi"]} - ${item["status"]}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["time"],
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white38,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
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
}

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060D1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "History Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF13233F), Color(0xFF0D1628)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: data["color"],
                    child: const Icon(Icons.air, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data["date"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data["time"],
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1628),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(Icons.air, color: Colors.lightBlue, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    data["aqi"],
                    style: TextStyle(
                      color: data["color"],
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data["status"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Environment Details",
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
                  child: detailCard(
                    "Humidity",
                    data["humidity"],
                    Icons.water_drop,
                    Colors.cyan,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: detailCard(
                    "Temperature",
                    data["temperature"],
                    Icons.thermostat,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

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
                    backgroundColor: (data["color"] as Color).withOpacity(0.15),
                    child: Icon(Icons.info_outline, color: data["color"]),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Recorded on ${data["date"]} at ${data["time"]}. "
                      "These are the air-quality, humidity and temperature readings "
                      "saved for this date.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  static Widget detailCard(
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
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
