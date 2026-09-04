import 'package:flutter/material.dart';

/// Scope lookups on a [BuildContext].
extension BuildContextX on BuildContext {
  /// The nearest [InheritedWidget] of type [T], or null.
  ///
  /// With [listen], this context rebuilds when that widget changes.
  T? scopeMaybeOf<T extends InheritedWidget>({bool listen = true}) =>
      listen ? dependOnInheritedWidgetOfExactType<T>() : getInheritedWidgetOfExactType<T>();

  /// The nearest [InheritedWidget] of type [T]; throws when there is none.
  T scopeOf<T extends InheritedWidget>({bool listen = true}) =>
      scopeMaybeOf<T>(listen: listen) ?? _notFoundInheritedWidgetOfExactType<T>();

  /// The nearest [InheritedModel] of type [T] for [aspect], or null.
  T? maybeInheritFrom<A extends Object, T extends InheritedModel<A>>(A? aspect) =>
      InheritedModel.inheritFrom<T>(this, aspect: aspect);

  /// The nearest [InheritedModel] of type [T] for [aspect]; throws when there is none.
  T inheritFrom<A extends Object, T extends InheritedModel<A>>({A? aspect}) =>
      InheritedModel.inheritFrom<T>(this, aspect: aspect) ??
      (throw ArgumentError('Out of scope, not found inherited model a $T of the exact type', 'out_of_scope'));

  static Never _notFoundInheritedWidgetOfExactType<T extends InheritedWidget>() =>
      throw ArgumentError('Out of scope, not found inherited widget a $T of the exact type', 'out_of_scope');
}
