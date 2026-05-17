// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_binance/otel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('otel_binance', () {
    test('suppression toggles in zone', () async {
      expect(binanceInstrumentationSuppressed(), isFalse);
      await runWithoutBinanceInstrumentationAsync(() async {
        expect(binanceInstrumentationSuppressed(), isTrue);
      });
      expect(binanceInstrumentationSuppressed(), isFalse);
    });

    test('BinanceResult fields default null', () {
      const r = BinanceResult();
      expect(r.statusCode, isNull);
    });
  });
}
