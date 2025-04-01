// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewsForEmployeeHash() =>
    r'd58af1f521e5f646f201c34fa56d66f25c3600cb';

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

/// Provides a real-time stream of performance reviews FOR a specific employee.
///
/// Copied from [reviewsForEmployee].
@ProviderFor(reviewsForEmployee)
const reviewsForEmployeeProvider = ReviewsForEmployeeFamily();

/// Provides a real-time stream of performance reviews FOR a specific employee.
///
/// Copied from [reviewsForEmployee].
class ReviewsForEmployeeFamily
    extends Family<AsyncValue<List<PerformanceReviewModel>>> {
  /// Provides a real-time stream of performance reviews FOR a specific employee.
  ///
  /// Copied from [reviewsForEmployee].
  const ReviewsForEmployeeFamily();

  /// Provides a real-time stream of performance reviews FOR a specific employee.
  ///
  /// Copied from [reviewsForEmployee].
  ReviewsForEmployeeProvider call(
    String employeeId,
  ) {
    return ReviewsForEmployeeProvider(
      employeeId,
    );
  }

  @override
  ReviewsForEmployeeProvider getProviderOverride(
    covariant ReviewsForEmployeeProvider provider,
  ) {
    return call(
      provider.employeeId,
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
  String? get name => r'reviewsForEmployeeProvider';
}

/// Provides a real-time stream of performance reviews FOR a specific employee.
///
/// Copied from [reviewsForEmployee].
class ReviewsForEmployeeProvider
    extends AutoDisposeStreamProvider<List<PerformanceReviewModel>> {
  /// Provides a real-time stream of performance reviews FOR a specific employee.
  ///
  /// Copied from [reviewsForEmployee].
  ReviewsForEmployeeProvider(
    String employeeId,
  ) : this._internal(
          (ref) => reviewsForEmployee(
            ref as ReviewsForEmployeeRef,
            employeeId,
          ),
          from: reviewsForEmployeeProvider,
          name: r'reviewsForEmployeeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reviewsForEmployeeHash,
          dependencies: ReviewsForEmployeeFamily._dependencies,
          allTransitiveDependencies:
              ReviewsForEmployeeFamily._allTransitiveDependencies,
          employeeId: employeeId,
        );

  ReviewsForEmployeeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.employeeId,
  }) : super.internal();

  final String employeeId;

  @override
  Override overrideWith(
    Stream<List<PerformanceReviewModel>> Function(
            ReviewsForEmployeeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReviewsForEmployeeProvider._internal(
        (ref) => create(ref as ReviewsForEmployeeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        employeeId: employeeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PerformanceReviewModel>>
      createElement() {
    return _ReviewsForEmployeeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewsForEmployeeProvider &&
        other.employeeId == employeeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, employeeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewsForEmployeeRef
    on AutoDisposeStreamProviderRef<List<PerformanceReviewModel>> {
  /// The parameter `employeeId` of this provider.
  String get employeeId;
}

class _ReviewsForEmployeeProviderElement
    extends AutoDisposeStreamProviderElement<List<PerformanceReviewModel>>
    with ReviewsForEmployeeRef {
  _ReviewsForEmployeeProviderElement(super.provider);

  @override
  String get employeeId => (origin as ReviewsForEmployeeProvider).employeeId;
}

String _$reviewsForManagedUsersHash() =>
    r'7355ca6abbf616704b8b4a3ea5e554e115dcddae';

/// Provider that fetches performance reviews for all users directly managed by the current user.
/// Returns a Future that resolves once all data is fetched for the initial load.
///
/// Copied from [reviewsForManagedUsers].
@ProviderFor(reviewsForManagedUsers)
final reviewsForManagedUsersProvider =
    AutoDisposeFutureProvider<List<PerformanceReviewModel>>.internal(
  reviewsForManagedUsers,
  name: r'reviewsForManagedUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewsForManagedUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewsForManagedUsersRef
    = AutoDisposeFutureProviderRef<List<PerformanceReviewModel>>;
String _$performanceReviewControllerHash() =>
    r'd9f64828376d6ffd73f4ce74c99284dd5d2dcf30';

/// See also [PerformanceReviewController].
@ProviderFor(PerformanceReviewController)
final performanceReviewControllerProvider = AutoDisposeAsyncNotifierProvider<
    PerformanceReviewController, void>.internal(
  PerformanceReviewController.new,
  name: r'performanceReviewControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceReviewControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PerformanceReviewController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
