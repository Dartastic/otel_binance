# otel_binance

Dartastic OpenTelemetry bridge for Binance (crypto exchange).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_binance/otel_binance.dart';

await tracedBinance<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return BinanceCallResult(value: r, result: BinanceResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutBinanceInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
