import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/services/app_version_service.dart';

void main() {
  group('AppVersionService.isVersionLower', () {
    test('detects lower patch version', () {
      expect(AppVersionService.isVersionLower('1.0.0', '1.0.1'), isTrue);
      expect(AppVersionService.isVersionLower('1.0.1', '1.0.0'), isFalse);
    });

    test('detects lower minor version', () {
      expect(AppVersionService.isVersionLower('1.0.9', '1.1.0'), isTrue);
      expect(AppVersionService.isVersionLower('1.2.0', '1.1.9'), isFalse);
    });

    test('detects lower major version', () {
      expect(AppVersionService.isVersionLower('1.9.9', '2.0.0'), isTrue);
      expect(AppVersionService.isVersionLower('2.0.0', '1.9.9'), isFalse);
    });

    test('handles equal versions as not lower', () {
      expect(AppVersionService.isVersionLower('1.0.0', '1.0.0'), isFalse);
      expect(AppVersionService.isVersionLower('2.1.3', '2.1.3'), isFalse);
    });

    test('correctly handles build metadata suffix (+1, +10)', () {
      expect(AppVersionService.isVersionLower('1.0.0+1', '1.0.1+2'), isTrue);
      expect(AppVersionService.isVersionLower('1.0.1+1', '1.0.1+5'), isFalse);
    });

    test('handles two-part versions smoothly', () {
      expect(AppVersionService.isVersionLower('1.0', '1.0.1'), isTrue);
      expect(AppVersionService.isVersionLower('1.1', '1.0.5'), isFalse);
    });
  });
}
