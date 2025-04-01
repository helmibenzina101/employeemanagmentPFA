// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreServiceHash() => r'7a78f675683f36d2b24ce25eca6b1ef4b3dda632';

/// See also [firestoreService].
@ProviderFor(firestoreService)
final firestoreServiceProvider = Provider<FirestoreService>.internal(
  firestoreService,
  name: r'firestoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreServiceRef = ProviderRef<FirestoreService>;
String _$currentUserStreamHash() => r'5f1073dab61bedcc5ceb85a3d29e8b30822156a4';

/// See also [currentUserStream].
@ProviderFor(currentUserStream)
final currentUserStreamProvider =
    AutoDisposeStreamProvider<UserModel?>.internal(
  currentUserStream,
  name: r'currentUserStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserStreamRef = AutoDisposeStreamProviderRef<UserModel?>;
String _$currentUserDataHash() => r'ee09ffb30d8d644d773a139b0573452bd5fc2955';

/// See also [currentUserData].
@ProviderFor(currentUserData)
final currentUserDataProvider = AutoDisposeProvider<UserModel?>.internal(
  currentUserData,
  name: r'currentUserDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserDataRef = AutoDisposeProviderRef<UserModel?>;
String _$userStreamByIdHash() => r'b2350d65fdd6ac39efb8c7977187f6cea4ce5695';

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

/// See also [userStreamById].
@ProviderFor(userStreamById)
const userStreamByIdProvider = UserStreamByIdFamily();

/// See also [userStreamById].
class UserStreamByIdFamily extends Family<AsyncValue<UserModel?>> {
  /// See also [userStreamById].
  const UserStreamByIdFamily();

  /// See also [userStreamById].
  UserStreamByIdProvider call(
    String userId,
  ) {
    return UserStreamByIdProvider(
      userId,
    );
  }

  @override
  UserStreamByIdProvider getProviderOverride(
    covariant UserStreamByIdProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userStreamByIdProvider';
}

/// See also [userStreamById].
class UserStreamByIdProvider extends AutoDisposeStreamProvider<UserModel?> {
  /// See also [userStreamById].
  UserStreamByIdProvider(
    String userId,
  ) : this._internal(
          (ref) => userStreamById(
            ref as UserStreamByIdRef,
            userId,
          ),
          from: userStreamByIdProvider,
          name: r'userStreamByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userStreamByIdHash,
          dependencies: UserStreamByIdFamily._dependencies,
          allTransitiveDependencies:
              UserStreamByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserStreamByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<UserModel?> Function(UserStreamByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserStreamByIdProvider._internal(
        (ref) => create(ref as UserStreamByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<UserModel?> createElement() {
    return _UserStreamByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserStreamByIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserStreamByIdRef on AutoDisposeStreamProviderRef<UserModel?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserStreamByIdProviderElement
    extends AutoDisposeStreamProviderElement<UserModel?>
    with UserStreamByIdRef {
  _UserStreamByIdProviderElement(super.provider);

  @override
  String get userId => (origin as UserStreamByIdProvider).userId;
}

String _$allActiveUsersStreamHash() =>
    r'56cbeda8024207a415d0637b240257ae3ed1ab96';

/// See also [allActiveUsersStream].
@ProviderFor(allActiveUsersStream)
final allActiveUsersStreamProvider =
    AutoDisposeStreamProvider<List<UserModel>>.internal(
  allActiveUsersStream,
  name: r'allActiveUsersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allActiveUsersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllActiveUsersStreamRef = AutoDisposeStreamProviderRef<List<UserModel>>;
String _$managedUsersStreamHash() =>
    r'ce93352ebad443d63de5e1b34cec04caabe487d8';

/// See also [managedUsersStream].
@ProviderFor(managedUsersStream)
final managedUsersStreamProvider =
    AutoDisposeStreamProvider<List<UserModel>>.internal(
  managedUsersStream,
  name: r'managedUsersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$managedUsersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManagedUsersStreamRef = AutoDisposeStreamProviderRef<List<UserModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
