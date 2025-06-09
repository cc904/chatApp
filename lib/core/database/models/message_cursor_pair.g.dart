// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_cursor_pair.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageCursorPairModelCollection on Isar {
  IsarCollection<MessageCursorPairModel> get messageCursorPairModels =>
      this.collection();
}

const MessageCursorPairModelSchema = CollectionSchema(
  name: r'MessageCursorPairModel',
  id: -7248812690867958347,
  properties: {
    r'conversationId': PropertySchema(
      id: 0,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'endCursorMessageId': PropertySchema(
      id: 2,
      name: r'endCursorMessageId',
      type: IsarType.string,
    ),
    r'endCursorPosition': PropertySchema(
      id: 3,
      name: r'endCursorPosition',
      type: IsarType.string,
    ),
    r'endCursorTimestamp': PropertySchema(
      id: 4,
      name: r'endCursorTimestamp',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'messageCount': PropertySchema(
      id: 6,
      name: r'messageCount',
      type: IsarType.long,
    ),
    r'metadataJson': PropertySchema(
      id: 7,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'pairId': PropertySchema(
      id: 8,
      name: r'pairId',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 9,
      name: r'priority',
      type: IsarType.long,
    ),
    r'startCursorMessageId': PropertySchema(
      id: 10,
      name: r'startCursorMessageId',
      type: IsarType.string,
    ),
    r'startCursorPosition': PropertySchema(
      id: 11,
      name: r'startCursorPosition',
      type: IsarType.string,
    ),
    r'startCursorTimestamp': PropertySchema(
      id: 12,
      name: r'startCursorTimestamp',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _messageCursorPairModelEstimateSize,
  serialize: _messageCursorPairModelSerialize,
  deserialize: _messageCursorPairModelDeserialize,
  deserializeProp: _messageCursorPairModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'pairId': IndexSchema(
      id: 2719656591867140602,
      name: r'pairId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'pairId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'conversationId_createdAt': IndexSchema(
      id: -6415830084913696883,
      name: r'conversationId_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'priority': IndexSchema(
      id: -6477851841645083544,
      name: r'priority',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'priority',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'conversation': LinkSchema(
      id: -7449329954940463771,
      name: r'conversation',
      target: r'Conversation',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _messageCursorPairModelGetId,
  getLinks: _messageCursorPairModelGetLinks,
  attach: _messageCursorPairModelAttach,
  version: '3.1.0+1',
);

int _messageCursorPairModelEstimateSize(
  MessageCursorPairModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversationId.length * 3;
  {
    final value = object.endCursorMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.endCursorPosition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.pairId.length * 3;
  {
    final value = object.startCursorMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.startCursorPosition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _messageCursorPairModelSerialize(
  MessageCursorPairModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.conversationId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.endCursorMessageId);
  writer.writeString(offsets[3], object.endCursorPosition);
  writer.writeDateTime(offsets[4], object.endCursorTimestamp);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeLong(offsets[6], object.messageCount);
  writer.writeString(offsets[7], object.metadataJson);
  writer.writeString(offsets[8], object.pairId);
  writer.writeLong(offsets[9], object.priority);
  writer.writeString(offsets[10], object.startCursorMessageId);
  writer.writeString(offsets[11], object.startCursorPosition);
  writer.writeDateTime(offsets[12], object.startCursorTimestamp);
  writer.writeString(offsets[13], object.type);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

MessageCursorPairModel _messageCursorPairModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageCursorPairModel();
  object.conversationId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.endCursorMessageId = reader.readStringOrNull(offsets[2]);
  object.endCursorPosition = reader.readStringOrNull(offsets[3]);
  object.endCursorTimestamp = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[5]);
  object.messageCount = reader.readLongOrNull(offsets[6]);
  object.metadataJson = reader.readStringOrNull(offsets[7]);
  object.pairId = reader.readString(offsets[8]);
  object.priority = reader.readLong(offsets[9]);
  object.startCursorMessageId = reader.readStringOrNull(offsets[10]);
  object.startCursorPosition = reader.readStringOrNull(offsets[11]);
  object.startCursorTimestamp = reader.readDateTimeOrNull(offsets[12]);
  object.type = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  return object;
}

P _messageCursorPairModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageCursorPairModelGetId(MessageCursorPairModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _messageCursorPairModelGetLinks(
    MessageCursorPairModel object) {
  return [object.conversation];
}

void _messageCursorPairModelAttach(
    IsarCollection<dynamic> col, Id id, MessageCursorPairModel object) {
  object.id = id;
  object.conversation
      .attach(col, col.isar.collection<Conversation>(), r'conversation', id);
}

extension MessageCursorPairModelByIndex
    on IsarCollection<MessageCursorPairModel> {
  Future<MessageCursorPairModel?> getByPairId(String pairId) {
    return getByIndex(r'pairId', [pairId]);
  }

  MessageCursorPairModel? getByPairIdSync(String pairId) {
    return getByIndexSync(r'pairId', [pairId]);
  }

  Future<bool> deleteByPairId(String pairId) {
    return deleteByIndex(r'pairId', [pairId]);
  }

  bool deleteByPairIdSync(String pairId) {
    return deleteByIndexSync(r'pairId', [pairId]);
  }

  Future<List<MessageCursorPairModel?>> getAllByPairId(
      List<String> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'pairId', values);
  }

  List<MessageCursorPairModel?> getAllByPairIdSync(List<String> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'pairId', values);
  }

  Future<int> deleteAllByPairId(List<String> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'pairId', values);
  }

  int deleteAllByPairIdSync(List<String> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'pairId', values);
  }

  Future<Id> putByPairId(MessageCursorPairModel object) {
    return putByIndex(r'pairId', object);
  }

  Id putByPairIdSync(MessageCursorPairModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'pairId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPairId(List<MessageCursorPairModel> objects) {
    return putAllByIndex(r'pairId', objects);
  }

  List<Id> putAllByPairIdSync(List<MessageCursorPairModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'pairId', objects, saveLinks: saveLinks);
  }
}

extension MessageCursorPairModelQueryWhereSort
    on QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QWhere> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterWhere>
      anyPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'priority'),
      );
    });
  }
}

extension MessageCursorPairModelQueryWhere on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QWhereClause> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> pairIdEqualTo(String pairId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId',
        value: [pairId],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> pairIdNotEqualTo(String pairId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterWhereClause>
      conversationIdEqualToAnyCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_createdAt',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterWhereClause>
      conversationIdNotEqualToAnyCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterWhereClause>
      conversationIdCreatedAtEqualTo(
          String conversationId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_createdAt',
        value: [conversationId, createdAt],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterWhereClause>
      conversationIdEqualToCreatedAtNotEqualTo(
          String conversationId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              upper: [conversationId, createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId, createdAt],
              includeLower: false,
              upper: [conversationId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId, createdAt],
              includeLower: false,
              upper: [conversationId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              upper: [conversationId, createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> conversationIdEqualToCreatedAtGreaterThan(
    String conversationId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId, createdAt],
        includeLower: include,
        upper: [conversationId],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> conversationIdEqualToCreatedAtLessThan(
    String conversationId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId],
        upper: [conversationId, createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> conversationIdEqualToCreatedAtBetween(
    String conversationId,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId, lowerCreatedAt],
        includeLower: includeLower,
        upper: [conversationId, upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> typeEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> typeNotEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> priorityEqualTo(int priority) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'priority',
        value: [priority],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> priorityNotEqualTo(int priority) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'priority',
              lower: [],
              upper: [priority],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'priority',
              lower: [priority],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'priority',
              lower: [priority],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'priority',
              lower: [],
              upper: [priority],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> priorityGreaterThan(
    int priority, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'priority',
        lower: [priority],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> priorityLessThan(
    int priority, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'priority',
        lower: [],
        upper: [priority],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterWhereClause> priorityBetween(
    int lowerPriority,
    int upperPriority, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'priority',
        lower: [lowerPriority],
        includeLower: includeLower,
        upper: [upperPriority],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MessageCursorPairModelQueryFilter on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QFilterCondition> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdEqualTo(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdGreaterThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdLessThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdBetween(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdStartsWith(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdEndsWith(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endCursorMessageId',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endCursorMessageId',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endCursorMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      endCursorMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      endCursorMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endCursorMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endCursorMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endCursorMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endCursorPosition',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endCursorPosition',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endCursorPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      endCursorPositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      endCursorPositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endCursorPosition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endCursorPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorPositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endCursorPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endCursorTimestamp',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endCursorTimestamp',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> endCursorTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endCursorTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'messageCount',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'messageCount',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> messageCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      pairIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      pairIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pairId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> pairIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startCursorMessageId',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startCursorMessageId',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startCursorMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      startCursorMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startCursorMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      startCursorMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startCursorMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startCursorMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startCursorMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startCursorPosition',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startCursorPosition',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startCursorPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      startCursorPositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startCursorPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      startCursorPositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startCursorPosition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startCursorPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorPositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startCursorPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startCursorTimestamp',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startCursorTimestamp',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startCursorTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> startCursorTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startCursorTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeEqualTo(
    String value, {
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeLessThan(
    String value, {
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MessageCursorPairModelQueryObject on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QFilterCondition> {}

extension MessageCursorPairModelQueryLinks on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QFilterCondition> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversation(FilterQuery<Conversation> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'conversation');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel,
      QAfterFilterCondition> conversationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'conversation', 0, true, 0, true);
    });
  }
}

extension MessageCursorPairModelQuerySortBy
    on QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QSortBy> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorPosition', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorPosition', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorTimestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByEndCursorTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorTimestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorPosition', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorPosition', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorTimestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByStartCursorTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorTimestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MessageCursorPairModelQuerySortThenBy on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QSortThenBy> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorPosition', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorPosition', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorTimestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByEndCursorTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endCursorTimestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorPosition', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorPosition', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorTimestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByStartCursorTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startCursorTimestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MessageCursorPairModelQueryWhereDistinct
    on QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct> {
  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByEndCursorMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endCursorMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByEndCursorPosition({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endCursorPosition',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByEndCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endCursorTimestamp');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageCount');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByPairId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByStartCursorMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startCursorMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByStartCursorPosition({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startCursorPosition',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByStartCursorTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startCursorTimestamp');
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageCursorPairModel, MessageCursorPairModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MessageCursorPairModelQueryProperty on QueryBuilder<
    MessageCursorPairModel, MessageCursorPairModel, QQueryProperty> {
  QueryBuilder<MessageCursorPairModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageCursorPairModel, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<MessageCursorPairModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MessageCursorPairModel, String?, QQueryOperations>
      endCursorMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endCursorMessageId');
    });
  }

  QueryBuilder<MessageCursorPairModel, String?, QQueryOperations>
      endCursorPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endCursorPosition');
    });
  }

  QueryBuilder<MessageCursorPairModel, DateTime?, QQueryOperations>
      endCursorTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endCursorTimestamp');
    });
  }

  QueryBuilder<MessageCursorPairModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MessageCursorPairModel, int?, QQueryOperations>
      messageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageCount');
    });
  }

  QueryBuilder<MessageCursorPairModel, String?, QQueryOperations>
      metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<MessageCursorPairModel, String, QQueryOperations>
      pairIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairId');
    });
  }

  QueryBuilder<MessageCursorPairModel, int, QQueryOperations>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<MessageCursorPairModel, String?, QQueryOperations>
      startCursorMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startCursorMessageId');
    });
  }

  QueryBuilder<MessageCursorPairModel, String?, QQueryOperations>
      startCursorPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startCursorPosition');
    });
  }

  QueryBuilder<MessageCursorPairModel, DateTime?, QQueryOperations>
      startCursorTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startCursorTimestamp');
    });
  }

  QueryBuilder<MessageCursorPairModel, String, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<MessageCursorPairModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
