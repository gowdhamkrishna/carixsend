// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frb_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FrbTransferEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrbTransferEventCopyWith<$Res> {
  factory $FrbTransferEventCopyWith(
    FrbTransferEvent value,
    $Res Function(FrbTransferEvent) then,
  ) = _$FrbTransferEventCopyWithImpl<$Res, FrbTransferEvent>;
}

/// @nodoc
class _$FrbTransferEventCopyWithImpl<$Res, $Val extends FrbTransferEvent>
    implements $FrbTransferEventCopyWith<$Res> {
  _$FrbTransferEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FrbTransferEvent_StartedImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_StartedImplCopyWith(
    _$FrbTransferEvent_StartedImpl value,
    $Res Function(_$FrbTransferEvent_StartedImpl) then,
  ) = __$$FrbTransferEvent_StartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbTransferEvent_StartedImplCopyWithImpl<$Res>
    extends _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_StartedImpl>
    implements _$$FrbTransferEvent_StartedImplCopyWith<$Res> {
  __$$FrbTransferEvent_StartedImplCopyWithImpl(
    _$FrbTransferEvent_StartedImpl _value,
    $Res Function(_$FrbTransferEvent_StartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbTransferEvent_StartedImpl extends FrbTransferEvent_Started {
  const _$FrbTransferEvent_StartedImpl() : super._();

  @override
  String toString() {
    return 'FrbTransferEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_StartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Started extends FrbTransferEvent {
  const factory FrbTransferEvent_Started() = _$FrbTransferEvent_StartedImpl;
  const FrbTransferEvent_Started._() : super._();
}

/// @nodoc
abstract class _$$FrbTransferEvent_ProgressImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_ProgressImplCopyWith(
    _$FrbTransferEvent_ProgressImpl value,
    $Res Function(_$FrbTransferEvent_ProgressImpl) then,
  ) = __$$FrbTransferEvent_ProgressImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FrbTransferProgress field0});
}

/// @nodoc
class __$$FrbTransferEvent_ProgressImplCopyWithImpl<$Res>
    extends
        _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_ProgressImpl>
    implements _$$FrbTransferEvent_ProgressImplCopyWith<$Res> {
  __$$FrbTransferEvent_ProgressImplCopyWithImpl(
    _$FrbTransferEvent_ProgressImpl _value,
    $Res Function(_$FrbTransferEvent_ProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$FrbTransferEvent_ProgressImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as FrbTransferProgress,
      ),
    );
  }
}

/// @nodoc

class _$FrbTransferEvent_ProgressImpl extends FrbTransferEvent_Progress {
  const _$FrbTransferEvent_ProgressImpl(this.field0) : super._();

  @override
  final FrbTransferProgress field0;

  @override
  String toString() {
    return 'FrbTransferEvent.progress(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_ProgressImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbTransferEvent_ProgressImplCopyWith<_$FrbTransferEvent_ProgressImpl>
  get copyWith =>
      __$$FrbTransferEvent_ProgressImplCopyWithImpl<
        _$FrbTransferEvent_ProgressImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return progress(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return progress?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (progress != null) {
      return progress(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return progress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return progress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (progress != null) {
      return progress(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Progress extends FrbTransferEvent {
  const factory FrbTransferEvent_Progress(final FrbTransferProgress field0) =
      _$FrbTransferEvent_ProgressImpl;
  const FrbTransferEvent_Progress._() : super._();

  FrbTransferProgress get field0;

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbTransferEvent_ProgressImplCopyWith<_$FrbTransferEvent_ProgressImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbTransferEvent_RecoveringImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_RecoveringImplCopyWith(
    _$FrbTransferEvent_RecoveringImpl value,
    $Res Function(_$FrbTransferEvent_RecoveringImpl) then,
  ) = __$$FrbTransferEvent_RecoveringImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FrbRecoveryInfo field0});
}

/// @nodoc
class __$$FrbTransferEvent_RecoveringImplCopyWithImpl<$Res>
    extends
        _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_RecoveringImpl>
    implements _$$FrbTransferEvent_RecoveringImplCopyWith<$Res> {
  __$$FrbTransferEvent_RecoveringImplCopyWithImpl(
    _$FrbTransferEvent_RecoveringImpl _value,
    $Res Function(_$FrbTransferEvent_RecoveringImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$FrbTransferEvent_RecoveringImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as FrbRecoveryInfo,
      ),
    );
  }
}

/// @nodoc

class _$FrbTransferEvent_RecoveringImpl extends FrbTransferEvent_Recovering {
  const _$FrbTransferEvent_RecoveringImpl(this.field0) : super._();

  @override
  final FrbRecoveryInfo field0;

  @override
  String toString() {
    return 'FrbTransferEvent.recovering(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_RecoveringImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbTransferEvent_RecoveringImplCopyWith<_$FrbTransferEvent_RecoveringImpl>
  get copyWith =>
      __$$FrbTransferEvent_RecoveringImplCopyWithImpl<
        _$FrbTransferEvent_RecoveringImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return recovering(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return recovering?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (recovering != null) {
      return recovering(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return recovering(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return recovering?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (recovering != null) {
      return recovering(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Recovering extends FrbTransferEvent {
  const factory FrbTransferEvent_Recovering(final FrbRecoveryInfo field0) =
      _$FrbTransferEvent_RecoveringImpl;
  const FrbTransferEvent_Recovering._() : super._();

  FrbRecoveryInfo get field0;

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbTransferEvent_RecoveringImplCopyWith<_$FrbTransferEvent_RecoveringImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbTransferEvent_VerifyingImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_VerifyingImplCopyWith(
    _$FrbTransferEvent_VerifyingImpl value,
    $Res Function(_$FrbTransferEvent_VerifyingImpl) then,
  ) = __$$FrbTransferEvent_VerifyingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbTransferEvent_VerifyingImplCopyWithImpl<$Res>
    extends
        _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_VerifyingImpl>
    implements _$$FrbTransferEvent_VerifyingImplCopyWith<$Res> {
  __$$FrbTransferEvent_VerifyingImplCopyWithImpl(
    _$FrbTransferEvent_VerifyingImpl _value,
    $Res Function(_$FrbTransferEvent_VerifyingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbTransferEvent_VerifyingImpl extends FrbTransferEvent_Verifying {
  const _$FrbTransferEvent_VerifyingImpl() : super._();

  @override
  String toString() {
    return 'FrbTransferEvent.verifying()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_VerifyingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return verifying();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return verifying?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (verifying != null) {
      return verifying();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return verifying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return verifying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (verifying != null) {
      return verifying(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Verifying extends FrbTransferEvent {
  const factory FrbTransferEvent_Verifying() = _$FrbTransferEvent_VerifyingImpl;
  const FrbTransferEvent_Verifying._() : super._();
}

/// @nodoc
abstract class _$$FrbTransferEvent_CompletedImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_CompletedImplCopyWith(
    _$FrbTransferEvent_CompletedImpl value,
    $Res Function(_$FrbTransferEvent_CompletedImpl) then,
  ) = __$$FrbTransferEvent_CompletedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbTransferEvent_CompletedImplCopyWithImpl<$Res>
    extends
        _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_CompletedImpl>
    implements _$$FrbTransferEvent_CompletedImplCopyWith<$Res> {
  __$$FrbTransferEvent_CompletedImplCopyWithImpl(
    _$FrbTransferEvent_CompletedImpl _value,
    $Res Function(_$FrbTransferEvent_CompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbTransferEvent_CompletedImpl extends FrbTransferEvent_Completed {
  const _$FrbTransferEvent_CompletedImpl() : super._();

  @override
  String toString() {
    return 'FrbTransferEvent.completed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_CompletedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return completed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return completed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Completed extends FrbTransferEvent {
  const factory FrbTransferEvent_Completed() = _$FrbTransferEvent_CompletedImpl;
  const FrbTransferEvent_Completed._() : super._();
}

/// @nodoc
abstract class _$$FrbTransferEvent_FailedImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_FailedImplCopyWith(
    _$FrbTransferEvent_FailedImpl value,
    $Res Function(_$FrbTransferEvent_FailedImpl) then,
  ) = __$$FrbTransferEvent_FailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FrbTransferErrorCode field0});
}

/// @nodoc
class __$$FrbTransferEvent_FailedImplCopyWithImpl<$Res>
    extends _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_FailedImpl>
    implements _$$FrbTransferEvent_FailedImplCopyWith<$Res> {
  __$$FrbTransferEvent_FailedImplCopyWithImpl(
    _$FrbTransferEvent_FailedImpl _value,
    $Res Function(_$FrbTransferEvent_FailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$FrbTransferEvent_FailedImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as FrbTransferErrorCode,
      ),
    );
  }
}

/// @nodoc

class _$FrbTransferEvent_FailedImpl extends FrbTransferEvent_Failed {
  const _$FrbTransferEvent_FailedImpl(this.field0) : super._();

  @override
  final FrbTransferErrorCode field0;

  @override
  String toString() {
    return 'FrbTransferEvent.failed(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_FailedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbTransferEvent_FailedImplCopyWith<_$FrbTransferEvent_FailedImpl>
  get copyWith =>
      __$$FrbTransferEvent_FailedImplCopyWithImpl<
        _$FrbTransferEvent_FailedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return failed(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return failed?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Failed extends FrbTransferEvent {
  const factory FrbTransferEvent_Failed(final FrbTransferErrorCode field0) =
      _$FrbTransferEvent_FailedImpl;
  const FrbTransferEvent_Failed._() : super._();

  FrbTransferErrorCode get field0;

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbTransferEvent_FailedImplCopyWith<_$FrbTransferEvent_FailedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbTransferEvent_CancelledImplCopyWith<$Res> {
  factory _$$FrbTransferEvent_CancelledImplCopyWith(
    _$FrbTransferEvent_CancelledImpl value,
    $Res Function(_$FrbTransferEvent_CancelledImpl) then,
  ) = __$$FrbTransferEvent_CancelledImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbTransferEvent_CancelledImplCopyWithImpl<$Res>
    extends
        _$FrbTransferEventCopyWithImpl<$Res, _$FrbTransferEvent_CancelledImpl>
    implements _$$FrbTransferEvent_CancelledImplCopyWith<$Res> {
  __$$FrbTransferEvent_CancelledImplCopyWithImpl(
    _$FrbTransferEvent_CancelledImpl _value,
    $Res Function(_$FrbTransferEvent_CancelledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbTransferEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbTransferEvent_CancelledImpl extends FrbTransferEvent_Cancelled {
  const _$FrbTransferEvent_CancelledImpl() : super._();

  @override
  String toString() {
    return 'FrbTransferEvent.cancelled()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbTransferEvent_CancelledImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(FrbTransferProgress field0) progress,
    required TResult Function(FrbRecoveryInfo field0) recovering,
    required TResult Function() verifying,
    required TResult Function() completed,
    required TResult Function(FrbTransferErrorCode field0) failed,
    required TResult Function() cancelled,
  }) {
    return cancelled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(FrbTransferProgress field0)? progress,
    TResult? Function(FrbRecoveryInfo field0)? recovering,
    TResult? Function()? verifying,
    TResult? Function()? completed,
    TResult? Function(FrbTransferErrorCode field0)? failed,
    TResult? Function()? cancelled,
  }) {
    return cancelled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(FrbTransferProgress field0)? progress,
    TResult Function(FrbRecoveryInfo field0)? recovering,
    TResult Function()? verifying,
    TResult Function()? completed,
    TResult Function(FrbTransferErrorCode field0)? failed,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbTransferEvent_Started value) started,
    required TResult Function(FrbTransferEvent_Progress value) progress,
    required TResult Function(FrbTransferEvent_Recovering value) recovering,
    required TResult Function(FrbTransferEvent_Verifying value) verifying,
    required TResult Function(FrbTransferEvent_Completed value) completed,
    required TResult Function(FrbTransferEvent_Failed value) failed,
    required TResult Function(FrbTransferEvent_Cancelled value) cancelled,
  }) {
    return cancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbTransferEvent_Started value)? started,
    TResult? Function(FrbTransferEvent_Progress value)? progress,
    TResult? Function(FrbTransferEvent_Recovering value)? recovering,
    TResult? Function(FrbTransferEvent_Verifying value)? verifying,
    TResult? Function(FrbTransferEvent_Completed value)? completed,
    TResult? Function(FrbTransferEvent_Failed value)? failed,
    TResult? Function(FrbTransferEvent_Cancelled value)? cancelled,
  }) {
    return cancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbTransferEvent_Started value)? started,
    TResult Function(FrbTransferEvent_Progress value)? progress,
    TResult Function(FrbTransferEvent_Recovering value)? recovering,
    TResult Function(FrbTransferEvent_Verifying value)? verifying,
    TResult Function(FrbTransferEvent_Completed value)? completed,
    TResult Function(FrbTransferEvent_Failed value)? failed,
    TResult Function(FrbTransferEvent_Cancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled(this);
    }
    return orElse();
  }
}

abstract class FrbTransferEvent_Cancelled extends FrbTransferEvent {
  const factory FrbTransferEvent_Cancelled() = _$FrbTransferEvent_CancelledImpl;
  const FrbTransferEvent_Cancelled._() : super._();
}
