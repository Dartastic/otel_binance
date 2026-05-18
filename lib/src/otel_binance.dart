// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_binance_suppression.dart';

class BinanceResult {
  const BinanceResult({
    this.symbol,
    this.side,
    this.orderType,
    this.orderId,
    this.clientOrderId,
    this.quantity,
    this.price,
    this.commission,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? symbol;
  final String? side;
  final String? orderType;
  final String? orderId;
  final String? clientOrderId;
  final double? quantity;
  final double? price;
  final double? commission;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class BinanceCallResult<T> {
  const BinanceCallResult({required this.value, this.result});
  final T value;
  final BinanceResult? result;
}

Future<T> tracedBinance<T>({
  required String operation,
  required Future<BinanceCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (binanceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_binance');
  final span = t.startSpan('binance $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'binance');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.symbol != null) {
        span.setStringAttribute('binance.symbol', res.symbol!);
      }
      if (res.side != null) {
        span.setStringAttribute('binance.side', res.side!);
      }
      if (res.orderType != null) {
        span.setStringAttribute('binance.order.type', res.orderType!);
      }
      if (res.orderId != null) {
        span.setStringAttribute('binance.order.id', res.orderId!);
      }
      if (res.clientOrderId != null) {
        span.setStringAttribute('binance.client_order.id', res.clientOrderId!);
      }
      if (res.quantity != null) {
        span.setDoubleAttribute('binance.quantity', res.quantity!);
      }
      if (res.price != null) {
        span.setDoubleAttribute('binance.price', res.price!);
      }
      if (res.commission != null) {
        span.setDoubleAttribute('binance.commission', res.commission!);
      }
      if (res.status != null) {
        span.setStringAttribute('binance.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('binance.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'binance.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
