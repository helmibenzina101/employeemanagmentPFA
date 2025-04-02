// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$absenceReportHash() => r'6e5ac675863ec66db2ad741528d3a38e17ad6986';

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

/// Provider to generate absence report data for a given date range.
/// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
/// Consider server-side aggregation (e.g., Cloud Functions) for production.
///
/// Copied from [absenceReport].
@ProviderFor(absenceReport)
const absenceReportProvider = AbsenceReportFamily();

/// Provider to generate absence report data for a given date range.
/// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
/// Consider server-side aggregation (e.g., Cloud Functions) for production.
///
/// Copied from [absenceReport].
class AbsenceReportFamily extends Family<AsyncValue<AbsenceReportData>> {
  /// Provider to generate absence report data for a given date range.
  /// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
  /// Consider server-side aggregation (e.g., Cloud Functions) for production.
  ///
  /// Copied from [absenceReport].
  const AbsenceReportFamily();

  /// Provider to generate absence report data for a given date range.
  /// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
  /// Consider server-side aggregation (e.g., Cloud Functions) for production.
  ///
  /// Copied from [absenceReport].
  AbsenceReportProvider call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return AbsenceReportProvider(
      startDate,
      endDate,
    );
  }

  @override
  AbsenceReportProvider getProviderOverride(
    covariant AbsenceReportProvider provider,
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
  String? get name => r'absenceReportProvider';
}

/// Provider to generate absence report data for a given date range.
/// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
/// Consider server-side aggregation (e.g., Cloud Functions) for production.
///
/// Copied from [absenceReport].
class AbsenceReportProvider
    extends AutoDisposeFutureProvider<AbsenceReportData> {
  /// Provider to generate absence report data for a given date range.
  /// WARNING: Fetches ALL users and ALL their leave requests. Inefficient for large scale.
  /// Consider server-side aggregation (e.g., Cloud Functions) for production.
  ///
  /// Copied from [absenceReport].
  AbsenceReportProvider(
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => absenceReport(
            ref as AbsenceReportRef,
            startDate,
            endDate,
          ),
          from: absenceReportProvider,
          name: r'absenceReportProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$absenceReportHash,
          dependencies: AbsenceReportFamily._dependencies,
          allTransitiveDependencies:
              AbsenceReportFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  AbsenceReportProvider._internal(
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
    FutureOr<AbsenceReportData> Function(AbsenceReportRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AbsenceReportProvider._internal(
        (ref) => create(ref as AbsenceReportRef),
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
  AutoDisposeFutureProviderElement<AbsenceReportData> createElement() {
    return _AbsenceReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AbsenceReportProvider &&
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
mixin AbsenceReportRef on AutoDisposeFutureProviderRef<AbsenceReportData> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _AbsenceReportProviderElement
    extends AutoDisposeFutureProviderElement<AbsenceReportData>
    with AbsenceReportRef {
  _AbsenceReportProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as AbsenceReportProvider).startDate;
  @override
  DateTime get endDate => (origin as AbsenceReportProvider).endDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
