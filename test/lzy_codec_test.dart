import 'package:lzy_codec/lzy_codec.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Lzy编码解码测试', () {
    // 基础测试用例
    const basicStr = "Hello World!";
    const chineseStr = "你好，世界！";
    const emojiStr = "👋😀🎉"; // 表情符号（多字节Unicode）
    const mixStr = "Dart编码测试 123 👋"; // 混合类型

    // 空字符串边界测试
    test('空字符串编码解码', () {
      expect(Lzy.encodeFromString(""), equals(Uint8List(0)));
      expect(() => Lzy.decodeToString(Uint8List(0)), throwsArgumentError);
    });

    // 基础英文字符测试
    test('基础英文字符编码解码', () {
      final encoded = Lzy.encodeFromString(basicStr);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(basicStr));
    });

    // 中文字符测试
    test('中文字符编码解码', () {
      final encoded = Lzy.encodeFromString(chineseStr);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(chineseStr));
    });

    // 表情符号测试（多字节Unicode）
    test('表情符号编码解码', () {
      final encoded = Lzy.encodeFromString(emojiStr);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(emojiStr));
    });

    // 混合类型测试
    test('混合类型字符编码解码', () {
      final encoded = Lzy.encodeFromString(mixStr);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(mixStr));
    });

    // 无效编码测试
    test('无效LZY编码抛出异常', () {
      // 构造无效编码（全是高位为1的字节）
      final invalidBytes = Uint8List.fromList([0x81, 0x82, 0x83]);
      expect(() => Lzy.decodeToString(invalidBytes), throwsArgumentError);
    });

    // 单字符测试
    test('单字符编码解码', () {
      const singleChar = "A";
      final encoded = Lzy.encodeFromString(singleChar);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(singleChar));
      expect(encoded, equals([65])); // 'A'的ASCII码是65
    });

    // 多字节字符测试（验证编码规则）
    test('多字节Unicode编码规则验证', () {
      // 测试0x4000以上的字符（三字节编码）
      const specialChar = "𝄞"; // 音乐符号，Unicode码点0x1D11E
      final encoded = Lzy.encodeFromString(specialChar);
      final decoded = Lzy.decodeToString(encoded);
      expect(decoded, equals(specialChar));
    });
  });
}