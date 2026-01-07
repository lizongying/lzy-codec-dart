import 'package:lzy_codec/lzy_codec.dart';
import 'dart:convert';
import 'dart:typed_data';

// 测试示例
void main() {
  // 测试编码和解码
  const testStr = "Hello 世界! 👋";

  // 字符串转LZY编码
  final lzyBytes = Lzy.encodeFromString(testStr);
  print("LZY编码字节: $lzyBytes");

  // LZY编码转回字符串
  final decodedStr = Lzy.decodeToString(lzyBytes);
  print("解码后的字符串: $decodedStr");
  print("编码解码是否一致: ${testStr == decodedStr}");

  // 测试UTF-8字节转换
  final utf8Bytes = Uint8List.fromList(utf8.encode(testStr));
  final lzyFromUtf8 = Lzy.encodeFromBytes(utf8Bytes);
  final decodedUtf8 = Lzy.decodeToBytes(lzyFromUtf8);
  print("UTF-8解码是否一致: ${utf8.decode(utf8Bytes) == utf8.decode(decodedUtf8)}");
}