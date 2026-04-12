import 'dart:convert';

import 'package:eschool/data/models/notification.dart';
import 'package:eschool/data/models/notificationDetails.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/hiveBoxKeys.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  static Future<void> addNotification(
      {required NotificationDetails notificationDetails}) async {
    try {
      await Hive.box(notificationsBoxKey).put(
          notificationDetails.createdAt.toString(),
          notificationDetails.toJson());
    } catch (_) {}
  }

  static Future<void> addNotificationTemporarily(
      {required Map<String, dynamic> data}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      List<String> notifications =
          sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
              List<String>.from([]);

      notifications.add(jsonEncode(data));

      await sharedPreferences.setStringList(
          temporarilyStoredNotificationsKey, notifications);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>>
      getTemporarilyStoredNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notifications =
        sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
            List<String>.from([]);

    return notifications
        .map((notificationData) =>
            Map<String, dynamic>.from(jsonDecode(notificationData) ?? {}))
        .toList();
  }

  static Future<void> clearTemporarilyNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(temporarilyStoredNotificationsKey, []);
  }

  /// Fetch notifications from API with pagination support
  Future<Map<String, dynamic>> fetchNotifications({
    int? page,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (page != null && page > 0) {
        queryParameters['page'] = page;
      }

      if (kDebugMode) {
        debugPrint('Fetching notifications with params: $queryParameters');
      }

      final result = await Api.get(
        url: Api.notifications,
        useAuthToken: true,
        queryParameters: queryParameters,
      );

      if (kDebugMode) {
        debugPrint('Notifications API response: $result');
      }

      // Handle both response formats:
      // 1. Paginated: {data: {data: [...], last_page: x, current_page: y, total: z}}
      // 2. Direct array: {data: [...]}
      final data = result['data'];

      List<dynamic> notificationsList;
      int totalPage;
      int currentPage;
      int total;

      if (data is List) {
        // Direct array format
        notificationsList = data;
        totalPage = 1;
        currentPage = 1;
        total = data.length;
      } else if (data is Map<String, dynamic>) {
        // Paginated format
        notificationsList = (data['data'] as List?) ?? [];
        totalPage = (data['last_page'] as int?) ?? 1;
        currentPage = (data['current_page'] as int?) ?? 1;
        total = (data['total'] as int?) ?? notificationsList.length;
      } else {
        throw ApiException('Unexpected response format');
      }

      return {
        'notifications': notificationsList
            .map((e) => Notification.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        'totalPage': totalPage,
        'currentPage': currentPage,
        'total': total,
      };
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Error fetching notifications: $e');
        debugPrint('Stack trace: $st');
      }
      throw ApiException(e.toString());
    }
  }
}
