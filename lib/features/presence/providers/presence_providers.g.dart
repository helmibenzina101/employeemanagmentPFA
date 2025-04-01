// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeEntriesForPeriodHash() =>
    r'f51f437b7968a1685fea7ba7dbb3cc5b3c3f9a28';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provides a stream of time entries for the current user within a specified date range.
///
/// Copied from [timeEntriesForPeriod].
@ProviderFor(timeEntriesForPeriod)
const timeEntriesForPeriodProvider = TimeEntriesForPeriodFamily();

/// Provides a stream of time entries for the current user within a specified date range.
///
/// Copied from [timeEntriesForPeriod].
class TimeEntriesForPeriodFamily
    extends Family<AsyncValue<List<TimeEntryModel>>> {
  /// Provides a stream of time entries for the current user within a specified date range.
  ///
  /// Copied from [timeEntriesForPeriod].
  const TimeEntriesForPeriodFamily();

  /// Provides a stream of time entries for the current user within a specified date range.
  ///
  /// Copied from [timeEntriesForPeriod].
  TimeEntriesForPeriodProvider call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return TimeEntriesForPeriodProvider(
      startDate,
      endDate,
    );
  }

  @override
  TimeEntriesForPeriodProvider getProviderOverride(
    covariant TimeEntriesForPeriodProvider provider,
  ) {
    return call(
      provider.startDate,
      provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timeEntriesForPeriodProvider';
}

/// Provides a stream of time entries for the current user within a specified date range.
///
/// Copied from [timeEntriesForPeriod].
class TimeEntriesForPeriodProvider
    extends AutoDisposeStreamProvider<List<TimeEntryModel>> {
  /// Provides a stream of time entries for the current user within a specified date range.
  ///
  /// Copied from [timeEntriesForPeriod].
  TimeEntriesForPeriodProvider(
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => timeEntriesForPeriod(
            ref as TimeEntriesForPeriodRef,
            startDate,
            endDate,
          ),
          from: timeEntriesForPeriodProvider,
          name: r'timeEntriesForPeriodProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeEntriesForPeriodHash,
          dependencies: TimeEntriesForPeriodFamily._dependencies,
          allTransitiveDependencies:
              TimeEntriesForPeriodFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  TimeEntriesForPeriodProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    Stream<List<TimeEntryModel>> Function(TimeEntriesForPeriodRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeEntriesForPeriodProvider._internal(
        (ref) => create(ref as TimeEntriesForPeriodRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeEntryModel>> createElement() {
    return _TimeEntriesForPeriodProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeEntriesForPeriodProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeEntriesForPeriodRef
    on AutoDisposeStreamProviderRef<List<TimeEntryModel>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _TimeEntriesForPeriodProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeEntryModel>>
    with TimeEntriesForPeriodRef {
  _TimeEntriesForPeriodProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as TimeEntriesForPeriodProvider).startDate;
  @override
  DateTime get endDate => (origin as TimeEntriesForPeriodProvider).endDate;
}

String _$lastTimeEntryHash() => r'459d4669c98ad0fe5dc804fba7961a3078113e3c';

/// Provides a stream of the single most recent time entry for the current user.
/// Useful for determining current clock-in/out/break status.
///
/// Copied from [lastTimeEntry].
@ProviderFor(lastTimeEntry)
final lastTimeEntryProvider =
    AutoDisposeStreamProvider<TimeEntryModel?>.internal(
  lastTimeEntry,
  name: r'lastTimeEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastTimeEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastTimeEntryRef = AutoDisposeStreamProviderRef<TimeEntryModel?>;
String _$processedTimesheetHash() =>
    r'7490ad1a88cc7678225c576ae80633e282e925ed';

/// Processes raw time entries for a given period to calculate work/break durations per day.
/// Returns a Future containing the list of processed daily entries.
///
/// Copied from [processedTimesheet].
@ProviderFor(processedTimesheet)
const processedTimesheetProvider = ProcessedTimesheetFamily();

/// Processes raw time entries for a given period to calculate work/break durations per day.
/// Returns a Future containing the list of processed daily entries.
///
/// Copied from [processedTimesheet].
class ProcessedTimesheetFamily
    extends Family<AsyncValue<List<ProcessedDayEntry>>> {
  /// Processes raw time entries for a given period to calculate work/break durations per day.
  /// Returns a Future containing the list of processed daily entries.
  ///
  /// Copied from [processedTimesheet].
  const ProcessedTimesheetFamily();

  /// Processes raw time entries for a given period to calculate work/break durations per day.
  /// Returns a Future containing the list of processed daily entries.
  ///
  /// Copied from [processedTimesheet].
  ProcessedTimesheetProvider call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return ProcessedTimesheetProvider(
      startDate,
      endDate,
    );
  }

  @override
  ProcessedTimesheetProvider getProviderOverride(
    covariant ProcessedTimesheetProvider provider,
  ) {
    return call(
      provider.startDate,
      provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'processedTimesheetProvider';
}

/// Processes raw time entries for a given period to calculate work/break durations per day.
/// Returns a Future containing the list of processed daily entries.
///
/// Copied from [processedTimesheet].
class ProcessedTimesheetProvider
    extends AutoDisposeFutureProvider<List<ProcessedDayEntry>> {
  /// Processes raw time entries for a given period to calculate work/break durations per day.
  /// Returns a Future containing the list of processed daily entries.
  ///
  /// Copied from [processedTimesheet].
  ProcessedTimesheetProvider(
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => processedTimesheet(
            ref as ProcessedTimesheetRef,
            startDate,
            endDate,
          ),
          from: processedTimesheetProvider,
          name: r'processedTimesheetProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$processedTimesheetHash,
          dependencies: ProcessedTimesheetFamily._dependencies,
          allTransitiveDependencies:
              ProcessedTimesheetFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  ProcessedTimesheetProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<ProcessedDayEntry>> Function(ProcessedTimesheetRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProcessedTimesheetProvider._internal(
        (ref) => create(ref as ProcessedTimesheetRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProcessedDayEntry>> createElement() {
    return _ProcessedTimesheetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProcessedTimesheetProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProcessedTimesheetRef
    on AutoDisposeFutureProviderRef<List<ProcessedDayEntry>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _ProcessedTimesheetProviderElement
    extends AutoDisposeFutureProviderElement<List<ProcessedDayEntry>>
    with ProcessedTimesheetRef {
  _ProcessedTimesheetProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as ProcessedTimesheetProvider).startDate;
  @override
  DateTime get endDate => (origin as ProcessedTimesheetProvider).endDate;
}

String _$clockControllerHash() => r'31c8c11896ded7a8be1d2c79e2e494d928e60324';

/// Manages the logic and state for clocking actions (in, out, break start/end).
///
/// Copied from [ClockController].
@ProviderFor(ClockController)
final clockControllerProvider =
    AutoDisposeAsyncNotifierProvider<ClockController, void>.internal(
  ClockController.new,
  name: r'clockControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clockControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClockController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
