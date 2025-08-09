class Participant {
  final String userId;
  final String name;
  final String? avatar;
  final int role; // 0=MEMBER,1=ADMIN,2=OWNER
  final int? joinedAt; // ms epoch
  final String? addedBy;
  final bool muted;
  final bool pinned;
  final bool online;
  final bool isActive;
  final int deliveredMessageIndex;
  final int readMessageIndex;
  final int roleId; // 2 default

  const Participant({
    required this.userId,
    required this.name,
    this.avatar,
    required this.role,
    this.joinedAt,
    this.addedBy,
    required this.muted,
    required this.pinned,
    required this.online,
    required this.isActive,
    required this.deliveredMessageIndex,
    required this.readMessageIndex,
    required this.roleId,
  });

  Participant copyWith({
    String? userId,
    String? name,
    String? avatar,
    int? role,
    int? joinedAt,
    String? addedBy,
    bool? muted,
    bool? pinned,
    bool? online,
    bool? isActive,
    int? deliveredMessageIndex,
    int? readMessageIndex,
    int? roleId,
  }) {
    return Participant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      addedBy: addedBy ?? this.addedBy,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      online: online ?? this.online,
      isActive: isActive ?? this.isActive,
      deliveredMessageIndex: deliveredMessageIndex ?? this.deliveredMessageIndex,
      readMessageIndex: readMessageIndex ?? this.readMessageIndex,
      roleId: roleId ?? this.roleId,
    );
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    // 兼容一次蛇形 -> 驼峰
    int _pickInt(String camel, String snake, int def) {
      final v = map[camel] ?? map[snake];
      if (v == null) return def;
      return v is int ? v : int.tryParse(v.toString()) ?? def;
    }
    bool _pickBool(String key, bool def) {
      final v = map[key];
      if (v == null) return def;
      if (v is bool) return v;
      if (v is num) return v != 0;
      return (v.toString().toLowerCase() == 'true');
    }

    return Participant(
      userId: map['userId'] as String,
      name: (map['name'] ?? '') as String,
      avatar: map['avatar'] as String?,
      role: _pickInt('role', 'role', 0),
      joinedAt: (map['joinedAt'] ?? map['joined_at']) as int?,
      addedBy: (map['addedBy'] ?? map['added_by']) as String?,
      muted: _pickBool('muted', false),
      pinned: _pickBool('pinned', false),
      online: _pickBool('online', false),
      isActive: _pickBool('isActive', map['is_active'] ?? true),
      deliveredMessageIndex: _pickInt('deliveredMessageIndex', 'delivered_message_index', 0),
      readMessageIndex: _pickInt('readMessageIndex', 'read_message_index', 0),
      roleId: _pickInt('roleId', 'roleId', 2),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'role': role,
      'joinedAt': joinedAt,
      'addedBy': addedBy,
      'muted': muted,
      'pinned': pinned,
      'online': online,
      'isActive': isActive,
      'deliveredMessageIndex': deliveredMessageIndex,
      'readMessageIndex': readMessageIndex,
      'roleId': roleId,
    };
  }
}
