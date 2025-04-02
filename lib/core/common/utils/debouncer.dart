import 'dart:async';

class Debouncer<T> {
  final Duration duration;
  void Function(T value)? action;
  Timer? _timer;

  Debouncer({required this.duration});

  void call(T value) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (action != null) action!(value);
    });
  }
}
