import 'dart:convert';
import 'dart:typed_data';

class Lzy {
  // 定义常量，与原Kotlin版本保持一致
  static const int _surrogateMin = 0xD800;
  static const int _surrogateMax = 0xDFFF;
  static const int _unicodeMax = 0x10FFFF;
  static ArgumentError get _errorUnicode => ArgumentError("invalid unicode");

  /// 验证Unicode码点是否有效（排除代理区字符）
  ///
  /// [r] Unicode码点
  /// 返回有效性标识
  static bool validUnicode(int r) {
    return (r >= 0 && r < _surrogateMin) ||
        (r > _surrogateMax && r <= _unicodeMax);
  }

  /// 将Unicode码点列表转换为LZY编码的字节数组
  ///
  /// [inputRunes] 整数列表，每个元素是有效的Unicode码点
  /// 返回LZY编码的Uint8List
  static Uint8List encode(List<int> inputRunes) {
    final List<int> byteList = <int>[];

    for (final int r in inputRunes) {
      if (r < 0x80) {
        // 单字节编码：0xxxxxxx
        byteList.add(r & 0xFF);
      } else if (r < 0x4000) {
        // 双字节编码：高7位 + 0x80 | 低7位
        byteList.add((r >> 7) & 0xFF);
        byteList.add((0x80 | (r & 0x7F)) & 0xFF);
      } else {
        // 三字节编码：高7位 + 0x80|中间7位 + 0x80|低7位
        byteList.add((r >> 14) & 0xFF);
        byteList.add((0x80 | ((r >> 7) & 0x7F)) & 0xFF);
        byteList.add((0x80 | (r & 0x7F)) & 0xFF);
      }
    }

    return Uint8List.fromList(byteList);
  }

  /// 将Dart字符串转换为LZY编码的字节数组
  ///
  /// [inputStr] Dart原生字符串
  /// 返回LZY编码的Uint8List
  static Uint8List encodeFromString(String inputStr) {
    // 将字符串转换为Unicode码点列表（Dart的runes已处理代理对）
    final List<int> runes = inputStr.runes.toList();
    return encode(runes);
  }

  /// 将UTF-8编码的字节数组转换为LZY编码的字节数组
  ///
  /// [inputBytes] UTF-8编码的Uint8List
  /// 返回LZY编码的Uint8List
  static Uint8List encodeFromBytes(Uint8List inputBytes) {
    // 先将UTF-8字节解码为Dart字符串
    final String inputStr = utf8.decode(inputBytes);
    return encodeFromString(inputStr);
  }

  /// 将LZY编码的字节数组解码为Unicode码点列表
  ///
  /// [inputBytes] LZY编码的Uint8List
  /// 返回Unicode码点列表
  /// 无效LZY编码或Unicode码点时抛出ArgumentError异常
  static List<int> decode(Uint8List inputBytes) {
    final int length = inputBytes.length;
    if (length == 0) {
      throw _errorUnicode;
    }

    // 寻找第一个最高位为0的字节（有效起始位置）
    int startIdx = -1;
    for (int i = 0; i < length; i++) {
      if ((inputBytes[i] & 0x80) == 0) {
        startIdx = i;
        break;
      }
    }

    if (startIdx == -1) {
      throw _errorUnicode;
    }

    final int validLen = length - startIdx;
    if (validLen == 0) {
      throw _errorUnicode;
    }

    final List<int> output = <int>[];
    int r = 0;

    for (int i = startIdx; i < length; i++) {
      final int b = inputBytes[i] & 0xFF; // 转换为无符号整数
      if ((b >> 7) == 0) {
        // 遇到单字节标记，处理上一个累积的码点（非起始位置）
        if (i > startIdx) {
          if (!validUnicode(r)) {
            throw _errorUnicode;
          }
          output.add(r);
        }
        // 重置为当前单字节值
        r = b;
      } else {
        // 累积码点：左移7位 + 低7位（排除0x80标记位）
        if (r > (_unicodeMax >> 7)) {
          throw _errorUnicode;
        }
        r = (r << 7) | (b & 0x7F);
      }
    }

    // 处理最后一个累积的码点
    if (!validUnicode(r)) {
      throw _errorUnicode;
    }
    output.add(r);

    return output;
  }

  /// 将LZY编码的字节数组解码为Dart原生字符串
  ///
  /// [inputBytes] LZY编码的Uint8List
  /// 返回Dart原生字符串
  /// 无效LZY编码或Unicode码点时抛出ArgumentError异常
  static String decodeToString(Uint8List inputBytes) {
    final List<int> runes = decode(inputBytes);
    final StringBuffer stringBuffer = StringBuffer();

    for (final int r in runes) {
      if (r <= 0xFFFF) {
        // 普通字符，直接转换
        stringBuffer.writeCharCode(r);
      } else {
        // 大于0xFFFF的字符，转换为代理对
        final int offset = r - 0x10000;
        final int highSurrogate = _surrogateMin + (offset >> 10);
        final int lowSurrogate = 0xDC00 + (offset & 0x3FF);
        stringBuffer
          ..writeCharCode(highSurrogate)
          ..writeCharCode(lowSurrogate);
      }
    }

    return stringBuffer.toString();
  }

  /// 将LZY编码的字节数组解码为UTF-8编码的字节数组
  ///
  /// [inputBytes] LZY编码的Uint8List
  /// 返回UTF-8编码的Uint8List
  /// 无效LZY编码或Unicode码点时抛出ArgumentError异常
  static Uint8List decodeToBytes(Uint8List inputBytes) {
    final String outputStr = decodeToString(inputBytes);
    // 将字符串编码为UTF-8字节数组
    return Uint8List.fromList(utf8.encode(outputStr));
  }
}