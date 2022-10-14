import 'package:json_annotation/json_annotation.dart';

part 'proxy_dto.g.dart';

@JsonSerializable()
class ProxyDto {
  final String? host;
  final String? port;
  final String type;
  final String? user;
  final String? password;

  ProxyDto({
    this.host,
    this.port,
    required this.type,
    this.user,
    this.password,
  });

  @override
  String toString() {
    return "$host:$port - $type $user-${(password != null && password!.isNotEmpty) ? password!.replaceRange(1, (password!.length) - 1, "*") : "-"}";
  }

  factory ProxyDto.fromJson(Map<String, dynamic> json) =>
      _$ProxyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProxyDtoToJson(this);
}
