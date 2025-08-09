// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
      'pinyin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastActiveTimeMeta =
      const VerificationMeta('lastActiveTime');
  @override
  late final GeneratedColumn<DateTime> lastActiveTime =
      GeneratedColumn<DateTime>('last_active_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
      'role_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _onlineMeta = const VerificationMeta('online');
  @override
  late final GeneratedColumn<bool> online = GeneratedColumn<bool>(
      'online', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("online" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFriendMeta =
      const VerificationMeta('isFriend');
  @override
  late final GeneratedColumn<bool> isFriend = GeneratedColumn<bool>(
      'is_friend', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_friend" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        name,
        avatar,
        phone,
        email,
        pinyin,
        lastActiveTime,
        status,
        roleId,
        online,
        isFriend,
        nickname,
        remark
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('pinyin')) {
      context.handle(_pinyinMeta,
          pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta));
    }
    if (data.containsKey('last_active_time')) {
      context.handle(
          _lastActiveTimeMeta,
          lastActiveTime.isAcceptableOrUnknown(
              data['last_active_time']!, _lastActiveTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    }
    if (data.containsKey('online')) {
      context.handle(_onlineMeta,
          online.isAcceptableOrUnknown(data['online']!, _onlineMeta));
    }
    if (data.containsKey('is_friend')) {
      context.handle(_isFriendMeta,
          isFriend.isAcceptableOrUnknown(data['is_friend']!, _isFriendMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      pinyin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pinyin']),
      lastActiveTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_active_time']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status']),
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role_id'])!,
      online: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}online'])!,
      isFriend: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_friend'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String userId;
  final String name;
  final String? avatar;
  final String? phone;
  final String? email;
  final String? pinyin;
  final DateTime? lastActiveTime;
  final int? status;
  final int roleId;
  final bool online;
  final bool isFriend;
  final String? nickname;
  final String? remark;
  const User(
      {required this.userId,
      required this.name,
      this.avatar,
      this.phone,
      this.email,
      this.pinyin,
      this.lastActiveTime,
      this.status,
      required this.roleId,
      required this.online,
      required this.isFriend,
      this.nickname,
      this.remark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pinyin != null) {
      map['pinyin'] = Variable<String>(pinyin);
    }
    if (!nullToAbsent || lastActiveTime != null) {
      map['last_active_time'] = Variable<DateTime>(lastActiveTime);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<int>(status);
    }
    map['role_id'] = Variable<int>(roleId);
    map['online'] = Variable<bool>(online);
    map['is_friend'] = Variable<bool>(isFriend);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      userId: Value(userId),
      name: Value(name),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      pinyin:
          pinyin == null && nullToAbsent ? const Value.absent() : Value(pinyin),
      lastActiveTime: lastActiveTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveTime),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      roleId: Value(roleId),
      online: Value(online),
      isFriend: Value(isFriend),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      pinyin: serializer.fromJson<String?>(json['pinyin']),
      lastActiveTime: serializer.fromJson<DateTime?>(json['lastActiveTime']),
      status: serializer.fromJson<int?>(json['status']),
      roleId: serializer.fromJson<int>(json['roleId']),
      online: serializer.fromJson<bool>(json['online']),
      isFriend: serializer.fromJson<bool>(json['isFriend']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'pinyin': serializer.toJson<String?>(pinyin),
      'lastActiveTime': serializer.toJson<DateTime?>(lastActiveTime),
      'status': serializer.toJson<int?>(status),
      'roleId': serializer.toJson<int>(roleId),
      'online': serializer.toJson<bool>(online),
      'isFriend': serializer.toJson<bool>(isFriend),
      'nickname': serializer.toJson<String?>(nickname),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  User copyWith(
          {String? userId,
          String? name,
          Value<String?> avatar = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> pinyin = const Value.absent(),
          Value<DateTime?> lastActiveTime = const Value.absent(),
          Value<int?> status = const Value.absent(),
          int? roleId,
          bool? online,
          bool? isFriend,
          Value<String?> nickname = const Value.absent(),
          Value<String?> remark = const Value.absent()}) =>
      User(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        avatar: avatar.present ? avatar.value : this.avatar,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        pinyin: pinyin.present ? pinyin.value : this.pinyin,
        lastActiveTime:
            lastActiveTime.present ? lastActiveTime.value : this.lastActiveTime,
        status: status.present ? status.value : this.status,
        roleId: roleId ?? this.roleId,
        online: online ?? this.online,
        isFriend: isFriend ?? this.isFriend,
        nickname: nickname.present ? nickname.value : this.nickname,
        remark: remark.present ? remark.value : this.remark,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      lastActiveTime: data.lastActiveTime.present
          ? data.lastActiveTime.value
          : this.lastActiveTime,
      status: data.status.present ? data.status.value : this.status,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      online: data.online.present ? data.online.value : this.online,
      isFriend: data.isFriend.present ? data.isFriend.value : this.isFriend,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pinyin: $pinyin, ')
          ..write('lastActiveTime: $lastActiveTime, ')
          ..write('status: $status, ')
          ..write('roleId: $roleId, ')
          ..write('online: $online, ')
          ..write('isFriend: $isFriend, ')
          ..write('nickname: $nickname, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, name, avatar, phone, email, pinyin,
      lastActiveTime, status, roleId, online, isFriend, nickname, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.pinyin == this.pinyin &&
          other.lastActiveTime == this.lastActiveTime &&
          other.status == this.status &&
          other.roleId == this.roleId &&
          other.online == this.online &&
          other.isFriend == this.isFriend &&
          other.nickname == this.nickname &&
          other.remark == this.remark);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> pinyin;
  final Value<DateTime?> lastActiveTime;
  final Value<int?> status;
  final Value<int> roleId;
  final Value<bool> online;
  final Value<bool> isFriend;
  final Value<String?> nickname;
  final Value<String?> remark;
  final Value<int> rowid;
  const UsersCompanion({
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.lastActiveTime = const Value.absent(),
    this.status = const Value.absent(),
    this.roleId = const Value.absent(),
    this.online = const Value.absent(),
    this.isFriend = const Value.absent(),
    this.nickname = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String userId,
    required String name,
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.lastActiveTime = const Value.absent(),
    this.status = const Value.absent(),
    this.roleId = const Value.absent(),
    this.online = const Value.absent(),
    this.isFriend = const Value.absent(),
    this.nickname = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        name = Value(name);
  static Insertable<User> custom({
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? pinyin,
    Expression<DateTime>? lastActiveTime,
    Expression<int>? status,
    Expression<int>? roleId,
    Expression<bool>? online,
    Expression<bool>? isFriend,
    Expression<String>? nickname,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (pinyin != null) 'pinyin': pinyin,
      if (lastActiveTime != null) 'last_active_time': lastActiveTime,
      if (status != null) 'status': status,
      if (roleId != null) 'role_id': roleId,
      if (online != null) 'online': online,
      if (isFriend != null) 'is_friend': isFriend,
      if (nickname != null) 'nickname': nickname,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? userId,
      Value<String>? name,
      Value<String?>? avatar,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? pinyin,
      Value<DateTime?>? lastActiveTime,
      Value<int?>? status,
      Value<int>? roleId,
      Value<bool>? online,
      Value<bool>? isFriend,
      Value<String?>? nickname,
      Value<String?>? remark,
      Value<int>? rowid}) {
    return UsersCompanion(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pinyin: pinyin ?? this.pinyin,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      status: status ?? this.status,
      roleId: roleId ?? this.roleId,
      online: online ?? this.online,
      isFriend: isFriend ?? this.isFriend,
      nickname: nickname ?? this.nickname,
      remark: remark ?? this.remark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (lastActiveTime.present) {
      map['last_active_time'] = Variable<DateTime>(lastActiveTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (online.present) {
      map['online'] = Variable<bool>(online.value);
    }
    if (isFriend.present) {
      map['is_friend'] = Variable<bool>(isFriend.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pinyin: $pinyin, ')
          ..write('lastActiveTime: $lastActiveTime, ')
          ..write('status: $status, ')
          ..write('roleId: $roleId, ')
          ..write('online: $online, ')
          ..write('isFriend: $isFriend, ')
          ..write('nickname: $nickname, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrentUsersTable extends CurrentUsers
    with TableInfo<$CurrentUsersTable, CurrentUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrentUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastLoginTimeMeta =
      const VerificationMeta('lastLoginTime');
  @override
  late final GeneratedColumn<DateTime> lastLoginTime =
      GeneratedColumn<DateTime>('last_login_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasSetPasswordMeta =
      const VerificationMeta('hasSetPassword');
  @override
  late final GeneratedColumn<bool> hasSetPassword = GeneratedColumn<bool>(
      'has_set_password', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_set_password" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
      'role_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        name,
        avatar,
        phone,
        email,
        lastLoginTime,
        status,
        hasSetPassword,
        roleId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'current_users';
  @override
  VerificationContext validateIntegrity(Insertable<CurrentUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('last_login_time')) {
      context.handle(
          _lastLoginTimeMeta,
          lastLoginTime.isAcceptableOrUnknown(
              data['last_login_time']!, _lastLoginTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('has_set_password')) {
      context.handle(
          _hasSetPasswordMeta,
          hasSetPassword.isAcceptableOrUnknown(
              data['has_set_password']!, _hasSetPasswordMeta));
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CurrentUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrentUser(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      lastLoginTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_login_time']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status']),
      hasSetPassword: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_set_password'])!,
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role_id'])!,
    );
  }

  @override
  $CurrentUsersTable createAlias(String alias) {
    return $CurrentUsersTable(attachedDatabase, alias);
  }
}

class CurrentUser extends DataClass implements Insertable<CurrentUser> {
  final String userId;
  final String name;
  final String? avatar;
  final String? phone;
  final String? email;
  final DateTime? lastLoginTime;
  final int? status;
  final bool hasSetPassword;
  final int roleId;
  const CurrentUser(
      {required this.userId,
      required this.name,
      this.avatar,
      this.phone,
      this.email,
      this.lastLoginTime,
      this.status,
      required this.hasSetPassword,
      required this.roleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || lastLoginTime != null) {
      map['last_login_time'] = Variable<DateTime>(lastLoginTime);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<int>(status);
    }
    map['has_set_password'] = Variable<bool>(hasSetPassword);
    map['role_id'] = Variable<int>(roleId);
    return map;
  }

  CurrentUsersCompanion toCompanion(bool nullToAbsent) {
    return CurrentUsersCompanion(
      userId: Value(userId),
      name: Value(name),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      lastLoginTime: lastLoginTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginTime),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      hasSetPassword: Value(hasSetPassword),
      roleId: Value(roleId),
    );
  }

  factory CurrentUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrentUser(
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      lastLoginTime: serializer.fromJson<DateTime?>(json['lastLoginTime']),
      status: serializer.fromJson<int?>(json['status']),
      hasSetPassword: serializer.fromJson<bool>(json['hasSetPassword']),
      roleId: serializer.fromJson<int>(json['roleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'lastLoginTime': serializer.toJson<DateTime?>(lastLoginTime),
      'status': serializer.toJson<int?>(status),
      'hasSetPassword': serializer.toJson<bool>(hasSetPassword),
      'roleId': serializer.toJson<int>(roleId),
    };
  }

  CurrentUser copyWith(
          {String? userId,
          String? name,
          Value<String?> avatar = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<DateTime?> lastLoginTime = const Value.absent(),
          Value<int?> status = const Value.absent(),
          bool? hasSetPassword,
          int? roleId}) =>
      CurrentUser(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        avatar: avatar.present ? avatar.value : this.avatar,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        lastLoginTime:
            lastLoginTime.present ? lastLoginTime.value : this.lastLoginTime,
        status: status.present ? status.value : this.status,
        hasSetPassword: hasSetPassword ?? this.hasSetPassword,
        roleId: roleId ?? this.roleId,
      );
  CurrentUser copyWithCompanion(CurrentUsersCompanion data) {
    return CurrentUser(
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      lastLoginTime: data.lastLoginTime.present
          ? data.lastLoginTime.value
          : this.lastLoginTime,
      status: data.status.present ? data.status.value : this.status,
      hasSetPassword: data.hasSetPassword.present
          ? data.hasSetPassword.value
          : this.hasSetPassword,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrentUser(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lastLoginTime: $lastLoginTime, ')
          ..write('status: $status, ')
          ..write('hasSetPassword: $hasSetPassword, ')
          ..write('roleId: $roleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, name, avatar, phone, email,
      lastLoginTime, status, hasSetPassword, roleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrentUser &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.lastLoginTime == this.lastLoginTime &&
          other.status == this.status &&
          other.hasSetPassword == this.hasSetPassword &&
          other.roleId == this.roleId);
}

class CurrentUsersCompanion extends UpdateCompanion<CurrentUser> {
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<DateTime?> lastLoginTime;
  final Value<int?> status;
  final Value<bool> hasSetPassword;
  final Value<int> roleId;
  final Value<int> rowid;
  const CurrentUsersCompanion({
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lastLoginTime = const Value.absent(),
    this.status = const Value.absent(),
    this.hasSetPassword = const Value.absent(),
    this.roleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrentUsersCompanion.insert({
    required String userId,
    required String name,
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lastLoginTime = const Value.absent(),
    this.status = const Value.absent(),
    this.hasSetPassword = const Value.absent(),
    this.roleId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        name = Value(name);
  static Insertable<CurrentUser> custom({
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<DateTime>? lastLoginTime,
    Expression<int>? status,
    Expression<bool>? hasSetPassword,
    Expression<int>? roleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (lastLoginTime != null) 'last_login_time': lastLoginTime,
      if (status != null) 'status': status,
      if (hasSetPassword != null) 'has_set_password': hasSetPassword,
      if (roleId != null) 'role_id': roleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrentUsersCompanion copyWith(
      {Value<String>? userId,
      Value<String>? name,
      Value<String?>? avatar,
      Value<String?>? phone,
      Value<String?>? email,
      Value<DateTime?>? lastLoginTime,
      Value<int?>? status,
      Value<bool>? hasSetPassword,
      Value<int>? roleId,
      Value<int>? rowid}) {
    return CurrentUsersCompanion(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      status: status ?? this.status,
      hasSetPassword: hasSetPassword ?? this.hasSetPassword,
      roleId: roleId ?? this.roleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (lastLoginTime.present) {
      map['last_login_time'] = Variable<DateTime>(lastLoginTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (hasSetPassword.present) {
      map['has_set_password'] = Variable<bool>(hasSetPassword.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrentUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lastLoginTime: $lastLoginTime, ')
          ..write('status: $status, ')
          ..write('hasSetPassword: $hasSetPassword, ')
          ..write('roleId: $roleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstMessageIndexMeta =
      const VerificationMeta('firstMessageIndex');
  @override
  late final GeneratedColumn<int> firstMessageIndex = GeneratedColumn<int>(
      'first_message_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMessageIndexMeta =
      const VerificationMeta('lastMessageIndex');
  @override
  late final GeneratedColumn<int> lastMessageIndex = GeneratedColumn<int>(
      'last_message_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMessageTimeMeta =
      const VerificationMeta('lastMessageTime');
  @override
  late final GeneratedColumn<DateTime> lastMessageTime =
      GeneratedColumn<DateTime>('last_message_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>('last_message_preview', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageNameMeta =
      const VerificationMeta('lastMessageName');
  @override
  late final GeneratedColumn<String> lastMessageName = GeneratedColumn<String>(
      'last_message_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<Participant>, String>
      participants = GeneratedColumn<String>('participants', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<Participant>>(
              $ConversationsTable.$converterparticipants);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiresApprovalMeta =
      const VerificationMeta('requiresApproval');
  @override
  late final GeneratedColumn<bool> requiresApproval = GeneratedColumn<bool>(
      'requires_approval', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_approval" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
      'muted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("muted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
      'pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readMessageIndexMeta =
      const VerificationMeta('readMessageIndex');
  @override
  late final GeneratedColumn<int> readMessageIndex = GeneratedColumn<int>(
      'read_message_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReadTimeMeta =
      const VerificationMeta('lastReadTime');
  @override
  late final GeneratedColumn<DateTime> lastReadTime = GeneratedColumn<DateTime>(
      'last_read_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        conversationId,
        type,
        name,
        avatar,
        createdAt,
        createdBy,
        firstMessageIndex,
        lastMessageIndex,
        lastMessageTime,
        lastMessagePreview,
        lastMessageName,
        participants,
        description,
        requiresApproval,
        muted,
        pinned,
        readMessageIndex,
        unreadCount,
        lastReadTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('first_message_index')) {
      context.handle(
          _firstMessageIndexMeta,
          firstMessageIndex.isAcceptableOrUnknown(
              data['first_message_index']!, _firstMessageIndexMeta));
    }
    if (data.containsKey('last_message_index')) {
      context.handle(
          _lastMessageIndexMeta,
          lastMessageIndex.isAcceptableOrUnknown(
              data['last_message_index']!, _lastMessageIndexMeta));
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
          _lastMessageTimeMeta,
          lastMessageTime.isAcceptableOrUnknown(
              data['last_message_time']!, _lastMessageTimeMeta));
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
          _lastMessagePreviewMeta,
          lastMessagePreview.isAcceptableOrUnknown(
              data['last_message_preview']!, _lastMessagePreviewMeta));
    }
    if (data.containsKey('last_message_name')) {
      context.handle(
          _lastMessageNameMeta,
          lastMessageName.isAcceptableOrUnknown(
              data['last_message_name']!, _lastMessageNameMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('requires_approval')) {
      context.handle(
          _requiresApprovalMeta,
          requiresApproval.isAcceptableOrUnknown(
              data['requires_approval']!, _requiresApprovalMeta));
    }
    if (data.containsKey('muted')) {
      context.handle(
          _mutedMeta, muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta));
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta,
          pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('read_message_index')) {
      context.handle(
          _readMessageIndexMeta,
          readMessageIndex.isAcceptableOrUnknown(
              data['read_message_index']!, _readMessageIndexMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('last_read_time')) {
      context.handle(
          _lastReadTimeMeta,
          lastReadTime.isAcceptableOrUnknown(
              data['last_read_time']!, _lastReadTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      firstMessageIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}first_message_index'])!,
      lastMessageIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_message_index'])!,
      lastMessageTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_time']),
      lastMessagePreview: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_message_preview']),
      lastMessageName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_message_name']),
      participants: $ConversationsTable.$converterparticipants.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}participants'])!),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      requiresApproval: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}requires_approval'])!,
      muted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}muted'])!,
      pinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      readMessageIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}read_message_index'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      lastReadTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_read_time']),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<Participant>, String> $converterparticipants =
      const ParticipantListConverter();
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String conversationId;
  final String type;
  final String? name;
  final String? avatar;
  final DateTime createdAt;
  final String? createdBy;
  final int firstMessageIndex;
  final int lastMessageIndex;
  final DateTime? lastMessageTime;
  final String? lastMessagePreview;
  final String? lastMessageName;
  final List<Participant> participants;
  final String? description;
  final bool requiresApproval;
  final bool muted;
  final bool pinned;
  final int readMessageIndex;
  final int unreadCount;
  final DateTime? lastReadTime;
  const Conversation(
      {required this.conversationId,
      required this.type,
      this.name,
      this.avatar,
      required this.createdAt,
      this.createdBy,
      required this.firstMessageIndex,
      required this.lastMessageIndex,
      this.lastMessageTime,
      this.lastMessagePreview,
      this.lastMessageName,
      required this.participants,
      this.description,
      required this.requiresApproval,
      required this.muted,
      required this.pinned,
      required this.readMessageIndex,
      required this.unreadCount,
      this.lastReadTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['first_message_index'] = Variable<int>(firstMessageIndex);
    map['last_message_index'] = Variable<int>(lastMessageIndex);
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime);
    }
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || lastMessageName != null) {
      map['last_message_name'] = Variable<String>(lastMessageName);
    }
    {
      map['participants'] = Variable<String>(
          $ConversationsTable.$converterparticipants.toSql(participants));
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['requires_approval'] = Variable<bool>(requiresApproval);
    map['muted'] = Variable<bool>(muted);
    map['pinned'] = Variable<bool>(pinned);
    map['read_message_index'] = Variable<int>(readMessageIndex);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || lastReadTime != null) {
      map['last_read_time'] = Variable<DateTime>(lastReadTime);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      conversationId: Value(conversationId),
      type: Value(type),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      createdAt: Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      firstMessageIndex: Value(firstMessageIndex),
      lastMessageIndex: Value(lastMessageIndex),
      lastMessageTime: lastMessageTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageTime),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      lastMessageName: lastMessageName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageName),
      participants: Value(participants),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      requiresApproval: Value(requiresApproval),
      muted: Value(muted),
      pinned: Value(pinned),
      readMessageIndex: Value(readMessageIndex),
      unreadCount: Value(unreadCount),
      lastReadTime: lastReadTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadTime),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String?>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      firstMessageIndex: serializer.fromJson<int>(json['firstMessageIndex']),
      lastMessageIndex: serializer.fromJson<int>(json['lastMessageIndex']),
      lastMessageTime: serializer.fromJson<DateTime?>(json['lastMessageTime']),
      lastMessagePreview:
          serializer.fromJson<String?>(json['lastMessagePreview']),
      lastMessageName: serializer.fromJson<String?>(json['lastMessageName']),
      participants:
          serializer.fromJson<List<Participant>>(json['participants']),
      description: serializer.fromJson<String?>(json['description']),
      requiresApproval: serializer.fromJson<bool>(json['requiresApproval']),
      muted: serializer.fromJson<bool>(json['muted']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      readMessageIndex: serializer.fromJson<int>(json['readMessageIndex']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastReadTime: serializer.fromJson<DateTime?>(json['lastReadTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String?>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'firstMessageIndex': serializer.toJson<int>(firstMessageIndex),
      'lastMessageIndex': serializer.toJson<int>(lastMessageIndex),
      'lastMessageTime': serializer.toJson<DateTime?>(lastMessageTime),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'lastMessageName': serializer.toJson<String?>(lastMessageName),
      'participants': serializer.toJson<List<Participant>>(participants),
      'description': serializer.toJson<String?>(description),
      'requiresApproval': serializer.toJson<bool>(requiresApproval),
      'muted': serializer.toJson<bool>(muted),
      'pinned': serializer.toJson<bool>(pinned),
      'readMessageIndex': serializer.toJson<int>(readMessageIndex),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastReadTime': serializer.toJson<DateTime?>(lastReadTime),
    };
  }

  Conversation copyWith(
          {String? conversationId,
          String? type,
          Value<String?> name = const Value.absent(),
          Value<String?> avatar = const Value.absent(),
          DateTime? createdAt,
          Value<String?> createdBy = const Value.absent(),
          int? firstMessageIndex,
          int? lastMessageIndex,
          Value<DateTime?> lastMessageTime = const Value.absent(),
          Value<String?> lastMessagePreview = const Value.absent(),
          Value<String?> lastMessageName = const Value.absent(),
          List<Participant>? participants,
          Value<String?> description = const Value.absent(),
          bool? requiresApproval,
          bool? muted,
          bool? pinned,
          int? readMessageIndex,
          int? unreadCount,
          Value<DateTime?> lastReadTime = const Value.absent()}) =>
      Conversation(
        conversationId: conversationId ?? this.conversationId,
        type: type ?? this.type,
        name: name.present ? name.value : this.name,
        avatar: avatar.present ? avatar.value : this.avatar,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        firstMessageIndex: firstMessageIndex ?? this.firstMessageIndex,
        lastMessageIndex: lastMessageIndex ?? this.lastMessageIndex,
        lastMessageTime: lastMessageTime.present
            ? lastMessageTime.value
            : this.lastMessageTime,
        lastMessagePreview: lastMessagePreview.present
            ? lastMessagePreview.value
            : this.lastMessagePreview,
        lastMessageName: lastMessageName.present
            ? lastMessageName.value
            : this.lastMessageName,
        participants: participants ?? this.participants,
        description: description.present ? description.value : this.description,
        requiresApproval: requiresApproval ?? this.requiresApproval,
        muted: muted ?? this.muted,
        pinned: pinned ?? this.pinned,
        readMessageIndex: readMessageIndex ?? this.readMessageIndex,
        unreadCount: unreadCount ?? this.unreadCount,
        lastReadTime:
            lastReadTime.present ? lastReadTime.value : this.lastReadTime,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      firstMessageIndex: data.firstMessageIndex.present
          ? data.firstMessageIndex.value
          : this.firstMessageIndex,
      lastMessageIndex: data.lastMessageIndex.present
          ? data.lastMessageIndex.value
          : this.lastMessageIndex,
      lastMessageTime: data.lastMessageTime.present
          ? data.lastMessageTime.value
          : this.lastMessageTime,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      lastMessageName: data.lastMessageName.present
          ? data.lastMessageName.value
          : this.lastMessageName,
      participants: data.participants.present
          ? data.participants.value
          : this.participants,
      description:
          data.description.present ? data.description.value : this.description,
      requiresApproval: data.requiresApproval.present
          ? data.requiresApproval.value
          : this.requiresApproval,
      muted: data.muted.present ? data.muted.value : this.muted,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      readMessageIndex: data.readMessageIndex.present
          ? data.readMessageIndex.value
          : this.readMessageIndex,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      lastReadTime: data.lastReadTime.present
          ? data.lastReadTime.value
          : this.lastReadTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('conversationId: $conversationId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('firstMessageIndex: $firstMessageIndex, ')
          ..write('lastMessageIndex: $lastMessageIndex, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageName: $lastMessageName, ')
          ..write('participants: $participants, ')
          ..write('description: $description, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('readMessageIndex: $readMessageIndex, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastReadTime: $lastReadTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      conversationId,
      type,
      name,
      avatar,
      createdAt,
      createdBy,
      firstMessageIndex,
      lastMessageIndex,
      lastMessageTime,
      lastMessagePreview,
      lastMessageName,
      participants,
      description,
      requiresApproval,
      muted,
      pinned,
      readMessageIndex,
      unreadCount,
      lastReadTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.conversationId == this.conversationId &&
          other.type == this.type &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.firstMessageIndex == this.firstMessageIndex &&
          other.lastMessageIndex == this.lastMessageIndex &&
          other.lastMessageTime == this.lastMessageTime &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.lastMessageName == this.lastMessageName &&
          other.participants == this.participants &&
          other.description == this.description &&
          other.requiresApproval == this.requiresApproval &&
          other.muted == this.muted &&
          other.pinned == this.pinned &&
          other.readMessageIndex == this.readMessageIndex &&
          other.unreadCount == this.unreadCount &&
          other.lastReadTime == this.lastReadTime);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> conversationId;
  final Value<String> type;
  final Value<String?> name;
  final Value<String?> avatar;
  final Value<DateTime> createdAt;
  final Value<String?> createdBy;
  final Value<int> firstMessageIndex;
  final Value<int> lastMessageIndex;
  final Value<DateTime?> lastMessageTime;
  final Value<String?> lastMessagePreview;
  final Value<String?> lastMessageName;
  final Value<List<Participant>> participants;
  final Value<String?> description;
  final Value<bool> requiresApproval;
  final Value<bool> muted;
  final Value<bool> pinned;
  final Value<int> readMessageIndex;
  final Value<int> unreadCount;
  final Value<DateTime?> lastReadTime;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.conversationId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.firstMessageIndex = const Value.absent(),
    this.lastMessageIndex = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageName = const Value.absent(),
    this.participants = const Value.absent(),
    this.description = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.readMessageIndex = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastReadTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String conversationId,
    required String type,
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    required DateTime createdAt,
    this.createdBy = const Value.absent(),
    this.firstMessageIndex = const Value.absent(),
    this.lastMessageIndex = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageName = const Value.absent(),
    this.participants = const Value.absent(),
    this.description = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.readMessageIndex = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastReadTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : conversationId = Value(conversationId),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Conversation> custom({
    Expression<String>? conversationId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? firstMessageIndex,
    Expression<int>? lastMessageIndex,
    Expression<DateTime>? lastMessageTime,
    Expression<String>? lastMessagePreview,
    Expression<String>? lastMessageName,
    Expression<String>? participants,
    Expression<String>? description,
    Expression<bool>? requiresApproval,
    Expression<bool>? muted,
    Expression<bool>? pinned,
    Expression<int>? readMessageIndex,
    Expression<int>? unreadCount,
    Expression<DateTime>? lastReadTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (firstMessageIndex != null) 'first_message_index': firstMessageIndex,
      if (lastMessageIndex != null) 'last_message_index': lastMessageIndex,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (lastMessageName != null) 'last_message_name': lastMessageName,
      if (participants != null) 'participants': participants,
      if (description != null) 'description': description,
      if (requiresApproval != null) 'requires_approval': requiresApproval,
      if (muted != null) 'muted': muted,
      if (pinned != null) 'pinned': pinned,
      if (readMessageIndex != null) 'read_message_index': readMessageIndex,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastReadTime != null) 'last_read_time': lastReadTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? conversationId,
      Value<String>? type,
      Value<String?>? name,
      Value<String?>? avatar,
      Value<DateTime>? createdAt,
      Value<String?>? createdBy,
      Value<int>? firstMessageIndex,
      Value<int>? lastMessageIndex,
      Value<DateTime?>? lastMessageTime,
      Value<String?>? lastMessagePreview,
      Value<String?>? lastMessageName,
      Value<List<Participant>>? participants,
      Value<String?>? description,
      Value<bool>? requiresApproval,
      Value<bool>? muted,
      Value<bool>? pinned,
      Value<int>? readMessageIndex,
      Value<int>? unreadCount,
      Value<DateTime?>? lastReadTime,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      firstMessageIndex: firstMessageIndex ?? this.firstMessageIndex,
      lastMessageIndex: lastMessageIndex ?? this.lastMessageIndex,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageName: lastMessageName ?? this.lastMessageName,
      participants: participants ?? this.participants,
      description: description ?? this.description,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      readMessageIndex: readMessageIndex ?? this.readMessageIndex,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (firstMessageIndex.present) {
      map['first_message_index'] = Variable<int>(firstMessageIndex.value);
    }
    if (lastMessageIndex.present) {
      map['last_message_index'] = Variable<int>(lastMessageIndex.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (lastMessageName.present) {
      map['last_message_name'] = Variable<String>(lastMessageName.value);
    }
    if (participants.present) {
      map['participants'] = Variable<String>(
          $ConversationsTable.$converterparticipants.toSql(participants.value));
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (requiresApproval.present) {
      map['requires_approval'] = Variable<bool>(requiresApproval.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (readMessageIndex.present) {
      map['read_message_index'] = Variable<int>(readMessageIndex.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastReadTime.present) {
      map['last_read_time'] = Variable<DateTime>(lastReadTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('firstMessageIndex: $firstMessageIndex, ')
          ..write('lastMessageIndex: $lastMessageIndex, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageName: $lastMessageName, ')
          ..write('participants: $participants, ')
          ..write('description: $description, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('readMessageIndex: $readMessageIndex, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastReadTime: $lastReadTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderAvatarMeta =
      const VerificationMeta('senderAvatar');
  @override
  late final GeneratedColumn<String> senderAvatar = GeneratedColumn<String>(
      'sender_avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _messageIndexMeta =
      const VerificationMeta('messageIndex');
  @override
  late final GeneratedColumn<int> messageIndex = GeneratedColumn<int>(
      'message_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageStatusMeta =
      const VerificationMeta('messageStatus');
  @override
  late final GeneratedColumn<String> messageStatus = GeneratedColumn<String>(
      'message_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quotedMessageIdMeta =
      const VerificationMeta('quotedMessageId');
  @override
  late final GeneratedColumn<String> quotedMessageId = GeneratedColumn<String>(
      'quoted_message_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _repliedToMessageIdMeta =
      const VerificationMeta('repliedToMessageId');
  @override
  late final GeneratedColumn<String> repliedToMessageId =
      GeneratedColumn<String>('replied_to_message_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _forwardedFromConversationIdMeta =
      const VerificationMeta('forwardedFromConversationId');
  @override
  late final GeneratedColumn<String> forwardedFromConversationId =
      GeneratedColumn<String>(
          'forwarded_from_conversation_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _forwardedFromMessageIdMeta =
      const VerificationMeta('forwardedFromMessageId');
  @override
  late final GeneratedColumn<String> forwardedFromMessageId =
      GeneratedColumn<String>('forwarded_from_message_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEditedMeta =
      const VerificationMeta('isEdited');
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
      'is_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _editedAtMeta =
      const VerificationMeta('editedAt');
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
      'edited_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reactionsMeta =
      const VerificationMeta('reactions');
  @override
  late final GeneratedColumn<String> reactions = GeneratedColumn<String>(
      'reactions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        messageId,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        createdAt,
        updatedAt,
        messageIndex,
        messageType,
        messageStatus,
        quotedMessageId,
        repliedToMessageId,
        forwardedFromConversationId,
        forwardedFromMessageId,
        isEdited,
        editedAt,
        isPinned,
        reactions,
        tags,
        content
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    }
    if (data.containsKey('sender_avatar')) {
      context.handle(
          _senderAvatarMeta,
          senderAvatar.isAcceptableOrUnknown(
              data['sender_avatar']!, _senderAvatarMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('message_index')) {
      context.handle(
          _messageIndexMeta,
          messageIndex.isAcceptableOrUnknown(
              data['message_index']!, _messageIndexMeta));
    } else if (isInserting) {
      context.missing(_messageIndexMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('message_status')) {
      context.handle(
          _messageStatusMeta,
          messageStatus.isAcceptableOrUnknown(
              data['message_status']!, _messageStatusMeta));
    } else if (isInserting) {
      context.missing(_messageStatusMeta);
    }
    if (data.containsKey('quoted_message_id')) {
      context.handle(
          _quotedMessageIdMeta,
          quotedMessageId.isAcceptableOrUnknown(
              data['quoted_message_id']!, _quotedMessageIdMeta));
    }
    if (data.containsKey('replied_to_message_id')) {
      context.handle(
          _repliedToMessageIdMeta,
          repliedToMessageId.isAcceptableOrUnknown(
              data['replied_to_message_id']!, _repliedToMessageIdMeta));
    }
    if (data.containsKey('forwarded_from_conversation_id')) {
      context.handle(
          _forwardedFromConversationIdMeta,
          forwardedFromConversationId.isAcceptableOrUnknown(
              data['forwarded_from_conversation_id']!,
              _forwardedFromConversationIdMeta));
    }
    if (data.containsKey('forwarded_from_message_id')) {
      context.handle(
          _forwardedFromMessageIdMeta,
          forwardedFromMessageId.isAcceptableOrUnknown(
              data['forwarded_from_message_id']!, _forwardedFromMessageIdMeta));
    }
    if (data.containsKey('is_edited')) {
      context.handle(_isEditedMeta,
          isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta));
    }
    if (data.containsKey('edited_at')) {
      context.handle(_editedAtMeta,
          editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('reactions')) {
      context.handle(_reactionsMeta,
          reactions.isAcceptableOrUnknown(data['reactions']!, _reactionsMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name']),
      senderAvatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_avatar']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      messageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_index'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      messageStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_status'])!,
      quotedMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}quoted_message_id']),
      repliedToMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}replied_to_message_id']),
      forwardedFromConversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forwarded_from_conversation_id']),
      forwardedFromMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forwarded_from_message_id']),
      isEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_edited'])!,
      editedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}edited_at']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      reactions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reactions']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messageIndex;
  final String messageType;
  final String messageStatus;
  final String? quotedMessageId;
  final String? repliedToMessageId;
  final String? forwardedFromConversationId;
  final String? forwardedFromMessageId;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isPinned;
  final String? reactions;
  final String? tags;
  final String? content;
  const Message(
      {required this.messageId,
      required this.conversationId,
      required this.senderId,
      this.senderName,
      this.senderAvatar,
      required this.createdAt,
      this.updatedAt,
      required this.messageIndex,
      required this.messageType,
      required this.messageStatus,
      this.quotedMessageId,
      this.repliedToMessageId,
      this.forwardedFromConversationId,
      this.forwardedFromMessageId,
      required this.isEdited,
      this.editedAt,
      required this.isPinned,
      this.reactions,
      this.tags,
      this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || senderName != null) {
      map['sender_name'] = Variable<String>(senderName);
    }
    if (!nullToAbsent || senderAvatar != null) {
      map['sender_avatar'] = Variable<String>(senderAvatar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['message_index'] = Variable<int>(messageIndex);
    map['message_type'] = Variable<String>(messageType);
    map['message_status'] = Variable<String>(messageStatus);
    if (!nullToAbsent || quotedMessageId != null) {
      map['quoted_message_id'] = Variable<String>(quotedMessageId);
    }
    if (!nullToAbsent || repliedToMessageId != null) {
      map['replied_to_message_id'] = Variable<String>(repliedToMessageId);
    }
    if (!nullToAbsent || forwardedFromConversationId != null) {
      map['forwarded_from_conversation_id'] =
          Variable<String>(forwardedFromConversationId);
    }
    if (!nullToAbsent || forwardedFromMessageId != null) {
      map['forwarded_from_message_id'] =
          Variable<String>(forwardedFromMessageId);
    }
    map['is_edited'] = Variable<bool>(isEdited);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || reactions != null) {
      map['reactions'] = Variable<String>(reactions);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      messageId: Value(messageId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      senderName: senderName == null && nullToAbsent
          ? const Value.absent()
          : Value(senderName),
      senderAvatar: senderAvatar == null && nullToAbsent
          ? const Value.absent()
          : Value(senderAvatar),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      messageIndex: Value(messageIndex),
      messageType: Value(messageType),
      messageStatus: Value(messageStatus),
      quotedMessageId: quotedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(quotedMessageId),
      repliedToMessageId: repliedToMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedToMessageId),
      forwardedFromConversationId:
          forwardedFromConversationId == null && nullToAbsent
              ? const Value.absent()
              : Value(forwardedFromConversationId),
      forwardedFromMessageId: forwardedFromMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(forwardedFromMessageId),
      isEdited: Value(isEdited),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      isPinned: Value(isPinned),
      reactions: reactions == null && nullToAbsent
          ? const Value.absent()
          : Value(reactions),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      messageId: serializer.fromJson<String>(json['messageId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String?>(json['senderName']),
      senderAvatar: serializer.fromJson<String?>(json['senderAvatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      messageIndex: serializer.fromJson<int>(json['messageIndex']),
      messageType: serializer.fromJson<String>(json['messageType']),
      messageStatus: serializer.fromJson<String>(json['messageStatus']),
      quotedMessageId: serializer.fromJson<String?>(json['quotedMessageId']),
      repliedToMessageId:
          serializer.fromJson<String?>(json['repliedToMessageId']),
      forwardedFromConversationId:
          serializer.fromJson<String?>(json['forwardedFromConversationId']),
      forwardedFromMessageId:
          serializer.fromJson<String?>(json['forwardedFromMessageId']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      reactions: serializer.fromJson<String?>(json['reactions']),
      tags: serializer.fromJson<String?>(json['tags']),
      content: serializer.fromJson<String?>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String?>(senderName),
      'senderAvatar': serializer.toJson<String?>(senderAvatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'messageIndex': serializer.toJson<int>(messageIndex),
      'messageType': serializer.toJson<String>(messageType),
      'messageStatus': serializer.toJson<String>(messageStatus),
      'quotedMessageId': serializer.toJson<String?>(quotedMessageId),
      'repliedToMessageId': serializer.toJson<String?>(repliedToMessageId),
      'forwardedFromConversationId':
          serializer.toJson<String?>(forwardedFromConversationId),
      'forwardedFromMessageId':
          serializer.toJson<String?>(forwardedFromMessageId),
      'isEdited': serializer.toJson<bool>(isEdited),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'isPinned': serializer.toJson<bool>(isPinned),
      'reactions': serializer.toJson<String?>(reactions),
      'tags': serializer.toJson<String?>(tags),
      'content': serializer.toJson<String?>(content),
    };
  }

  Message copyWith(
          {String? messageId,
          String? conversationId,
          String? senderId,
          Value<String?> senderName = const Value.absent(),
          Value<String?> senderAvatar = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          int? messageIndex,
          String? messageType,
          String? messageStatus,
          Value<String?> quotedMessageId = const Value.absent(),
          Value<String?> repliedToMessageId = const Value.absent(),
          Value<String?> forwardedFromConversationId = const Value.absent(),
          Value<String?> forwardedFromMessageId = const Value.absent(),
          bool? isEdited,
          Value<DateTime?> editedAt = const Value.absent(),
          bool? isPinned,
          Value<String?> reactions = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          Value<String?> content = const Value.absent()}) =>
      Message(
        messageId: messageId ?? this.messageId,
        conversationId: conversationId ?? this.conversationId,
        senderId: senderId ?? this.senderId,
        senderName: senderName.present ? senderName.value : this.senderName,
        senderAvatar:
            senderAvatar.present ? senderAvatar.value : this.senderAvatar,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        messageIndex: messageIndex ?? this.messageIndex,
        messageType: messageType ?? this.messageType,
        messageStatus: messageStatus ?? this.messageStatus,
        quotedMessageId: quotedMessageId.present
            ? quotedMessageId.value
            : this.quotedMessageId,
        repliedToMessageId: repliedToMessageId.present
            ? repliedToMessageId.value
            : this.repliedToMessageId,
        forwardedFromConversationId: forwardedFromConversationId.present
            ? forwardedFromConversationId.value
            : this.forwardedFromConversationId,
        forwardedFromMessageId: forwardedFromMessageId.present
            ? forwardedFromMessageId.value
            : this.forwardedFromMessageId,
        isEdited: isEdited ?? this.isEdited,
        editedAt: editedAt.present ? editedAt.value : this.editedAt,
        isPinned: isPinned ?? this.isPinned,
        reactions: reactions.present ? reactions.value : this.reactions,
        tags: tags.present ? tags.value : this.tags,
        content: content.present ? content.value : this.content,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName:
          data.senderName.present ? data.senderName.value : this.senderName,
      senderAvatar: data.senderAvatar.present
          ? data.senderAvatar.value
          : this.senderAvatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      messageIndex: data.messageIndex.present
          ? data.messageIndex.value
          : this.messageIndex,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      messageStatus: data.messageStatus.present
          ? data.messageStatus.value
          : this.messageStatus,
      quotedMessageId: data.quotedMessageId.present
          ? data.quotedMessageId.value
          : this.quotedMessageId,
      repliedToMessageId: data.repliedToMessageId.present
          ? data.repliedToMessageId.value
          : this.repliedToMessageId,
      forwardedFromConversationId: data.forwardedFromConversationId.present
          ? data.forwardedFromConversationId.value
          : this.forwardedFromConversationId,
      forwardedFromMessageId: data.forwardedFromMessageId.present
          ? data.forwardedFromMessageId.value
          : this.forwardedFromMessageId,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      reactions: data.reactions.present ? data.reactions.value : this.reactions,
      tags: data.tags.present ? data.tags.value : this.tags,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('senderAvatar: $senderAvatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('messageIndex: $messageIndex, ')
          ..write('messageType: $messageType, ')
          ..write('messageStatus: $messageStatus, ')
          ..write('quotedMessageId: $quotedMessageId, ')
          ..write('repliedToMessageId: $repliedToMessageId, ')
          ..write('forwardedFromConversationId: $forwardedFromConversationId, ')
          ..write('forwardedFromMessageId: $forwardedFromMessageId, ')
          ..write('isEdited: $isEdited, ')
          ..write('editedAt: $editedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('reactions: $reactions, ')
          ..write('tags: $tags, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      messageId,
      conversationId,
      senderId,
      senderName,
      senderAvatar,
      createdAt,
      updatedAt,
      messageIndex,
      messageType,
      messageStatus,
      quotedMessageId,
      repliedToMessageId,
      forwardedFromConversationId,
      forwardedFromMessageId,
      isEdited,
      editedAt,
      isPinned,
      reactions,
      tags,
      content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.messageId == this.messageId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.senderAvatar == this.senderAvatar &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.messageIndex == this.messageIndex &&
          other.messageType == this.messageType &&
          other.messageStatus == this.messageStatus &&
          other.quotedMessageId == this.quotedMessageId &&
          other.repliedToMessageId == this.repliedToMessageId &&
          other.forwardedFromConversationId ==
              this.forwardedFromConversationId &&
          other.forwardedFromMessageId == this.forwardedFromMessageId &&
          other.isEdited == this.isEdited &&
          other.editedAt == this.editedAt &&
          other.isPinned == this.isPinned &&
          other.reactions == this.reactions &&
          other.tags == this.tags &&
          other.content == this.content);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> messageId;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String?> senderName;
  final Value<String?> senderAvatar;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> messageIndex;
  final Value<String> messageType;
  final Value<String> messageStatus;
  final Value<String?> quotedMessageId;
  final Value<String?> repliedToMessageId;
  final Value<String?> forwardedFromConversationId;
  final Value<String?> forwardedFromMessageId;
  final Value<bool> isEdited;
  final Value<DateTime?> editedAt;
  final Value<bool> isPinned;
  final Value<String?> reactions;
  final Value<String?> tags;
  final Value<String?> content;
  final Value<int> rowid;
  const MessagesCompanion({
    this.messageId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderAvatar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.messageIndex = const Value.absent(),
    this.messageType = const Value.absent(),
    this.messageStatus = const Value.absent(),
    this.quotedMessageId = const Value.absent(),
    this.repliedToMessageId = const Value.absent(),
    this.forwardedFromConversationId = const Value.absent(),
    this.forwardedFromMessageId = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.reactions = const Value.absent(),
    this.tags = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String messageId,
    required String conversationId,
    required String senderId,
    this.senderName = const Value.absent(),
    this.senderAvatar = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    required int messageIndex,
    required String messageType,
    required String messageStatus,
    this.quotedMessageId = const Value.absent(),
    this.repliedToMessageId = const Value.absent(),
    this.forwardedFromConversationId = const Value.absent(),
    this.forwardedFromMessageId = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.reactions = const Value.absent(),
    this.tags = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : messageId = Value(messageId),
        conversationId = Value(conversationId),
        senderId = Value(senderId),
        createdAt = Value(createdAt),
        messageIndex = Value(messageIndex),
        messageType = Value(messageType),
        messageStatus = Value(messageStatus);
  static Insertable<Message> custom({
    Expression<String>? messageId,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<String>? senderAvatar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? messageIndex,
    Expression<String>? messageType,
    Expression<String>? messageStatus,
    Expression<String>? quotedMessageId,
    Expression<String>? repliedToMessageId,
    Expression<String>? forwardedFromConversationId,
    Expression<String>? forwardedFromMessageId,
    Expression<bool>? isEdited,
    Expression<DateTime>? editedAt,
    Expression<bool>? isPinned,
    Expression<String>? reactions,
    Expression<String>? tags,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (senderAvatar != null) 'sender_avatar': senderAvatar,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (messageIndex != null) 'message_index': messageIndex,
      if (messageType != null) 'message_type': messageType,
      if (messageStatus != null) 'message_status': messageStatus,
      if (quotedMessageId != null) 'quoted_message_id': quotedMessageId,
      if (repliedToMessageId != null)
        'replied_to_message_id': repliedToMessageId,
      if (forwardedFromConversationId != null)
        'forwarded_from_conversation_id': forwardedFromConversationId,
      if (forwardedFromMessageId != null)
        'forwarded_from_message_id': forwardedFromMessageId,
      if (isEdited != null) 'is_edited': isEdited,
      if (editedAt != null) 'edited_at': editedAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (reactions != null) 'reactions': reactions,
      if (tags != null) 'tags': tags,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? messageId,
      Value<String>? conversationId,
      Value<String>? senderId,
      Value<String?>? senderName,
      Value<String?>? senderAvatar,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? messageIndex,
      Value<String>? messageType,
      Value<String>? messageStatus,
      Value<String?>? quotedMessageId,
      Value<String?>? repliedToMessageId,
      Value<String?>? forwardedFromConversationId,
      Value<String?>? forwardedFromMessageId,
      Value<bool>? isEdited,
      Value<DateTime?>? editedAt,
      Value<bool>? isPinned,
      Value<String?>? reactions,
      Value<String?>? tags,
      Value<String?>? content,
      Value<int>? rowid}) {
    return MessagesCompanion(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageIndex: messageIndex ?? this.messageIndex,
      messageType: messageType ?? this.messageType,
      messageStatus: messageStatus ?? this.messageStatus,
      quotedMessageId: quotedMessageId ?? this.quotedMessageId,
      repliedToMessageId: repliedToMessageId ?? this.repliedToMessageId,
      forwardedFromConversationId:
          forwardedFromConversationId ?? this.forwardedFromConversationId,
      forwardedFromMessageId:
          forwardedFromMessageId ?? this.forwardedFromMessageId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isPinned: isPinned ?? this.isPinned,
      reactions: reactions ?? this.reactions,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (senderAvatar.present) {
      map['sender_avatar'] = Variable<String>(senderAvatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (messageIndex.present) {
      map['message_index'] = Variable<int>(messageIndex.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (messageStatus.present) {
      map['message_status'] = Variable<String>(messageStatus.value);
    }
    if (quotedMessageId.present) {
      map['quoted_message_id'] = Variable<String>(quotedMessageId.value);
    }
    if (repliedToMessageId.present) {
      map['replied_to_message_id'] = Variable<String>(repliedToMessageId.value);
    }
    if (forwardedFromConversationId.present) {
      map['forwarded_from_conversation_id'] =
          Variable<String>(forwardedFromConversationId.value);
    }
    if (forwardedFromMessageId.present) {
      map['forwarded_from_message_id'] =
          Variable<String>(forwardedFromMessageId.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (reactions.present) {
      map['reactions'] = Variable<String>(reactions.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('senderAvatar: $senderAvatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('messageIndex: $messageIndex, ')
          ..write('messageType: $messageType, ')
          ..write('messageStatus: $messageStatus, ')
          ..write('quotedMessageId: $quotedMessageId, ')
          ..write('repliedToMessageId: $repliedToMessageId, ')
          ..write('forwardedFromConversationId: $forwardedFromConversationId, ')
          ..write('forwardedFromMessageId: $forwardedFromMessageId, ')
          ..write('isEdited: $isEdited, ')
          ..write('editedAt: $editedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('reactions: $reactions, ')
          ..write('tags: $tags, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendRequestsTable extends FriendRequests
    with TableInfo<$FriendRequestsTable, FriendRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestIdMeta =
      const VerificationMeta('requestId');
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
      'request_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiverIdMeta =
      const VerificationMeta('receiverId');
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
      'receiver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _processedAtMeta =
      const VerificationMeta('processedAt');
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
      'processed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [requestId, senderId, receiverId, status, message, sentAt, processedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend_requests';
  @override
  VerificationContext validateIntegrity(Insertable<FriendRequest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_id')) {
      context.handle(_requestIdMeta,
          requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta));
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
          _receiverIdMeta,
          receiverId.isAcceptableOrUnknown(
              data['receiver_id']!, _receiverIdMeta));
    } else if (isInserting) {
      context.missing(_receiverIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
          _processedAtMeta,
          processedAt.isAcceptableOrUnknown(
              data['processed_at']!, _processedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestId};
  @override
  FriendRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendRequest(
      requestId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}request_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      receiverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
      processedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}processed_at']),
    );
  }

  @override
  $FriendRequestsTable createAlias(String alias) {
    return $FriendRequestsTable(attachedDatabase, alias);
  }
}

class FriendRequest extends DataClass implements Insertable<FriendRequest> {
  final String requestId;
  final String senderId;
  final String receiverId;
  final String status;
  final String? message;
  final DateTime sentAt;
  final DateTime? processedAt;
  const FriendRequest(
      {required this.requestId,
      required this.senderId,
      required this.receiverId,
      required this.status,
      this.message,
      required this.sentAt,
      this.processedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_id'] = Variable<String>(requestId);
    map['sender_id'] = Variable<String>(senderId);
    map['receiver_id'] = Variable<String>(receiverId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['sent_at'] = Variable<DateTime>(sentAt);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    return map;
  }

  FriendRequestsCompanion toCompanion(bool nullToAbsent) {
    return FriendRequestsCompanion(
      requestId: Value(requestId),
      senderId: Value(senderId),
      receiverId: Value(receiverId),
      status: Value(status),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      sentAt: Value(sentAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
    );
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendRequest(
      requestId: serializer.fromJson<String>(json['requestId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receiverId: serializer.fromJson<String>(json['receiverId']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String?>(json['message']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestId': serializer.toJson<String>(requestId),
      'senderId': serializer.toJson<String>(senderId),
      'receiverId': serializer.toJson<String>(receiverId),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String?>(message),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
    };
  }

  FriendRequest copyWith(
          {String? requestId,
          String? senderId,
          String? receiverId,
          String? status,
          Value<String?> message = const Value.absent(),
          DateTime? sentAt,
          Value<DateTime?> processedAt = const Value.absent()}) =>
      FriendRequest(
        requestId: requestId ?? this.requestId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        status: status ?? this.status,
        message: message.present ? message.value : this.message,
        sentAt: sentAt ?? this.sentAt,
        processedAt: processedAt.present ? processedAt.value : this.processedAt,
      );
  FriendRequest copyWithCompanion(FriendRequestsCompanion data) {
    return FriendRequest(
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receiverId:
          data.receiverId.present ? data.receiverId.value : this.receiverId,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      processedAt:
          data.processedAt.present ? data.processedAt.value : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendRequest(')
          ..write('requestId: $requestId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('sentAt: $sentAt, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      requestId, senderId, receiverId, status, message, sentAt, processedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendRequest &&
          other.requestId == this.requestId &&
          other.senderId == this.senderId &&
          other.receiverId == this.receiverId &&
          other.status == this.status &&
          other.message == this.message &&
          other.sentAt == this.sentAt &&
          other.processedAt == this.processedAt);
}

class FriendRequestsCompanion extends UpdateCompanion<FriendRequest> {
  final Value<String> requestId;
  final Value<String> senderId;
  final Value<String> receiverId;
  final Value<String> status;
  final Value<String?> message;
  final Value<DateTime> sentAt;
  final Value<DateTime?> processedAt;
  final Value<int> rowid;
  const FriendRequestsCompanion({
    this.requestId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendRequestsCompanion.insert({
    required String requestId,
    required String senderId,
    required String receiverId,
    required String status,
    this.message = const Value.absent(),
    required DateTime sentAt,
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : requestId = Value(requestId),
        senderId = Value(senderId),
        receiverId = Value(receiverId),
        status = Value(status),
        sentAt = Value(sentAt);
  static Insertable<FriendRequest> custom({
    Expression<String>? requestId,
    Expression<String>? senderId,
    Expression<String>? receiverId,
    Expression<String>? status,
    Expression<String>? message,
    Expression<DateTime>? sentAt,
    Expression<DateTime>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestId != null) 'request_id': requestId,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (sentAt != null) 'sent_at': sentAt,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendRequestsCompanion copyWith(
      {Value<String>? requestId,
      Value<String>? senderId,
      Value<String>? receiverId,
      Value<String>? status,
      Value<String?>? message,
      Value<DateTime>? sentAt,
      Value<DateTime?>? processedAt,
      Value<int>? rowid}) {
    return FriendRequestsCompanion(
      requestId: requestId ?? this.requestId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendRequestsCompanion(')
          ..write('requestId: $requestId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('sentAt: $sentAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickRepliesTable extends QuickReplies
    with TableInfo<$QuickRepliesTable, QuickReply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickRepliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, content, category, orderIndex, isEnabled, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_replies';
  @override
  VerificationContext validateIntegrity(Insertable<QuickReply> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickReply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickReply(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $QuickRepliesTable createAlias(String alias) {
    return $QuickRepliesTable(attachedDatabase, alias);
  }
}

class QuickReply extends DataClass implements Insertable<QuickReply> {
  final int id;
  final String content;
  final String? category;
  final int orderIndex;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const QuickReply(
      {required this.id,
      required this.content,
      this.category,
      required this.orderIndex,
      required this.isEnabled,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  QuickRepliesCompanion toCompanion(bool nullToAbsent) {
    return QuickRepliesCompanion(
      id: Value(id),
      content: Value(content),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      orderIndex: Value(orderIndex),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory QuickReply.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickReply(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<String?>(json['category']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<String?>(category),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  QuickReply copyWith(
          {int? id,
          String? content,
          Value<String?> category = const Value.absent(),
          int? orderIndex,
          bool? isEnabled,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      QuickReply(
        id: id ?? this.id,
        content: content ?? this.content,
        category: category.present ? category.value : this.category,
        orderIndex: orderIndex ?? this.orderIndex,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  QuickReply copyWithCompanion(QuickRepliesCompanion data) {
    return QuickReply(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickReply(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, content, category, orderIndex, isEnabled, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickReply &&
          other.id == this.id &&
          other.content == this.content &&
          other.category == this.category &&
          other.orderIndex == this.orderIndex &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuickRepliesCompanion extends UpdateCompanion<QuickReply> {
  final Value<int> id;
  final Value<String> content;
  final Value<String?> category;
  final Value<int> orderIndex;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const QuickRepliesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuickRepliesCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.category = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
  })  : content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<QuickReply> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<String>? category,
    Expression<int>? orderIndex,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuickRepliesCompanion copyWith(
      {Value<int>? id,
      Value<String>? content,
      Value<String?>? category,
      Value<int>? orderIndex,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return QuickRepliesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickRepliesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CurrentUsersTable currentUsers = $CurrentUsersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $FriendRequestsTable friendRequests = $FriendRequestsTable(this);
  late final $QuickRepliesTable quickReplies = $QuickRepliesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        currentUsers,
        conversations,
        messages,
        friendRequests,
        quickReplies
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String userId,
  required String name,
  Value<String?> avatar,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> pinyin,
  Value<DateTime?> lastActiveTime,
  Value<int?> status,
  Value<int> roleId,
  Value<bool> online,
  Value<bool> isFriend,
  Value<String?> nickname,
  Value<String?> remark,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> userId,
  Value<String> name,
  Value<String?> avatar,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> pinyin,
  Value<DateTime?> lastActiveTime,
  Value<int?> status,
  Value<int> roleId,
  Value<bool> online,
  Value<bool> isFriend,
  Value<String?> nickname,
  Value<String?> remark,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinyin => $composableBuilder(
      column: $table.pinyin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActiveTime => $composableBuilder(
      column: $table.lastActiveTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get online => $composableBuilder(
      column: $table.online, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFriend => $composableBuilder(
      column: $table.isFriend, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinyin => $composableBuilder(
      column: $table.pinyin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActiveTime => $composableBuilder(
      column: $table.lastActiveTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get online => $composableBuilder(
      column: $table.online, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFriend => $composableBuilder(
      column: $table.isFriend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveTime => $composableBuilder(
      column: $table.lastActiveTime, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<bool> get online =>
      $composableBuilder(column: $table.online, builder: (column) => column);

  GeneratedColumn<bool> get isFriend =>
      $composableBuilder(column: $table.isFriend, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> pinyin = const Value.absent(),
            Value<DateTime?> lastActiveTime = const Value.absent(),
            Value<int?> status = const Value.absent(),
            Value<int> roleId = const Value.absent(),
            Value<bool> online = const Value.absent(),
            Value<bool> isFriend = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            userId: userId,
            name: name,
            avatar: avatar,
            phone: phone,
            email: email,
            pinyin: pinyin,
            lastActiveTime: lastActiveTime,
            status: status,
            roleId: roleId,
            online: online,
            isFriend: isFriend,
            nickname: nickname,
            remark: remark,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String name,
            Value<String?> avatar = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> pinyin = const Value.absent(),
            Value<DateTime?> lastActiveTime = const Value.absent(),
            Value<int?> status = const Value.absent(),
            Value<int> roleId = const Value.absent(),
            Value<bool> online = const Value.absent(),
            Value<bool> isFriend = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            userId: userId,
            name: name,
            avatar: avatar,
            phone: phone,
            email: email,
            pinyin: pinyin,
            lastActiveTime: lastActiveTime,
            status: status,
            roleId: roleId,
            online: online,
            isFriend: isFriend,
            nickname: nickname,
            remark: remark,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$CurrentUsersTableCreateCompanionBuilder = CurrentUsersCompanion
    Function({
  required String userId,
  required String name,
  Value<String?> avatar,
  Value<String?> phone,
  Value<String?> email,
  Value<DateTime?> lastLoginTime,
  Value<int?> status,
  Value<bool> hasSetPassword,
  Value<int> roleId,
  Value<int> rowid,
});
typedef $$CurrentUsersTableUpdateCompanionBuilder = CurrentUsersCompanion
    Function({
  Value<String> userId,
  Value<String> name,
  Value<String?> avatar,
  Value<String?> phone,
  Value<String?> email,
  Value<DateTime?> lastLoginTime,
  Value<int?> status,
  Value<bool> hasSetPassword,
  Value<int> roleId,
  Value<int> rowid,
});

class $$CurrentUsersTableFilterComposer
    extends Composer<_$AppDatabase, $CurrentUsersTable> {
  $$CurrentUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginTime => $composableBuilder(
      column: $table.lastLoginTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasSetPassword => $composableBuilder(
      column: $table.hasSetPassword,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnFilters(column));
}

class $$CurrentUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrentUsersTable> {
  $$CurrentUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginTime => $composableBuilder(
      column: $table.lastLoginTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasSetPassword => $composableBuilder(
      column: $table.hasSetPassword,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnOrderings(column));
}

class $$CurrentUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrentUsersTable> {
  $$CurrentUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginTime => $composableBuilder(
      column: $table.lastLoginTime, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get hasSetPassword => $composableBuilder(
      column: $table.hasSetPassword, builder: (column) => column);

  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);
}

class $$CurrentUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CurrentUsersTable,
    CurrentUser,
    $$CurrentUsersTableFilterComposer,
    $$CurrentUsersTableOrderingComposer,
    $$CurrentUsersTableAnnotationComposer,
    $$CurrentUsersTableCreateCompanionBuilder,
    $$CurrentUsersTableUpdateCompanionBuilder,
    (
      CurrentUser,
      BaseReferences<_$AppDatabase, $CurrentUsersTable, CurrentUser>
    ),
    CurrentUser,
    PrefetchHooks Function()> {
  $$CurrentUsersTableTableManager(_$AppDatabase db, $CurrentUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrentUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrentUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrentUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime?> lastLoginTime = const Value.absent(),
            Value<int?> status = const Value.absent(),
            Value<bool> hasSetPassword = const Value.absent(),
            Value<int> roleId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrentUsersCompanion(
            userId: userId,
            name: name,
            avatar: avatar,
            phone: phone,
            email: email,
            lastLoginTime: lastLoginTime,
            status: status,
            hasSetPassword: hasSetPassword,
            roleId: roleId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String name,
            Value<String?> avatar = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime?> lastLoginTime = const Value.absent(),
            Value<int?> status = const Value.absent(),
            Value<bool> hasSetPassword = const Value.absent(),
            Value<int> roleId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrentUsersCompanion.insert(
            userId: userId,
            name: name,
            avatar: avatar,
            phone: phone,
            email: email,
            lastLoginTime: lastLoginTime,
            status: status,
            hasSetPassword: hasSetPassword,
            roleId: roleId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CurrentUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CurrentUsersTable,
    CurrentUser,
    $$CurrentUsersTableFilterComposer,
    $$CurrentUsersTableOrderingComposer,
    $$CurrentUsersTableAnnotationComposer,
    $$CurrentUsersTableCreateCompanionBuilder,
    $$CurrentUsersTableUpdateCompanionBuilder,
    (
      CurrentUser,
      BaseReferences<_$AppDatabase, $CurrentUsersTable, CurrentUser>
    ),
    CurrentUser,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String conversationId,
  required String type,
  Value<String?> name,
  Value<String?> avatar,
  required DateTime createdAt,
  Value<String?> createdBy,
  Value<int> firstMessageIndex,
  Value<int> lastMessageIndex,
  Value<DateTime?> lastMessageTime,
  Value<String?> lastMessagePreview,
  Value<String?> lastMessageName,
  Value<List<Participant>> participants,
  Value<String?> description,
  Value<bool> requiresApproval,
  Value<bool> muted,
  Value<bool> pinned,
  Value<int> readMessageIndex,
  Value<int> unreadCount,
  Value<DateTime?> lastReadTime,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> conversationId,
  Value<String> type,
  Value<String?> name,
  Value<String?> avatar,
  Value<DateTime> createdAt,
  Value<String?> createdBy,
  Value<int> firstMessageIndex,
  Value<int> lastMessageIndex,
  Value<DateTime?> lastMessageTime,
  Value<String?> lastMessagePreview,
  Value<String?> lastMessageName,
  Value<List<Participant>> participants,
  Value<String?> description,
  Value<bool> requiresApproval,
  Value<bool> muted,
  Value<bool> pinned,
  Value<int> readMessageIndex,
  Value<int> unreadCount,
  Value<DateTime?> lastReadTime,
  Value<int> rowid,
});

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firstMessageIndex => $composableBuilder(
      column: $table.firstMessageIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastMessageIndex => $composableBuilder(
      column: $table.lastMessageIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessageName => $composableBuilder(
      column: $table.lastMessageName,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<Participant>, List<Participant>, String>
      get participants => $composableBuilder(
          column: $table.participants,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get muted => $composableBuilder(
      column: $table.muted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readMessageIndex => $composableBuilder(
      column: $table.readMessageIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime, builder: (column) => ColumnFilters(column));
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firstMessageIndex => $composableBuilder(
      column: $table.firstMessageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastMessageIndex => $composableBuilder(
      column: $table.lastMessageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessageName => $composableBuilder(
      column: $table.lastMessageName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participants => $composableBuilder(
      column: $table.participants,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get muted => $composableBuilder(
      column: $table.muted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readMessageIndex => $composableBuilder(
      column: $table.readMessageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime,
      builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get firstMessageIndex => $composableBuilder(
      column: $table.firstMessageIndex, builder: (column) => column);

  GeneratedColumn<int> get lastMessageIndex => $composableBuilder(
      column: $table.lastMessageIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime, builder: (column) => column);

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview, builder: (column) => column);

  GeneratedColumn<String> get lastMessageName => $composableBuilder(
      column: $table.lastMessageName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Participant>, String>
      get participants => $composableBuilder(
          column: $table.participants, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval, builder: (column) => column);

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get readMessageIndex => $composableBuilder(
      column: $table.readMessageIndex, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime, builder: (column) => column);
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> conversationId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<int> firstMessageIndex = const Value.absent(),
            Value<int> lastMessageIndex = const Value.absent(),
            Value<DateTime?> lastMessageTime = const Value.absent(),
            Value<String?> lastMessagePreview = const Value.absent(),
            Value<String?> lastMessageName = const Value.absent(),
            Value<List<Participant>> participants = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> requiresApproval = const Value.absent(),
            Value<bool> muted = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            Value<int> readMessageIndex = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime?> lastReadTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            conversationId: conversationId,
            type: type,
            name: name,
            avatar: avatar,
            createdAt: createdAt,
            createdBy: createdBy,
            firstMessageIndex: firstMessageIndex,
            lastMessageIndex: lastMessageIndex,
            lastMessageTime: lastMessageTime,
            lastMessagePreview: lastMessagePreview,
            lastMessageName: lastMessageName,
            participants: participants,
            description: description,
            requiresApproval: requiresApproval,
            muted: muted,
            pinned: pinned,
            readMessageIndex: readMessageIndex,
            unreadCount: unreadCount,
            lastReadTime: lastReadTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String conversationId,
            required String type,
            Value<String?> name = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            required DateTime createdAt,
            Value<String?> createdBy = const Value.absent(),
            Value<int> firstMessageIndex = const Value.absent(),
            Value<int> lastMessageIndex = const Value.absent(),
            Value<DateTime?> lastMessageTime = const Value.absent(),
            Value<String?> lastMessagePreview = const Value.absent(),
            Value<String?> lastMessageName = const Value.absent(),
            Value<List<Participant>> participants = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> requiresApproval = const Value.absent(),
            Value<bool> muted = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            Value<int> readMessageIndex = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime?> lastReadTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            conversationId: conversationId,
            type: type,
            name: name,
            avatar: avatar,
            createdAt: createdAt,
            createdBy: createdBy,
            firstMessageIndex: firstMessageIndex,
            lastMessageIndex: lastMessageIndex,
            lastMessageTime: lastMessageTime,
            lastMessagePreview: lastMessagePreview,
            lastMessageName: lastMessageName,
            participants: participants,
            description: description,
            requiresApproval: requiresApproval,
            muted: muted,
            pinned: pinned,
            readMessageIndex: readMessageIndex,
            unreadCount: unreadCount,
            lastReadTime: lastReadTime,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String messageId,
  required String conversationId,
  required String senderId,
  Value<String?> senderName,
  Value<String?> senderAvatar,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  required int messageIndex,
  required String messageType,
  required String messageStatus,
  Value<String?> quotedMessageId,
  Value<String?> repliedToMessageId,
  Value<String?> forwardedFromConversationId,
  Value<String?> forwardedFromMessageId,
  Value<bool> isEdited,
  Value<DateTime?> editedAt,
  Value<bool> isPinned,
  Value<String?> reactions,
  Value<String?> tags,
  Value<String?> content,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> messageId,
  Value<String> conversationId,
  Value<String> senderId,
  Value<String?> senderName,
  Value<String?> senderAvatar,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> messageIndex,
  Value<String> messageType,
  Value<String> messageStatus,
  Value<String?> quotedMessageId,
  Value<String?> repliedToMessageId,
  Value<String?> forwardedFromConversationId,
  Value<String?> forwardedFromMessageId,
  Value<bool> isEdited,
  Value<DateTime?> editedAt,
  Value<bool> isPinned,
  Value<String?> reactions,
  Value<String?> tags,
  Value<String?> content,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderAvatar => $composableBuilder(
      column: $table.senderAvatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageStatus => $composableBuilder(
      column: $table.messageStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quotedMessageId => $composableBuilder(
      column: $table.quotedMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repliedToMessageId => $composableBuilder(
      column: $table.repliedToMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get forwardedFromConversationId => $composableBuilder(
      column: $table.forwardedFromConversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get forwardedFromMessageId => $composableBuilder(
      column: $table.forwardedFromMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
      column: $table.editedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactions => $composableBuilder(
      column: $table.reactions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderAvatar => $composableBuilder(
      column: $table.senderAvatar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageStatus => $composableBuilder(
      column: $table.messageStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quotedMessageId => $composableBuilder(
      column: $table.quotedMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repliedToMessageId => $composableBuilder(
      column: $table.repliedToMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get forwardedFromConversationId => $composableBuilder(
      column: $table.forwardedFromConversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get forwardedFromMessageId => $composableBuilder(
      column: $table.forwardedFromMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
      column: $table.editedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactions => $composableBuilder(
      column: $table.reactions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => column);

  GeneratedColumn<String> get senderAvatar => $composableBuilder(
      column: $table.senderAvatar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<String> get messageStatus => $composableBuilder(
      column: $table.messageStatus, builder: (column) => column);

  GeneratedColumn<String> get quotedMessageId => $composableBuilder(
      column: $table.quotedMessageId, builder: (column) => column);

  GeneratedColumn<String> get repliedToMessageId => $composableBuilder(
      column: $table.repliedToMessageId, builder: (column) => column);

  GeneratedColumn<String> get forwardedFromConversationId => $composableBuilder(
      column: $table.forwardedFromConversationId, builder: (column) => column);

  GeneratedColumn<String> get forwardedFromMessageId => $composableBuilder(
      column: $table.forwardedFromMessageId, builder: (column) => column);

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get reactions =>
      $composableBuilder(column: $table.reactions, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> messageId = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String?> senderName = const Value.absent(),
            Value<String?> senderAvatar = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> messageIndex = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<String> messageStatus = const Value.absent(),
            Value<String?> quotedMessageId = const Value.absent(),
            Value<String?> repliedToMessageId = const Value.absent(),
            Value<String?> forwardedFromConversationId = const Value.absent(),
            Value<String?> forwardedFromMessageId = const Value.absent(),
            Value<bool> isEdited = const Value.absent(),
            Value<DateTime?> editedAt = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<String?> reactions = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            messageId: messageId,
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            senderAvatar: senderAvatar,
            createdAt: createdAt,
            updatedAt: updatedAt,
            messageIndex: messageIndex,
            messageType: messageType,
            messageStatus: messageStatus,
            quotedMessageId: quotedMessageId,
            repliedToMessageId: repliedToMessageId,
            forwardedFromConversationId: forwardedFromConversationId,
            forwardedFromMessageId: forwardedFromMessageId,
            isEdited: isEdited,
            editedAt: editedAt,
            isPinned: isPinned,
            reactions: reactions,
            tags: tags,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String messageId,
            required String conversationId,
            required String senderId,
            Value<String?> senderName = const Value.absent(),
            Value<String?> senderAvatar = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            required int messageIndex,
            required String messageType,
            required String messageStatus,
            Value<String?> quotedMessageId = const Value.absent(),
            Value<String?> repliedToMessageId = const Value.absent(),
            Value<String?> forwardedFromConversationId = const Value.absent(),
            Value<String?> forwardedFromMessageId = const Value.absent(),
            Value<bool> isEdited = const Value.absent(),
            Value<DateTime?> editedAt = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<String?> reactions = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            messageId: messageId,
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            senderAvatar: senderAvatar,
            createdAt: createdAt,
            updatedAt: updatedAt,
            messageIndex: messageIndex,
            messageType: messageType,
            messageStatus: messageStatus,
            quotedMessageId: quotedMessageId,
            repliedToMessageId: repliedToMessageId,
            forwardedFromConversationId: forwardedFromConversationId,
            forwardedFromMessageId: forwardedFromMessageId,
            isEdited: isEdited,
            editedAt: editedAt,
            isPinned: isPinned,
            reactions: reactions,
            tags: tags,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$FriendRequestsTableCreateCompanionBuilder = FriendRequestsCompanion
    Function({
  required String requestId,
  required String senderId,
  required String receiverId,
  required String status,
  Value<String?> message,
  required DateTime sentAt,
  Value<DateTime?> processedAt,
  Value<int> rowid,
});
typedef $$FriendRequestsTableUpdateCompanionBuilder = FriendRequestsCompanion
    Function({
  Value<String> requestId,
  Value<String> senderId,
  Value<String> receiverId,
  Value<String> status,
  Value<String?> message,
  Value<DateTime> sentAt,
  Value<DateTime?> processedAt,
  Value<int> rowid,
});

class $$FriendRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendRequestsTable> {
  $$FriendRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
      column: $table.requestId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnFilters(column));
}

class $$FriendRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendRequestsTable> {
  $$FriendRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
      column: $table.requestId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnOrderings(column));
}

class $$FriendRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendRequestsTable> {
  $$FriendRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => column);
}

class $$FriendRequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendRequestsTable,
    FriendRequest,
    $$FriendRequestsTableFilterComposer,
    $$FriendRequestsTableOrderingComposer,
    $$FriendRequestsTableAnnotationComposer,
    $$FriendRequestsTableCreateCompanionBuilder,
    $$FriendRequestsTableUpdateCompanionBuilder,
    (
      FriendRequest,
      BaseReferences<_$AppDatabase, $FriendRequestsTable, FriendRequest>
    ),
    FriendRequest,
    PrefetchHooks Function()> {
  $$FriendRequestsTableTableManager(
      _$AppDatabase db, $FriendRequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> requestId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> receiverId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendRequestsCompanion(
            requestId: requestId,
            senderId: senderId,
            receiverId: receiverId,
            status: status,
            message: message,
            sentAt: sentAt,
            processedAt: processedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String requestId,
            required String senderId,
            required String receiverId,
            required String status,
            Value<String?> message = const Value.absent(),
            required DateTime sentAt,
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendRequestsCompanion.insert(
            requestId: requestId,
            senderId: senderId,
            receiverId: receiverId,
            status: status,
            message: message,
            sentAt: sentAt,
            processedAt: processedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FriendRequestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendRequestsTable,
    FriendRequest,
    $$FriendRequestsTableFilterComposer,
    $$FriendRequestsTableOrderingComposer,
    $$FriendRequestsTableAnnotationComposer,
    $$FriendRequestsTableCreateCompanionBuilder,
    $$FriendRequestsTableUpdateCompanionBuilder,
    (
      FriendRequest,
      BaseReferences<_$AppDatabase, $FriendRequestsTable, FriendRequest>
    ),
    FriendRequest,
    PrefetchHooks Function()>;
typedef $$QuickRepliesTableCreateCompanionBuilder = QuickRepliesCompanion
    Function({
  Value<int> id,
  required String content,
  Value<String?> category,
  Value<int> orderIndex,
  Value<bool> isEnabled,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$QuickRepliesTableUpdateCompanionBuilder = QuickRepliesCompanion
    Function({
  Value<int> id,
  Value<String> content,
  Value<String?> category,
  Value<int> orderIndex,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});

class $$QuickRepliesTableFilterComposer
    extends Composer<_$AppDatabase, $QuickRepliesTable> {
  $$QuickRepliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$QuickRepliesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickRepliesTable> {
  $$QuickRepliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$QuickRepliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickRepliesTable> {
  $$QuickRepliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuickRepliesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuickRepliesTable,
    QuickReply,
    $$QuickRepliesTableFilterComposer,
    $$QuickRepliesTableOrderingComposer,
    $$QuickRepliesTableAnnotationComposer,
    $$QuickRepliesTableCreateCompanionBuilder,
    $$QuickRepliesTableUpdateCompanionBuilder,
    (QuickReply, BaseReferences<_$AppDatabase, $QuickRepliesTable, QuickReply>),
    QuickReply,
    PrefetchHooks Function()> {
  $$QuickRepliesTableTableManager(_$AppDatabase db, $QuickRepliesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickRepliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickRepliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickRepliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              QuickRepliesCompanion(
            id: id,
            content: content,
            category: category,
            orderIndex: orderIndex,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String content,
            Value<String?> category = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              QuickRepliesCompanion.insert(
            id: id,
            content: content,
            category: category,
            orderIndex: orderIndex,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuickRepliesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuickRepliesTable,
    QuickReply,
    $$QuickRepliesTableFilterComposer,
    $$QuickRepliesTableOrderingComposer,
    $$QuickRepliesTableAnnotationComposer,
    $$QuickRepliesTableCreateCompanionBuilder,
    $$QuickRepliesTableUpdateCompanionBuilder,
    (QuickReply, BaseReferences<_$AppDatabase, $QuickRepliesTable, QuickReply>),
    QuickReply,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CurrentUsersTableTableManager get currentUsers =>
      $$CurrentUsersTableTableManager(_db, _db.currentUsers);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$FriendRequestsTableTableManager get friendRequests =>
      $$FriendRequestsTableTableManager(_db, _db.friendRequests);
  $$QuickRepliesTableTableManager get quickReplies =>
      $$QuickRepliesTableTableManager(_db, _db.quickReplies);
}
