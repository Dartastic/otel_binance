// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_binance/otel_binance.dart';

/// Traces Binance calls with OpenTelemetry.
///
/// `otel_binance` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Binance call in
/// [tracedBinance]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'binance-example');

  // Traces a Binance call.
  final binanceId = await tracedBinance<String>(
    operation: 'create',
    invoke: () async {
      // Make the Binance call here, then report what it returned.
      const id = 'binance_8f3a2c';
      return const BinanceCallResult(
          value: id,
          result: BinanceResult(
              symbol: 'example',
              side: 'example',
              orderType: 'standard',
              orderId: 'order_8f3a2c',
              clientOrderId: 'clientorder_8f3a2c',
              quantity: 0.5,
              price: 0.5,
              commission: 0.5,
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedBinance create returned $binanceId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutBinanceInstrumentationAsync.
  await runWithoutBinanceInstrumentationAsync(
    () => tracedBinance<String>(
      operation: 'create',
      invoke: () async {
        const id = 'binance_8f3a2c';
        return const BinanceCallResult(
            value: id,
            result: BinanceResult(
                symbol: 'example',
                side: 'example',
                orderType: 'standard',
                orderId: 'order_8f3a2c',
                clientOrderId: 'clientorder_8f3a2c',
                quantity: 0.5,
                price: 0.5,
                commission: 0.5,
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
