import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clock.dart';
import 'uuid_v7.dart';

part 'utils_providers.g.dart';

/// The application clock.
///
/// Override in tests with `clockProvider.overrideWithValue(FixedClock(...))`
/// so time-dependent behaviour is deterministic.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

/// The UUIDv7 generator, bound to [clockProvider] so identifiers and timestamps
/// share a single notion of "now".
@Riverpod(keepAlive: true)
UuidV7Generator idGenerator(Ref ref) =>
    UuidV7Generator(clock: ref.watch(clockProvider));
