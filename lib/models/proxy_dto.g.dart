// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxyDto _$ProxyDtoFromJson(Map<String, dynamic> json) => ProxyDto(
      host: json['host'] as String?,
      port: json['port'] as String?,
      type: json['type'] as String,
      user: json['user'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$ProxyDtoToJson(ProxyDto instance) => <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'type': instance.type,
      'user': instance.user,
      'password': instance.password,
    };
