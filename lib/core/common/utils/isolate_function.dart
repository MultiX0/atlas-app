// isolate_utils.dart

import 'dart:isolate';
import 'dart:async';

import 'package:flutter/services.dart';

Future<dynamic> computeIsolate<T>(Future<T> Function(dynamic) function, dynamic arg) async {
  final receivePort = ReceivePort();
  var rootToken = RootIsolateToken.instance!;
  await Isolate.spawn<_IsolateData>(
    _isolateEntry,
    _IsolateData(
      token: rootToken,
      function: function,
      argument: arg,
      answerPort: receivePort.sendPort,
    ),
  );
  return await receivePort.first;
}

void _isolateEntry(_IsolateData isolateData) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);
  final answer = await isolateData.function(isolateData.argument);
  isolateData.answerPort.send(answer);
}

class _IsolateData {
  final RootIsolateToken token;
  final Function function;
  final dynamic argument;
  final SendPort answerPort;

  _IsolateData({
    required this.token,
    required this.function,
    required this.argument,
    required this.answerPort,
  });
}
