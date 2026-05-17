# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedBinance<T>(...)` — wraps a otel_binance call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutBinanceInstrumentation()` / `Async()`.
