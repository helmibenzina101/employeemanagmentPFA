// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDocumentsStreamHash() =>
    r'1840680f4e9e1ebf0caa8e4578986f13f0c6c006';

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

/// See also [userDocumentsStream].
@ProviderFor(userDocumentsStream)
const userDocumentsStreamProvider = UserDocumentsStreamFamily();

/// See also [userDocumentsStream].
class UserDocumentsStreamFamily
    extends Family<AsyncValue<List<DocumentMetadataModel>>> {
  /// See also [userDocumentsStream].
  const UserDocumentsStreamFamily();

  /// See also [userDocumentsStream].
  UserDocumentsStreamProvider call(
    String userId,
  ) {
    return UserDocumentsStreamProvider(
      userId,
    );
  }

  @override
  UserDocumentsStreamProvider getProviderOverride(
    covariant UserDocumentsStreamProvider provider,
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
  String? get name => r'userDocumentsStreamProvider';
}

/// See also [userDocumentsStream].
class UserDocumentsStreamProvider
    extends AutoDisposeStreamProvider<List<DocumentMetadataModel>> {
  /// See also [userDocumentsStream].
  UserDocumentsStreamProvider(
    String userId,
  ) : this._internal(
          (ref) => userDocumentsStream(
            ref as UserDocumentsStreamRef,
            userId,
          ),
          from: userDocumentsStreamProvider,
          name: r'userDocumentsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userDocumentsStreamHash,
          dependencies: UserDocumentsStreamFamily._dependencies,
          allTransitiveDependencies:
              UserDocumentsStreamFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserDocumentsStreamProvider._internal(
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
    Stream<List<DocumentMetadataModel>> Function(
            UserDocumentsStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDocumentsStreamProvider._internal(
        (ref) => create(ref as UserDocumentsStreamRef),
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
  AutoDisposeStreamProviderElement<List<DocumentMetadataModel>>
      createElement() {
    return _UserDocumentsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDocumentsStreamProvider && other.userId == userId;
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
mixin UserDocumentsStreamRef
    on AutoDisposeStreamProviderRef<List<DocumentMetadataModel>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDocumentsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<DocumentMetadataModel>>
    with UserDocumentsStreamRef {
  _UserDocumentsStreamProviderElement(super.provider);

  @override
  String get userId => (origin as UserDocumentsStreamProvider).userId;
}

String _$profileEditControllerHash() =>
    r'7a1c3052878f51a4fd19fac86a4fc1710ec7356f';

/// See also [ProfileEditController].
@ProviderFor(ProfileEditController)
final profileEditControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileEditController, void>.internal(
  ProfileEditController.new,
  name: r'profileEditControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileEditControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileEditController = AutoDisposeAsyncNotifier<void>;
String _$documentMetadataControllerHash() =>
    r'da2dcf0d8f9f083abedd23402065749f8ba18a7a';

/// See also [DocumentMetadataController].
@ProviderFor(DocumentMetadataController)
final documentMetadataControllerProvider =
    AutoDisposeAsyncNotifierProvider<DocumentMetadataController, void>.internal(
  DocumentMetadataController.new,
  name: r'documentMetadataControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentMetadataControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DocumentMetadataController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
