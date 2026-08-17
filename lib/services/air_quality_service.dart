import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String _databaseUrl =
    'https://airqualitysystem-151e4-default-rtdb.asia-southeast1.firebasedatabase.app';

class AirQualityService {
  static final DatabaseReference _rtdbCurrent = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _databaseUrl,
  ).ref('air_monitor/current');

  static final CollectionReference _historyCollection = FirebaseFirestore
      .instance
      .collection('history');

  static Future<void> saveReading({
    required int aqi,
    required String condition,
    required num humidity,
    required num temperature,
  }) async {
    await _rtdbCurrent.set({
      'aqi': aqi,
      'condition': condition,
      'humidity': humidity,
      'temperature': temperature,
      'fan': false,
      'buzzer': false,
      'purifier': false,
      'dehumidifier': false,
    });

    await _historyCollection.add({
      'aqi': aqi,
      'condition': condition,
      'humidity': humidity,
      'temperature': temperature,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static String conditionForAqi(int aqi) {
    if (aqi <= 50) return "Excellent Air";
    if (aqi <= 100) return "Good Indoor Air";
    if (aqi <= 150) return "Moderate Air";
    if (aqi <= 200) return "Unhealthy Air";
    return "Hazardous Air";
  }
}
