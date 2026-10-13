# Extra module — HWID & offline local licensing

**Date:** 2026-10-13 · **Author:** Big Pickle (OpenCode) · **Status:** DONE

This module was requested in addition to the Day-3 plan (`P0-11` … `P0-16`): a
hardware fingerprint plus **local** (server-free) licence validation.

## Why Ed25519

A licence must be verifiable offline and must not be forgeable by the app. We
therefore sign licences with **Ed25519**: the vendor keeps the private key and
the app embeds only the public key (`LicenseVerifier.publicKey`). No server and
no secret ever ship inside the app.

## Pieces

| Piece | File | Responsibility |
|---|---|---|
| Raw device id | `lib/core/licensing/device_id_provider.dart` | `DeviceIdProvider.readRawDeviceId()` abstraction (pure `core`). |
| HWID | `lib/core/licensing/hardware_id.dart` | `HardwareId.compute()` = SHA-256 of `flow-pos:<raw>` → 64 hex chars. |
| Licence value | `lib/core/licensing/license.dart` | `License` + canonical payload (id, product, hwid, issuedAt, expiresAt, features). |
| Wire format | `lib/core/licensing/license_key.dart` | `FLOW1.<base64url(payload)>.<base64url(sig)>`; `tryDecode` never throws. |
| Verification | `lib/core/licensing/license_verifier.dart` | Signature → product → device → expiry, returning `Result<License>`. |
| Persistence | `lib/core/licensing/license_store.dart` | `LicenseStore` abstraction. |
| Orchestration | `lib/core/licensing/license_service.dart` | `activate()`, `load()`, `deactivate()`. |
| App adapters | `lib/app/licensing/*` | `device_info_plus` device id + keystore-backed store. |

## Flow

1. The vendor computes the customer's HWID and signs a `License` payload.
2. The customer pastes the `FLOW1.…` key; `LicenseService.activate()` decodes,
   verifies the signature, checks product/device/expiry and, on success, stores
   the raw key in the platform keystore (`SecureLicenseStore`).
3. On every start `LicenseService.load()` re-verifies the stored key, so a
   clock-based expiry or a copied key on another machine is caught locally.

## Failure mapping (reuses the existing `Failure` hierarchy)

| Condition | Failure |
|---|---|
| Bad / forged signature | `CryptoFailure` |
| Wrong product or malformed key | `ValidationFailure` |
| Bound to another device | `PermissionFailure(permission: 'license.device')` |
| Expired | `PermissionFailure(permission: 'license.expired')` |
| Nothing activated | `NotFoundFailure` |

## Shared helper

`canonicalJson` moved to `lib/core/utils/canonical_json.dart`
(`encodeCanonicalJson`) and is now shared by the audit hash chain and licence
signing — one implementation, as the architecture rules require.

## Verification

`test/core/licensing/license_test.dart` (payload round-trip, expiry, key
encode/decode, malformed keys) and
`test/core/licensing/license_service_test.dart` (valid activation + persistence,
wrong device, expired, forged signature, wrong product, malformed key, missing
licence, `load()` re-validation, `deactivate()`).

## Notes / limits

- The host has no platform channels, so tests inject fake `DeviceIdProvider` /
  `LicenseStore`; `device_info_plus` is only touched by the app-layer adapter.
- `HardwareId.namespace` is a salt: changing it invalidates all issued licences.
- A licence is a bearer token once issued; revocation needs a future online
  check (out of scope for the offline-first product).
