import 'package:homeconnect/src/models/settings/constraints/setting_constraints.dart';
import 'package:test/test.dart';

void main() {
  group('SettingConstraints', () {
    test('should be able to parse ints from json', () {
      final intJson = {
        'data': {
          'constraints': {
            'allowedvalues': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          },
        },
      };
      final settingConstraints = AllowedValuesPayload.fromJson(intJson);

      expect(settingConstraints.constraints.allowedValues, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('should be able to parse strings from json', () {
      final stringJson = {
        'data': {
          'constraints': {
            'allowedvalues': ["common.setting.option.off", "common.setting.option.on"],
          },
        },
      };
      final settingConstraints = AllowedValuesPayload.fromJson(stringJson);

      expect(settingConstraints.constraints.allowedValues, ["common.setting.option.off", "common.setting.option.on"]);
    });

    test('should return an empty array if allowedvalues is not present', () {
      final emptyJson = {
        'data': {
          'constraints': {},
        },
      };
      final settingConstraints = AllowedValuesPayload.fromJson(emptyJson);

      expect(settingConstraints.constraints.allowedValues, []);
    });
  });
}
