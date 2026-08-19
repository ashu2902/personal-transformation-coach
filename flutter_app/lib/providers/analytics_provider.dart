import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// Global Provider for Analytics Service
final analyticsServiceProvider = Provider<IAnalyticsService>((ref) {
  return MixpanelAnalyticsService();
});
