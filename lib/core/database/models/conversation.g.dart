// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConversationCollection on Isar {
  IsarCollection<Conversation> get conversations => this.collection();
}

const ConversationSchema = CollectionSchema(
  name: r'Conversation',
  id: 7261696243536555740,
  properties: {
    r'activeParticipantCount': PropertySchema(
      id: 0,
      name: r'activeParticipantCount',
      type: IsarType.long,
    ),
    r'avatar': PropertySchema(
      id: 1,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'avatarText': PropertySchema(
      id: 2,
      name: r'avatarText',
      type: IsarType.string,
    ),
    r'contactUserId': PropertySchema(
      id: 3,
      name: r'contactUserId',
      type: IsarType.string,
    ),
    r'conversationId': PropertySchema(
      id: 4,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 6,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 7,
      name: r'description',
      type: IsarType.string,
    ),
    r'firstMessageIndex': PropertySchema(
      id: 8,
      name: r'firstMessageIndex',
      type: IsarType.long,
    ),
    r'lastMessageIndex': PropertySchema(
      id: 9,
      name: r'lastMessageIndex',
      type: IsarType.long,
    ),
    r'lastMessageName': PropertySchema(
      id: 10,
      name: r'lastMessageName',
      type: IsarType.string,
    ),
    r'lastMessagePreview': PropertySchema(
      id: 11,
      name: r'lastMessagePreview',
      type: IsarType.string,
    ),
    r'lastMessageTime': PropertySchema(
      id: 12,
      name: r'lastMessageTime',
      type: IsarType.dateTime,
    ),
    r'lastReadTime': PropertySchema(
      id: 13,
      name: r'lastReadTime',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'onlineParticipantCount': PropertySchema(
      id: 15,
      name: r'onlineParticipantCount',
      type: IsarType.long,
    ),
    r'participants': PropertySchema(
      id: 16,
      name: r'participants',
      type: IsarType.objectList,
      target: r'Participant',
    ),
    r'type': PropertySchema(
      id: 17,
      name: r'type',
      type: IsarType.string,
      enumMap: _ConversationtypeEnumValueMap,
    )
  },
  estimateSize: _conversationEstimateSize,
  serialize: _conversationSerialize,
  deserialize: _conversationDeserialize,
  deserializeProp: _conversationDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'messages': LinkSchema(
      id: 3447319214171122287,
      name: r'messages',
      target: r'Message',
      single: false,
      linkName: r'conversation',
    )
  },
  embeddedSchemas: {r'Participant': ParticipantSchema},
  getId: _conversationGetId,
  getLinks: _conversationGetLinks,
  attach: _conversationAttach,
  version: '3.1.8',
);

int _conversationEstimateSize(
  Conversation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.avatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.avatarText.length * 3;
  {
    final value = object.contactUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.conversationId.length * 3;
  {
    final value = object.createdBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessageName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessagePreview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.participants.length * 3;
  {
    final offsets = allOffsets[Participant]!;
    for (var i = 0; i < object.participants.length; i++) {
      final value = object.participants[i];
      bytesCount += ParticipantSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _conversationSerialize(
  Conversation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeParticipantCount);
  writer.writeString(offsets[1], object.avatar);
  writer.writeString(offsets[2], object.avatarText);
  writer.writeString(offsets[3], object.contactUserId);
  writer.writeString(offsets[4], object.conversationId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.createdBy);
  writer.writeString(offsets[7], object.description);
  writer.writeLong(offsets[8], object.firstMessageIndex);
  writer.writeLong(offsets[9], object.lastMessageIndex);
  writer.writeString(offsets[10], object.lastMessageName);
  writer.writeString(offsets[11], object.lastMessagePreview);
  writer.writeDateTime(offsets[12], object.lastMessageTime);
  writer.writeDateTime(offsets[13], object.lastReadTime);
  writer.writeString(offsets[14], object.name);
  writer.writeLong(offsets[15], object.onlineParticipantCount);
  writer.writeObjectList<Participant>(
    offsets[16],
    allOffsets,
    ParticipantSchema.serialize,
    object.participants,
  );
  writer.writeString(offsets[17], object.type.name);
}

Conversation _conversationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Conversation();
  object.avatar = reader.readStringOrNull(offsets[1]);
  object.contactUserId = reader.readStringOrNull(offsets[3]);
  object.conversationId = reader.readString(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.createdBy = reader.readStringOrNull(offsets[6]);
  object.description = reader.readStringOrNull(offsets[7]);
  object.firstMessageIndex = reader.readLong(offsets[8]);
  object.id = id;
  object.lastMessageIndex = reader.readLong(offsets[9]);
  object.lastMessageName = reader.readStringOrNull(offsets[10]);
  object.lastMessagePreview = reader.readStringOrNull(offsets[11]);
  object.lastMessageTime = reader.readDateTimeOrNull(offsets[12]);
  object.lastReadTime = reader.readDateTimeOrNull(offsets[13]);
  object.name = reader.readStringOrNull(offsets[14]);
  object.participants = reader.readObjectList<Participant>(
        offsets[16],
        ParticipantSchema.deserialize,
        allOffsets,
        Participant(),
      ) ??
      [];
  object.type =
      _ConversationtypeValueEnumMap[reader.readStringOrNull(offsets[17])] ??
          ConversationType.private;
  return object;
}

P _conversationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readObjectList<Participant>(
            offset,
            ParticipantSchema.deserialize,
            allOffsets,
            Participant(),
          ) ??
          []) as P;
    case 17:
      return (_ConversationtypeValueEnumMap[reader.readStringOrNull(offset)] ??
          ConversationType.private) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ConversationtypeEnumValueMap = {
  r'private': r'private',
  r'group': r'group',
  r'channel': r'channel',
};
const _ConversationtypeValueEnumMap = {
  r'private': ConversationType.private,
  r'group': ConversationType.group,
  r'channel': ConversationType.channel,
};

Id _conversationGetId(Conversation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _conversationGetLinks(Conversation object) {
  return [object.messages];
}

void _conversationAttach(
    IsarCollection<dynamic> col, Id id, Conversation object) {
  object.id = id;
  object.messages.attach(col, col.isar.collection<Message>(), r'messages', id);
}

extension ConversationQueryWhereSort
    on QueryBuilder<Conversation, Conversation, QWhere> {
  QueryBuilder<Conversation, Conversation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConversationQueryWhere
    on QueryBuilder<Conversation, Conversation, QWhereClause> {
  QueryBuilder<Conversation, Conversation, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ConversationQueryFilter
    on QueryBuilder<Conversation, Conversation, QFilterCondition> {
  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      activeParticipantCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      activeParticipantCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      activeParticipantCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      activeParticipantCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeParticipantCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> avatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> avatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> avatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatarText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatarText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarText',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      avatarTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatarText',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactUserId',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactUserId',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      contactUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      firstMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      firstMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      firstMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      firstMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageName',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageName',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageName',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageName',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessagePreview',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessagePreview',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessagePreview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessagePreview',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessagePreview',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessagePreviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessagePreview',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageTime',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageTime',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastMessageTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      lastReadTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      onlineParticipantCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onlineParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      onlineParticipantCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'onlineParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      onlineParticipantCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'onlineParticipantCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      onlineParticipantCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'onlineParticipantCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participants',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeEqualTo(
    ConversationType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      typeGreaterThan(
    ConversationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeLessThan(
    ConversationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeBetween(
    ConversationType lower,
    ConversationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension ConversationQueryObject
    on QueryBuilder<Conversation, Conversation, QFilterCondition> {
  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      participantsElement(FilterQuery<Participant> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'participants');
    });
  }
}

extension ConversationQueryLinks
    on QueryBuilder<Conversation, Conversation, QFilterCondition> {
  QueryBuilder<Conversation, Conversation, QAfterFilterCondition> messages(
      FilterQuery<Message> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'messages');
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', length, true, length, true);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, true, 0, true);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, false, 999999, true);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, true, length, include);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', length, include, 999999, true);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterFilterCondition>
      messagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'messages', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ConversationQuerySortBy
    on QueryBuilder<Conversation, Conversation, QSortBy> {
  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByActiveParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeParticipantCount', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByActiveParticipantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeParticipantCount', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByAvatarText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarText', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByAvatarTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarText', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByContactUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUserId', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByContactUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUserId', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByFirstMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByFirstMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageName', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageName', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessagePreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessagePreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTime', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastMessageTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTime', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByOnlineParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineParticipantCount', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      sortByOnlineParticipantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineParticipantCount', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ConversationQuerySortThenBy
    on QueryBuilder<Conversation, Conversation, QSortThenBy> {
  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByActiveParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeParticipantCount', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByActiveParticipantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeParticipantCount', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByAvatarText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarText', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByAvatarTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarText', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByContactUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUserId', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByContactUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUserId', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByFirstMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByFirstMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageName', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageName', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessagePreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessagePreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTime', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastMessageTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTime', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByOnlineParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineParticipantCount', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy>
      thenByOnlineParticipantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineParticipantCount', Sort.desc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Conversation, Conversation, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ConversationQueryWhereDistinct
    on QueryBuilder<Conversation, Conversation, QDistinct> {
  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByActiveParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeParticipantCount');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByAvatarText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByContactUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByConversationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByCreatedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByFirstMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstMessageIndex');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByLastMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageIndex');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByLastMessageName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByLastMessagePreview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessagePreview',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByLastMessageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageTime');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTime');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct>
      distinctByOnlineParticipantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onlineParticipantCount');
    });
  }

  QueryBuilder<Conversation, Conversation, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension ConversationQueryProperty
    on QueryBuilder<Conversation, Conversation, QQueryProperty> {
  QueryBuilder<Conversation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Conversation, int, QQueryOperations>
      activeParticipantCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeParticipantCount');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<Conversation, String, QQueryOperations> avatarTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarText');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations>
      contactUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactUserId');
    });
  }

  QueryBuilder<Conversation, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<Conversation, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Conversation, int, QQueryOperations>
      firstMessageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstMessageIndex');
    });
  }

  QueryBuilder<Conversation, int, QQueryOperations> lastMessageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageIndex');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations>
      lastMessageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageName');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations>
      lastMessagePreviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessagePreview');
    });
  }

  QueryBuilder<Conversation, DateTime?, QQueryOperations>
      lastMessageTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageTime');
    });
  }

  QueryBuilder<Conversation, DateTime?, QQueryOperations>
      lastReadTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTime');
    });
  }

  QueryBuilder<Conversation, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Conversation, int, QQueryOperations>
      onlineParticipantCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onlineParticipantCount');
    });
  }

  QueryBuilder<Conversation, List<Participant>, QQueryOperations>
      participantsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participants');
    });
  }

  QueryBuilder<Conversation, ConversationType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ParticipantSchema = Schema(
  name: r'Participant',
  id: -4270384824746104850,
  properties: {
    r'addedBy': PropertySchema(
      id: 0,
      name: r'addedBy',
      type: IsarType.string,
    ),
    r'avatar': PropertySchema(
      id: 1,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'deliveredMessageIndex': PropertySchema(
      id: 2,
      name: r'deliveredMessageIndex',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'joinedAt': PropertySchema(
      id: 4,
      name: r'joinedAt',
      type: IsarType.dateTime,
    ),
    r'lastDeliveredMessageIndex': PropertySchema(
      id: 5,
      name: r'lastDeliveredMessageIndex',
      type: IsarType.long,
    ),
    r'lastReadMessageIndex': PropertySchema(
      id: 6,
      name: r'lastReadMessageIndex',
      type: IsarType.long,
    ),
    r'muted': PropertySchema(
      id: 7,
      name: r'muted',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'online': PropertySchema(
      id: 9,
      name: r'online',
      type: IsarType.bool,
    ),
    r'pinned': PropertySchema(
      id: 10,
      name: r'pinned',
      type: IsarType.bool,
    ),
    r'readMessageIndex': PropertySchema(
      id: 11,
      name: r'readMessageIndex',
      type: IsarType.long,
    ),
    r'role': PropertySchema(
      id: 12,
      name: r'role',
      type: IsarType.string,
      enumMap: _ParticipantroleEnumValueMap,
    ),
    r'userId': PropertySchema(
      id: 13,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _participantEstimateSize,
  serialize: _participantSerialize,
  deserialize: _participantDeserialize,
  deserializeProp: _participantDeserializeProp,
);

int _participantEstimateSize(
  Participant object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.addedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.avatar.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.role.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _participantSerialize(
  Participant object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.addedBy);
  writer.writeString(offsets[1], object.avatar);
  writer.writeLong(offsets[2], object.deliveredMessageIndex);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeDateTime(offsets[4], object.joinedAt);
  writer.writeLong(offsets[5], object.lastDeliveredMessageIndex);
  writer.writeLong(offsets[6], object.lastReadMessageIndex);
  writer.writeBool(offsets[7], object.muted);
  writer.writeString(offsets[8], object.name);
  writer.writeBool(offsets[9], object.online);
  writer.writeBool(offsets[10], object.pinned);
  writer.writeLong(offsets[11], object.readMessageIndex);
  writer.writeString(offsets[12], object.role.name);
  writer.writeString(offsets[13], object.userId);
}

Participant _participantDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Participant();
  object.addedBy = reader.readStringOrNull(offsets[0]);
  object.avatar = reader.readString(offsets[1]);
  object.deliveredMessageIndex = reader.readLong(offsets[2]);
  object.isActive = reader.readBool(offsets[3]);
  object.joinedAt = reader.readDateTimeOrNull(offsets[4]);
  object.lastDeliveredMessageIndex = reader.readLong(offsets[5]);
  object.lastReadMessageIndex = reader.readLong(offsets[6]);
  object.muted = reader.readBool(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.online = reader.readBool(offsets[9]);
  object.pinned = reader.readBool(offsets[10]);
  object.readMessageIndex = reader.readLong(offsets[11]);
  object.role =
      _ParticipantroleValueEnumMap[reader.readStringOrNull(offsets[12])] ??
          MemberRole.member;
  object.userId = reader.readString(offsets[13]);
  return object;
}

P _participantDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (_ParticipantroleValueEnumMap[reader.readStringOrNull(offset)] ??
          MemberRole.member) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ParticipantroleEnumValueMap = {
  r'member': r'member',
  r'admin': r'admin',
  r'owner': r'owner',
};
const _ParticipantroleValueEnumMap = {
  r'member': MemberRole.member,
  r'admin': MemberRole.admin,
  r'owner': MemberRole.owner,
};

extension ParticipantQueryFilter
    on QueryBuilder<Participant, Participant, QFilterCondition> {
  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addedBy',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addedBy',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> addedByMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      addedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      avatarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> avatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      deliveredMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      deliveredMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      deliveredMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      deliveredMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deliveredMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      joinedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'joinedAt',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      joinedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'joinedAt',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> joinedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      joinedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      joinedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> joinedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joinedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastDeliveredMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDeliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastDeliveredMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDeliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastDeliveredMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDeliveredMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastDeliveredMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDeliveredMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastReadMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastReadMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastReadMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      lastReadMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> mutedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'muted',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> onlineEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'online',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> pinnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinned',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      readMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      readMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      readMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      readMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleEqualTo(
    MemberRole value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleGreaterThan(
    MemberRole value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleLessThan(
    MemberRole value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleBetween(
    MemberRole lower,
    MemberRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<Participant, Participant, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension ParticipantQueryObject
    on QueryBuilder<Participant, Participant, QFilterCondition> {}
