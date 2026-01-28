import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // 🔔 OneSignal App ID
  static const String _oneSignalAppId =
      "42e1a0b9-ab1d-4c80-8a7d-00c0d1cb9fec";

  // 🔐 OneSignal REST API Key
  // ⚠️ For learning / MCA project only
  static const String _restApiKey =
      "os_v2_app_ilq2bonldvgibct5adands475r4ptwik7myemxmo7jnwfgsfsl62r7zfnsm3gidb73oe6hjkyxpmybi7auz2l3lka2a7guqtt4g2hsy";

  /// Send notification when a new product is added
  static Future<void> sendNewProductNotification({
    required String productName,
    required String productImageUrl,
  }) async {
    const String url = "https://onesignal.com/api/v1/notifications";

    final Map<String, dynamic> body = {
      "app_id": _oneSignalAppId,
      "included_segments": ["All"],
      "headings": {
        "en": "🆕 New Product Added"
      },
      "contents": {
        "en": "$productName is now available!"
      },
      "big_picture": productImageUrl, // Android large image
      "android_picture": productImageUrl,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $_restApiKey",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      } else {
        print("❌ Failed to send notification");
        print(response.body);
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
