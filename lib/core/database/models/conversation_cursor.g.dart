// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_cursor.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConversationCursorCollection on Isar {
  IsarCollection<ConversationCursor> get conversationCursors =>
      this.collection();
}

const ConversationCursorSchema = CollectionSchema(
  name: r'ConversationCursor',
  id: 1733471422245688238,
  properties: {
    r'conversationId': PropertySchema(
      id: 0,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'earliestMessageIndex': PropertySchema(
      id: 1,
      name: r'earliestMessageIndex',
      type: IsarType.long,
    ),
    r'hasMoreAfter': PropertySchema(
      id: 2,
      name: r'hasMoreAfter',
      type: IsarType.bool,
    ),
    r'hasMoreBefore': PropertySchema(
      id: 3,
      name: r'hasMoreBefore',
      type: IsarType.bool,
    ),
    r'lastSyncTime': PropertySchema(
      id: 4,
      name: r'lastSyncTime',
      type: IsarType.dateTime,
    ),
    r'latestMessageIndex': PropertySchema(
      id: 5,
      name: r'latestMessageIndex',
      type: IsarType.long,
    ),
    r'messageCount': PropertySchema(
      id: 6,
      name: r'messageCount',
      type: IsarType.long,
    )
  },
  estimateSize: _conversationCursorEstimateSize,
  serialize: _conversationCursorSerialize,
  deserialize: _conversationCursorDeserialize,
  deserializeProp: _conversationCursorDeserializeProp,
  idName: r'id',
  indexes: {
    r'conversationId': IndexSchema(
      id: 2945908346256754300,
      name: r'conversationId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _conversationCursorGetId,
  getLinks: _conversationCursorGetLinks,
  attach: _conversationCursorAttach,
  version: '3.1.0+1',
);

int _conversationCursorEstimateSize(
  ConversationCursor object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversationId.length * 3;
  return bytesCount;
}

void _conversationCursorSerialize(
  ConversationCursor object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.conversationId);
  writer.writeLong(offsets[1], object.earliestMessageIndex);
  writer.writeBool(offsets[2], object.hasMoreAfter);
  writer.writeBool(offsets[3], object.hasMoreBefore);
  writer.writeDateTime(offsets[4], object.lastSyncTime);
  writer.writeLong(offsets[5], object.latestMessageIndex);
  writer.writeLong(offsets[6], object.messageCount);
}

ConversationCursor _conversationCursorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConversationCursor();
  object.conversationId = reader.readString(offsets[0]);
  object.earliestMessageIndex = reader.readLong(offsets[1]);
  object.hasMoreAfter = reader.readBool(offsets[2]);
  object.hasMoreBefore = reader.readBool(offsets[3]);
  object.id = id;
  object.lastSyncTime = reader.readDateTime(offsets[4]);
  object.latestMessageIndex = reader.readLong(offsets[5]);
  object.messageCount = reader.readLong(offsets[6]);
  return object;
}

P _conversationCursorDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _conversationCursorGetId(ConversationCursor object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _conversationCursorGetLinks(
    ConversationCursor object) {
  return [];
}

void _conversationCursorAttach(
    IsarCollection<dynamic> col, Id id, ConversationCursor object) {
  object.id = id;
}

extension ConversationCursorByIndex on IsarCollection<ConversationCursor> {
  Future<ConversationCursor?> getByConversationId(String conversationId) {
    return getByIndex(r'conversationId', [conversationId]);
  }

  ConversationCursor? getByConversationIdSync(String conversationId) {
    return getByIndexSync(r'conversationId', [conversationId]);
  }

  Future<bool> deleteByConversationId(String conversationId) {
    return deleteByIndex(r'conversationId', [conversationId]);
  }

  bool deleteByConversationIdSync(String conversationId) {
    return deleteByIndexSync(r'conversationId', [conversationId]);
  }

  Future<List<ConversationCursor?>> getAllByConversationId(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'conversationId', values);
  }

  List<ConversationCursor?> getAllByConversationIdSync(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'conversationId', values);
  }

  Future<int> deleteAllByConversationId(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'conversationId', values);
  }

  int deleteAllByConversationIdSync(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'conversationId', values);
  }

  Future<Id> putByConversationId(ConversationCursor object) {
    return putByIndex(r'conversationId', object);
  }

  Id putByConversationIdSync(ConversationCursor object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'conversationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConversationId(List<ConversationCursor> objects) {
    return putAllByIndex(r'conversationId', objects);
  }

  List<Id> putAllByConversationIdSync(List<ConversationCursor> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'conversationId', objects, saveLinks: saveLinks);
  }
}

extension ConversationCursorQueryWhereSort
    on QueryBuilder<ConversationCursor, ConversationCursor, QWhere> {
  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConversationCursorQueryWhere
    on QueryBuilder<ConversationCursor, ConversationCursor, QWhereClause> {
  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      conversationIdEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterWhereClause>
      conversationIdNotEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConversationCursorQueryFilter
    on QueryBuilder<ConversationCursor, ConversationCursor, QFilterCondition> {
  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      earliestMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earliestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      earliestMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earliestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      earliestMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earliestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      earliestMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earliestMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      hasMoreAfterEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasMoreAfter',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      hasMoreBeforeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasMoreBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      lastSyncTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      lastSyncTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      lastSyncTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      lastSyncTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      latestMessageIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      latestMessageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      latestMessageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latestMessageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      latestMessageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latestMessageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      messageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      messageCountGreaterThan(
    int value, {
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      messageCountLessThan(
    int value, {
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

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterFilterCondition>
      messageCountBetween(
    int lower,
    int upper, {
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
}

extension ConversationCursorQueryObject
    on QueryBuilder<ConversationCursor, ConversationCursor, QFilterCondition> {}

extension ConversationCursorQueryLinks
    on QueryBuilder<ConversationCursor, ConversationCursor, QFilterCondition> {}

extension ConversationCursorQuerySortBy
    on QueryBuilder<ConversationCursor, ConversationCursor, QSortBy> {
  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByEarliestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByEarliestMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByHasMoreAfter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreAfter', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByHasMoreAfterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreAfter', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByHasMoreBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreBefore', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByHasMoreBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreBefore', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByLatestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByLatestMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      sortByMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.desc);
    });
  }
}

extension ConversationCursorQuerySortThenBy
    on QueryBuilder<ConversationCursor, ConversationCursor, QSortThenBy> {
  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByEarliestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByEarliestMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByHasMoreAfter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreAfter', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByHasMoreAfterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreAfter', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByHasMoreBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreBefore', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByHasMoreBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMoreBefore', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByLatestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestMessageIndex', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByLatestMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestMessageIndex', Sort.desc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.asc);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QAfterSortBy>
      thenByMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageCount', Sort.desc);
    });
  }
}

extension ConversationCursorQueryWhereDistinct
    on QueryBuilder<ConversationCursor, ConversationCursor, QDistinct> {
  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByEarliestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earliestMessageIndex');
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByHasMoreAfter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMoreAfter');
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByHasMoreBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMoreBefore');
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncTime');
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByLatestMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latestMessageIndex');
    });
  }

  QueryBuilder<ConversationCursor, ConversationCursor, QDistinct>
      distinctByMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageCount');
    });
  }
}

extension ConversationCursorQueryProperty
    on QueryBuilder<ConversationCursor, ConversationCursor, QQueryProperty> {
  QueryBuilder<ConversationCursor, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConversationCursor, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<ConversationCursor, int, QQueryOperations>
      earliestMessageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earliestMessageIndex');
    });
  }

  QueryBuilder<ConversationCursor, bool, QQueryOperations>
      hasMoreAfterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMoreAfter');
    });
  }

  QueryBuilder<ConversationCursor, bool, QQueryOperations>
      hasMoreBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMoreBefore');
    });
  }

  QueryBuilder<ConversationCursor, DateTime, QQueryOperations>
      lastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncTime');
    });
  }

  QueryBuilder<ConversationCursor, int, QQueryOperations>
      latestMessageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latestMessageIndex');
    });
  }

  QueryBuilder<ConversationCursor, int, QQueryOperations>
      messageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageCount');
    });
  }
}
