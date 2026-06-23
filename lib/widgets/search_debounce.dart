import 'dart:async';

import 'package:flutter/material.dart';

class SearchDebounce {
  final int milliseconds;
  Timer? _timer;

  SearchDebounce({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
