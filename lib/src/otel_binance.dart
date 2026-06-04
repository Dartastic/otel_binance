// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'binance')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.symbol != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('binance.symbol', res.symbol!)]));
      }
      if (res.side != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('binance.side', res.side!)]));
      }
      if (res.orderType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('binance.order.type', res.orderType!)]));
      }
      if (res.orderId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('binance.order.id', res.orderId!)]));
      }
      if (res.clientOrderId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('binance.client_order.id', res.clientOrderId!)
        ]));
      }
      if (res.quantity != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('binance.quantity', res.quantity!)]));
      }
      if (res.price != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('binance.price', res.price!)]));
      }
      if (res.commission != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('binance.commission', res.commission!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('binance.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('binance.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'binance.error',
          )
        ]));
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
