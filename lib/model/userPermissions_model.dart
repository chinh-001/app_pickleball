import 'dart:developer' as log;
import '../utils/auth_helper.dart';

class Channel {
  final int id;
  final String token;
  final String code;
  final List<String> permissions;

  Channel({
    required this.id,
    required this.token,
    required this.code,
    required this.permissions,
  });

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      token: map['token'] ?? '',
      code: map['code'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'token': token, 'code': code, 'permissions': permissions};
  }
}

class UserPermissions {
  final int id;
  final String identifier;
  final List<Channel> channels;

  UserPermissions({
    required this.id,
    required this.identifier,
    required this.channels,
  });

  factory UserPermissions.fromMap(Map<String, dynamic> map) {
    return UserPermissions(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      identifier: map['identifier'] ?? '',
      channels:
          (map['channels'] as List?)
              ?.map((channel) => Channel.fromMap(channel))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'channels': channels.map((channel) => channel.toJson()).toList(),
    };
  }

  Future<bool> savePermissionsData() async {
    try {
      await AuthHelper.saveUserPermissionsData(toJson());
      log.log('User permissions saved successfully');
      return true;
    } catch (e) {
      log.log('Error saving user permissions: $e');
      return false;
    }
  }
}
