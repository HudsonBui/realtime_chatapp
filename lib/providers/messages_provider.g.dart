// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesNotifierHash() => r'97e2346f8aa59bf1bfa25d61424a4c96c3c07abb';

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

abstract class _$MessagesNotifier
    extends BuildlessAutoDisposeStreamNotifier<List<MessageModel>> {
  late final String chatId;

  Stream<List<MessageModel>> build(
    String chatId,
  );
}

/// See also [MessagesNotifier].
@ProviderFor(MessagesNotifier)
const messagesNotifierProvider = MessagesNotifierFamily();

/// See also [MessagesNotifier].
class MessagesNotifierFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// See also [MessagesNotifier].
  const MessagesNotifierFamily();

  /// See also [MessagesNotifier].
  MessagesNotifierProvider call(
    String chatId,
  ) {
    return MessagesNotifierProvider(
      chatId,
    );
  }

  @override
  MessagesNotifierProvider getProviderOverride(
    covariant MessagesNotifierProvider provider,
  ) {
    return call(
      provider.chatId,
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
  String? get name => r'messagesNotifierProvider';
}

/// See also [MessagesNotifier].
class MessagesNotifierProvider extends AutoDisposeStreamNotifierProviderImpl<
    MessagesNotifier, List<MessageModel>> {
  /// See also [MessagesNotifier].
  MessagesNotifierProvider(
    String chatId,
  ) : this._internal(
          () => MessagesNotifier()..chatId = chatId,
          from: messagesNotifierProvider,
          name: r'messagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesNotifierHash,
          dependencies: MessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              MessagesNotifierFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  MessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  Stream<List<MessageModel>> runNotifierBuild(
    covariant MessagesNotifier notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(MessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesNotifierProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<MessagesNotifier, List<MessageModel>>
      createElement() {
    return _MessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessagesNotifierRef
    on AutoDisposeStreamNotifierProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _MessagesNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<MessagesNotifier,
        List<MessageModel>> with MessagesNotifierRef {
  _MessagesNotifierProviderElement(super.provider);

  @override
  String get chatId => (origin as MessagesNotifierProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
