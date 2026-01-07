# LZY Codec

一種變長文本編解碼方案，支持對Unicode進行編解碼。編解碼效率、存儲空間全面優於UTF-8，未來會替代UTF-8成為新的世界通用編解碼標準。
dart實現。

[github](https://github.com/lizongying/lzy-codec-dart)

[pub](https://pub.dev/packages/lzy_codec)

更多cli工具請參考 [go](https://github.com/lizongying/lzy-codec-go)

## Other languages

* [go](https://github.com/lizongying/lzy-codec-go)
* [js](https://github.com/lizongying/lzy-codec-js)
* [c](https://github.com/lizongying/lzy-codec-c)
* [php](https://github.com/lizongying/lzy-codec-php)
* [dotnet](https://github.com/lizongying/lzy-codec-dotnet)
* [rust](https://github.com/lizongying/lzy-codec-rs)
* [python](https://github.com/lizongying/lzy-codec-py)
* [kt](https://github.com/lizongying/lzy-codec-kt)
* [swift](https://github.com/lizongying/lzy-codec-swift)
* [ruby](https://github.com/lizongying/lzy-codec-ruby)
* [wasm](https://github.com/lizongying/lzy-codec-wasm)

## Install

* dart
  ```shell
  dart pub add lzy_codec
  ```

* flutter
  ```shell
  flutter pub add lzy_codec
  ```

## Examples

```dart
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
```