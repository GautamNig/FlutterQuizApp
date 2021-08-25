import 'Constants.dart';

extension EnumToStringExtension on IdentifierNameEnum {
  String get toShortString => this.toString().split('.').last;
}