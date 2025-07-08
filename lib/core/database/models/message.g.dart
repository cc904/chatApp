// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageCollection on Isar {
  IsarCollection<Message> get messages => this.collection();
}

const MessageSchema = CollectionSchema(
  name: r'Message',
  id: 2463283977299753079,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.string,
    ),
    r'actorUserId': PropertySchema(
      id: 1,
      name: r'actorUserId',
      type: IsarType.string,
    ),
    r'affectedUserIds': PropertySchema(
      id: 2,
      name: r'affectedUserIds',
      type: IsarType.string,
    ),
    r'caption': PropertySchema(
      id: 3,
      name: r'caption',
      type: IsarType.string,
    ),
    r'contactAvatar': PropertySchema(
      id: 4,
      name: r'contactAvatar',
      type: IsarType.string,
    ),
    r'contactEmail': PropertySchema(
      id: 5,
      name: r'contactEmail',
      type: IsarType.string,
    ),
    r'contactId': PropertySchema(
      id: 6,
      name: r'contactId',
      type: IsarType.string,
    ),
    r'contactName': PropertySchema(
      id: 7,
      name: r'contactName',
      type: IsarType.string,
    ),
    r'contactPhone': PropertySchema(
      id: 8,
      name: r'contactPhone',
      type: IsarType.string,
    ),
    r'conversationId': PropertySchema(
      id: 9,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 10,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'duration': PropertySchema(
      id: 11,
      name: r'duration',
      type: IsarType.long,
    ),
    r'editedAt': PropertySchema(
      id: 12,
      name: r'editedAt',
      type: IsarType.dateTime,
    ),
    r'eventTimestamp': PropertySchema(
      id: 13,
      name: r'eventTimestamp',
      type: IsarType.dateTime,
    ),
    r'eventType': PropertySchema(
      id: 14,
      name: r'eventType',
      type: IsarType.string,
    ),
    r'expiresAt': PropertySchema(
      id: 15,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'faviconUrl': PropertySchema(
      id: 16,
      name: r'faviconUrl',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 17,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(
      id: 18,
      name: r'fileSize',
      type: IsarType.double,
    ),
    r'forwardedFromConversationId': PropertySchema(
      id: 19,
      name: r'forwardedFromConversationId',
      type: IsarType.string,
    ),
    r'forwardedFromMessageId': PropertySchema(
      id: 20,
      name: r'forwardedFromMessageId',
      type: IsarType.string,
    ),
    r'hashtags': PropertySchema(
      id: 21,
      name: r'hashtags',
      type: IsarType.string,
    ),
    r'height': PropertySchema(
      id: 22,
      name: r'height',
      type: IsarType.long,
    ),
    r'isAnonymous': PropertySchema(
      id: 23,
      name: r'isAnonymous',
      type: IsarType.bool,
    ),
    r'isEdited': PropertySchema(
      id: 24,
      name: r'isEdited',
      type: IsarType.bool,
    ),
    r'isMultipleChoice': PropertySchema(
      id: 25,
      name: r'isMultipleChoice',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 26,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'linkDescription': PropertySchema(
      id: 27,
      name: r'linkDescription',
      type: IsarType.string,
    ),
    r'linkImageUrl': PropertySchema(
      id: 28,
      name: r'linkImageUrl',
      type: IsarType.string,
    ),
    r'linkTitle': PropertySchema(
      id: 29,
      name: r'linkTitle',
      type: IsarType.string,
    ),
    r'linkUrl': PropertySchema(
      id: 30,
      name: r'linkUrl',
      type: IsarType.string,
    ),
    r'localPath': PropertySchema(
      id: 31,
      name: r'localPath',
      type: IsarType.string,
    ),
    r'mediaUrl': PropertySchema(
      id: 32,
      name: r'mediaUrl',
      type: IsarType.string,
    ),
    r'membershipActor': PropertySchema(
      id: 33,
      name: r'membershipActor',
      type: IsarType.string,
    ),
    r'membershipAffectedMembers': PropertySchema(
      id: 34,
      name: r'membershipAffectedMembers',
      type: IsarType.string,
    ),
    r'membershipEventType': PropertySchema(
      id: 35,
      name: r'membershipEventType',
      type: IsarType.string,
    ),
    r'membershipInviteLink': PropertySchema(
      id: 36,
      name: r'membershipInviteLink',
      type: IsarType.string,
    ),
    r'membershipMetadata': PropertySchema(
      id: 37,
      name: r'membershipMetadata',
      type: IsarType.string,
    ),
    r'membershipNewRole': PropertySchema(
      id: 38,
      name: r'membershipNewRole',
      type: IsarType.long,
    ),
    r'membershipPreviousRole': PropertySchema(
      id: 39,
      name: r'membershipPreviousRole',
      type: IsarType.long,
    ),
    r'membershipRemovalReason': PropertySchema(
      id: 40,
      name: r'membershipRemovalReason',
      type: IsarType.string,
    ),
    r'mentions': PropertySchema(
      id: 41,
      name: r'mentions',
      type: IsarType.string,
    ),
    r'messageId': PropertySchema(
      id: 42,
      name: r'messageId',
      type: IsarType.string,
    ),
    r'messageIndex': PropertySchema(
      id: 43,
      name: r'messageIndex',
      type: IsarType.long,
    ),
    r'metadata': PropertySchema(
      id: 44,
      name: r'metadata',
      type: IsarType.string,
    ),
    r'mimeType': PropertySchema(
      id: 45,
      name: r'mimeType',
      type: IsarType.string,
    ),
    r'params': PropertySchema(
      id: 46,
      name: r'params',
      type: IsarType.string,
    ),
    r'pollId': PropertySchema(
      id: 47,
      name: r'pollId',
      type: IsarType.string,
    ),
    r'question': PropertySchema(
      id: 48,
      name: r'question',
      type: IsarType.string,
    ),
    r'quotedMessageId': PropertySchema(
      id: 49,
      name: r'quotedMessageId',
      type: IsarType.string,
    ),
    r'reactions': PropertySchema(
      id: 50,
      name: r'reactions',
      type: IsarType.string,
    ),
    r'repliedToMessageId': PropertySchema(
      id: 51,
      name: r'repliedToMessageId',
      type: IsarType.string,
    ),
    r'senderAvatar': PropertySchema(
      id: 52,
      name: r'senderAvatar',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 53,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'senderName': PropertySchema(
      id: 54,
      name: r'senderName',
      type: IsarType.string,
    ),
    r'siteName': PropertySchema(
      id: 55,
      name: r'siteName',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 56,
      name: r'status',
      type: IsarType.string,
      enumMap: _MessagestatusEnumValueMap,
    ),
    r'stickerId': PropertySchema(
      id: 57,
      name: r'stickerId',
      type: IsarType.string,
    ),
    r'stickerPackId': PropertySchema(
      id: 58,
      name: r'stickerPackId',
      type: IsarType.string,
    ),
    r'stickerPackName': PropertySchema(
      id: 59,
      name: r'stickerPackName',
      type: IsarType.string,
    ),
    r'stickerUrl': PropertySchema(
      id: 60,
      name: r'stickerUrl',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 61,
      name: r'tags',
      type: IsarType.string,
    ),
    r'text': PropertySchema(
      id: 62,
      name: r'text',
      type: IsarType.string,
    ),
    r'textForSearch': PropertySchema(
      id: 63,
      name: r'textForSearch',
      type: IsarType.string,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 64,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 65,
      name: r'type',
      type: IsarType.string,
      enumMap: _MessagetypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 66,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'width': PropertySchema(
      id: 67,
      name: r'width',
      type: IsarType.long,
    )
  },
  estimateSize: _messageEstimateSize,
  serialize: _messageSerialize,
  deserialize: _messageDeserialize,
  deserializeProp: _messageDeserializeProp,
  idName: r'id',
  indexes: {
    r'messageId': IndexSchema(
      id: -635287409172016016,
      name: r'messageId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'messageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'conversationId_messageIndex_createdAt': IndexSchema(
      id: -2788030659683020195,
      name: r'conversationId_messageIndex_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'messageIndex',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'textForSearch': IndexSchema(
      id: -6245724253215085175,
      name: r'textForSearch',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'textForSearch',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'conversation': LinkSchema(
      id: -7483555114440002086,
      name: r'conversation',
      target: r'Conversation',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _messageGetId,
  getLinks: _messageGetLinks,
  attach: _messageAttach,
  version: '3.1.8',
);

int _messageEstimateSize(
  Message object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.action;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.actorUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.affectedUserIds;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caption;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactAvatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.conversationId.length * 3;
  {
    final value = object.eventType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.faviconUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.forwardedFromConversationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.forwardedFromMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hashtags;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkDescription;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mediaUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipActor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipAffectedMembers;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipEventType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipInviteLink;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipMetadata;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.membershipRemovalReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mentions;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.messageId.length * 3;
  {
    final value = object.metadata;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mimeType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.params;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pollId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.question;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.quotedMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reactions;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.repliedToMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderAvatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.senderId.length * 3;
  {
    final value = object.senderName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.siteName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.stickerId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stickerPackId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stickerPackName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stickerUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tags;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.text;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.textForSearch;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _messageSerialize(
  Message object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeString(offsets[1], object.actorUserId);
  writer.writeString(offsets[2], object.affectedUserIds);
  writer.writeString(offsets[3], object.caption);
  writer.writeString(offsets[4], object.contactAvatar);
  writer.writeString(offsets[5], object.contactEmail);
  writer.writeString(offsets[6], object.contactId);
  writer.writeString(offsets[7], object.contactName);
  writer.writeString(offsets[8], object.contactPhone);
  writer.writeString(offsets[9], object.conversationId);
  writer.writeDateTime(offsets[10], object.createdAt);
  writer.writeLong(offsets[11], object.duration);
  writer.writeDateTime(offsets[12], object.editedAt);
  writer.writeDateTime(offsets[13], object.eventTimestamp);
  writer.writeString(offsets[14], object.eventType);
  writer.writeDateTime(offsets[15], object.expiresAt);
  writer.writeString(offsets[16], object.faviconUrl);
  writer.writeString(offsets[17], object.fileName);
  writer.writeDouble(offsets[18], object.fileSize);
  writer.writeString(offsets[19], object.forwardedFromConversationId);
  writer.writeString(offsets[20], object.forwardedFromMessageId);
  writer.writeString(offsets[21], object.hashtags);
  writer.writeLong(offsets[22], object.height);
  writer.writeBool(offsets[23], object.isAnonymous);
  writer.writeBool(offsets[24], object.isEdited);
  writer.writeBool(offsets[25], object.isMultipleChoice);
  writer.writeBool(offsets[26], object.isPinned);
  writer.writeString(offsets[27], object.linkDescription);
  writer.writeString(offsets[28], object.linkImageUrl);
  writer.writeString(offsets[29], object.linkTitle);
  writer.writeString(offsets[30], object.linkUrl);
  writer.writeString(offsets[31], object.localPath);
  writer.writeString(offsets[32], object.mediaUrl);
  writer.writeString(offsets[33], object.membershipActor);
  writer.writeString(offsets[34], object.membershipAffectedMembers);
  writer.writeString(offsets[35], object.membershipEventType);
  writer.writeString(offsets[36], object.membershipInviteLink);
  writer.writeString(offsets[37], object.membershipMetadata);
  writer.writeLong(offsets[38], object.membershipNewRole);
  writer.writeLong(offsets[39], object.membershipPreviousRole);
  writer.writeString(offsets[40], object.membershipRemovalReason);
  writer.writeString(offsets[41], object.mentions);
  writer.writeString(offsets[42], object.messageId);
  writer.writeLong(offsets[43], object.messageIndex);
  writer.writeString(offsets[44], object.metadata);
  writer.writeString(offsets[45], object.mimeType);
  writer.writeString(offsets[46], object.params);
  writer.writeString(offsets[47], object.pollId);
  writer.writeString(offsets[48], object.question);
  writer.writeString(offsets[49], object.quotedMessageId);
  writer.writeString(offsets[50], object.reactions);
  writer.writeString(offsets[51], object.repliedToMessageId);
  writer.writeString(offsets[52], object.senderAvatar);
  writer.writeString(offsets[53], object.senderId);
  writer.writeString(offsets[54], object.senderName);
  writer.writeString(offsets[55], object.siteName);
  writer.writeString(offsets[56], object.status.name);
  writer.writeString(offsets[57], object.stickerId);
  writer.writeString(offsets[58], object.stickerPackId);
  writer.writeString(offsets[59], object.stickerPackName);
  writer.writeString(offsets[60], object.stickerUrl);
  writer.writeString(offsets[61], object.tags);
  writer.writeString(offsets[62], object.text);
  writer.writeString(offsets[63], object.textForSearch);
  writer.writeString(offsets[64], object.thumbnailUrl);
  writer.writeString(offsets[65], object.type.name);
  writer.writeDateTime(offsets[66], object.updatedAt);
  writer.writeLong(offsets[67], object.width);
}

Message _messageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Message();
  object.action = reader.readStringOrNull(offsets[0]);
  object.actorUserId = reader.readStringOrNull(offsets[1]);
  object.affectedUserIds = reader.readStringOrNull(offsets[2]);
  object.caption = reader.readStringOrNull(offsets[3]);
  object.contactAvatar = reader.readStringOrNull(offsets[4]);
  object.contactEmail = reader.readStringOrNull(offsets[5]);
  object.contactId = reader.readStringOrNull(offsets[6]);
  object.contactName = reader.readStringOrNull(offsets[7]);
  object.contactPhone = reader.readStringOrNull(offsets[8]);
  object.conversationId = reader.readString(offsets[9]);
  object.createdAt = reader.readDateTime(offsets[10]);
  object.duration = reader.readLongOrNull(offsets[11]);
  object.editedAt = reader.readDateTimeOrNull(offsets[12]);
  object.eventTimestamp = reader.readDateTimeOrNull(offsets[13]);
  object.eventType = reader.readStringOrNull(offsets[14]);
  object.expiresAt = reader.readDateTimeOrNull(offsets[15]);
  object.faviconUrl = reader.readStringOrNull(offsets[16]);
  object.fileName = reader.readStringOrNull(offsets[17]);
  object.fileSize = reader.readDoubleOrNull(offsets[18]);
  object.forwardedFromConversationId = reader.readStringOrNull(offsets[19]);
  object.forwardedFromMessageId = reader.readStringOrNull(offsets[20]);
  object.hashtags = reader.readStringOrNull(offsets[21]);
  object.height = reader.readLongOrNull(offsets[22]);
  object.id = id;
  object.isAnonymous = reader.readBoolOrNull(offsets[23]);
  object.isEdited = reader.readBool(offsets[24]);
  object.isMultipleChoice = reader.readBoolOrNull(offsets[25]);
  object.isPinned = reader.readBool(offsets[26]);
  object.linkDescription = reader.readStringOrNull(offsets[27]);
  object.linkImageUrl = reader.readStringOrNull(offsets[28]);
  object.linkTitle = reader.readStringOrNull(offsets[29]);
  object.linkUrl = reader.readStringOrNull(offsets[30]);
  object.localPath = reader.readStringOrNull(offsets[31]);
  object.mediaUrl = reader.readStringOrNull(offsets[32]);
  object.membershipActor = reader.readStringOrNull(offsets[33]);
  object.membershipAffectedMembers = reader.readStringOrNull(offsets[34]);
  object.membershipEventType = reader.readStringOrNull(offsets[35]);
  object.membershipInviteLink = reader.readStringOrNull(offsets[36]);
  object.membershipMetadata = reader.readStringOrNull(offsets[37]);
  object.membershipNewRole = reader.readLongOrNull(offsets[38]);
  object.membershipPreviousRole = reader.readLongOrNull(offsets[39]);
  object.membershipRemovalReason = reader.readStringOrNull(offsets[40]);
  object.mentions = reader.readStringOrNull(offsets[41]);
  object.messageId = reader.readString(offsets[42]);
  object.messageIndex = reader.readLong(offsets[43]);
  object.metadata = reader.readStringOrNull(offsets[44]);
  object.mimeType = reader.readStringOrNull(offsets[45]);
  object.params = reader.readStringOrNull(offsets[46]);
  object.pollId = reader.readStringOrNull(offsets[47]);
  object.question = reader.readStringOrNull(offsets[48]);
  object.quotedMessageId = reader.readStringOrNull(offsets[49]);
  object.reactions = reader.readStringOrNull(offsets[50]);
  object.repliedToMessageId = reader.readStringOrNull(offsets[51]);
  object.senderAvatar = reader.readStringOrNull(offsets[52]);
  object.senderId = reader.readString(offsets[53]);
  object.senderName = reader.readStringOrNull(offsets[54]);
  object.siteName = reader.readStringOrNull(offsets[55]);
  object.status =
      _MessagestatusValueEnumMap[reader.readStringOrNull(offsets[56])] ??
          MessageStatus.sending;
  object.stickerId = reader.readStringOrNull(offsets[57]);
  object.stickerPackId = reader.readStringOrNull(offsets[58]);
  object.stickerPackName = reader.readStringOrNull(offsets[59]);
  object.stickerUrl = reader.readStringOrNull(offsets[60]);
  object.tags = reader.readStringOrNull(offsets[61]);
  object.text = reader.readStringOrNull(offsets[62]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[64]);
  object.type =
      _MessagetypeValueEnumMap[reader.readStringOrNull(offsets[65])] ??
          MessageType.text;
  object.updatedAt = reader.readDateTimeOrNull(offsets[66]);
  object.width = reader.readLongOrNull(offsets[67]);
  return object;
}

P _messageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readBoolOrNull(offset)) as P;
    case 24:
      return (reader.readBool(offset)) as P;
    case 25:
      return (reader.readBoolOrNull(offset)) as P;
    case 26:
      return (reader.readBool(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    case 37:
      return (reader.readStringOrNull(offset)) as P;
    case 38:
      return (reader.readLongOrNull(offset)) as P;
    case 39:
      return (reader.readLongOrNull(offset)) as P;
    case 40:
      return (reader.readStringOrNull(offset)) as P;
    case 41:
      return (reader.readStringOrNull(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readLong(offset)) as P;
    case 44:
      return (reader.readStringOrNull(offset)) as P;
    case 45:
      return (reader.readStringOrNull(offset)) as P;
    case 46:
      return (reader.readStringOrNull(offset)) as P;
    case 47:
      return (reader.readStringOrNull(offset)) as P;
    case 48:
      return (reader.readStringOrNull(offset)) as P;
    case 49:
      return (reader.readStringOrNull(offset)) as P;
    case 50:
      return (reader.readStringOrNull(offset)) as P;
    case 51:
      return (reader.readStringOrNull(offset)) as P;
    case 52:
      return (reader.readStringOrNull(offset)) as P;
    case 53:
      return (reader.readString(offset)) as P;
    case 54:
      return (reader.readStringOrNull(offset)) as P;
    case 55:
      return (reader.readStringOrNull(offset)) as P;
    case 56:
      return (_MessagestatusValueEnumMap[reader.readStringOrNull(offset)] ??
          MessageStatus.sending) as P;
    case 57:
      return (reader.readStringOrNull(offset)) as P;
    case 58:
      return (reader.readStringOrNull(offset)) as P;
    case 59:
      return (reader.readStringOrNull(offset)) as P;
    case 60:
      return (reader.readStringOrNull(offset)) as P;
    case 61:
      return (reader.readStringOrNull(offset)) as P;
    case 62:
      return (reader.readStringOrNull(offset)) as P;
    case 63:
      return (reader.readStringOrNull(offset)) as P;
    case 64:
      return (reader.readStringOrNull(offset)) as P;
    case 65:
      return (_MessagetypeValueEnumMap[reader.readStringOrNull(offset)] ??
          MessageType.text) as P;
    case 66:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 67:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MessagestatusEnumValueMap = {
  r'sending': r'sending',
  r'sent': r'sent',
  r'delivered': r'delivered',
  r'read': r'read',
  r'failed': r'failed',
  r'deleted': r'deleted',
  r'revoked': r'revoked',
};
const _MessagestatusValueEnumMap = {
  r'sending': MessageStatus.sending,
  r'sent': MessageStatus.sent,
  r'delivered': MessageStatus.delivered,
  r'read': MessageStatus.read,
  r'failed': MessageStatus.failed,
  r'deleted': MessageStatus.deleted,
  r'revoked': MessageStatus.revoked,
};
const _MessagetypeEnumValueMap = {
  r'text': r'text',
  r'image': r'image',
  r'voice': r'voice',
  r'file': r'file',
  r'video': r'video',
  r'system': r'system',
  r'membership': r'membership',
};
const _MessagetypeValueEnumMap = {
  r'text': MessageType.text,
  r'image': MessageType.image,
  r'voice': MessageType.voice,
  r'file': MessageType.file,
  r'video': MessageType.video,
  r'system': MessageType.system,
  r'membership': MessageType.membership,
};

Id _messageGetId(Message object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _messageGetLinks(Message object) {
  return [object.conversation];
}

void _messageAttach(IsarCollection<dynamic> col, Id id, Message object) {
  object.id = id;
  object.conversation
      .attach(col, col.isar.collection<Conversation>(), r'conversation', id);
}

extension MessageByIndex on IsarCollection<Message> {
  Future<Message?> getByMessageId(String messageId) {
    return getByIndex(r'messageId', [messageId]);
  }

  Message? getByMessageIdSync(String messageId) {
    return getByIndexSync(r'messageId', [messageId]);
  }

  Future<bool> deleteByMessageId(String messageId) {
    return deleteByIndex(r'messageId', [messageId]);
  }

  bool deleteByMessageIdSync(String messageId) {
    return deleteByIndexSync(r'messageId', [messageId]);
  }

  Future<List<Message?>> getAllByMessageId(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'messageId', values);
  }

  List<Message?> getAllByMessageIdSync(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'messageId', values);
  }

  Future<int> deleteAllByMessageId(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'messageId', values);
  }

  int deleteAllByMessageIdSync(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'messageId', values);
  }

  Future<Id> putByMessageId(Message object) {
    return putByIndex(r'messageId', object);
  }

  Id putByMessageIdSync(Message object, {bool saveLinks = true}) {
    return putByIndexSync(r'messageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMessageId(List<Message> objects) {
    return putAllByIndex(r'messageId', objects);
  }

  List<Id> putAllByMessageIdSync(List<Message> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'messageId', objects, saveLinks: saveLinks);
  }
}

extension MessageQueryWhereSort on QueryBuilder<Message, Message, QWhere> {
  QueryBuilder<Message, Message, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Message, Message, QAfterWhere> anyTextForSearch() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'textForSearch'),
      );
    });
  }
}

extension MessageQueryWhere on QueryBuilder<Message, Message, QWhereClause> {
  QueryBuilder<Message, Message, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Message, Message, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> idBetween(
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

  QueryBuilder<Message, Message, QAfterWhereClause> messageIdEqualTo(
      String messageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'messageId',
        value: [messageId],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> messageIdNotEqualTo(
      String messageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdEqualToAnyMessageIndexCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_messageIndex_createdAt',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdNotEqualToAnyMessageIndexCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexEqualToAnyCreatedAt(
          String conversationId, int messageIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_messageIndex_createdAt',
        value: [conversationId, messageIndex],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdEqualToMessageIndexNotEqualToAnyCreatedAt(
          String conversationId, int messageIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId],
              upper: [conversationId, messageIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex],
              includeLower: false,
              upper: [conversationId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex],
              includeLower: false,
              upper: [conversationId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId],
              upper: [conversationId, messageIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdEqualToMessageIndexGreaterThanAnyCreatedAt(
    String conversationId,
    int messageIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId, messageIndex],
        includeLower: include,
        upper: [conversationId],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdEqualToMessageIndexLessThanAnyCreatedAt(
    String conversationId,
    int messageIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId],
        upper: [conversationId, messageIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdEqualToMessageIndexBetweenAnyCreatedAt(
    String conversationId,
    int lowerMessageIndex,
    int upperMessageIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId, lowerMessageIndex],
        includeLower: includeLower,
        upper: [conversationId, upperMessageIndex],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexCreatedAtEqualTo(
          String conversationId, int messageIndex, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_messageIndex_createdAt',
        value: [conversationId, messageIndex, createdAt],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexEqualToCreatedAtNotEqualTo(
          String conversationId, int messageIndex, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex],
              upper: [conversationId, messageIndex, createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex, createdAt],
              includeLower: false,
              upper: [conversationId, messageIndex],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex, createdAt],
              includeLower: false,
              upper: [conversationId, messageIndex],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_messageIndex_createdAt',
              lower: [conversationId, messageIndex],
              upper: [conversationId, messageIndex, createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexEqualToCreatedAtGreaterThan(
    String conversationId,
    int messageIndex,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId, messageIndex, createdAt],
        includeLower: include,
        upper: [conversationId, messageIndex],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexEqualToCreatedAtLessThan(
    String conversationId,
    int messageIndex,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId, messageIndex],
        upper: [conversationId, messageIndex, createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause>
      conversationIdMessageIndexEqualToCreatedAtBetween(
    String conversationId,
    int messageIndex,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_messageIndex_createdAt',
        lower: [conversationId, messageIndex, lowerCreatedAt],
        includeLower: includeLower,
        upper: [conversationId, messageIndex, upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'textForSearch',
        value: [null],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'textForSearch',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchEqualTo(
      String? textForSearch) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'textForSearch',
        value: [textForSearch],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchNotEqualTo(
      String? textForSearch) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textForSearch',
              lower: [],
              upper: [textForSearch],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textForSearch',
              lower: [textForSearch],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textForSearch',
              lower: [textForSearch],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textForSearch',
              lower: [],
              upper: [textForSearch],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchGreaterThan(
    String? textForSearch, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'textForSearch',
        lower: [textForSearch],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchLessThan(
    String? textForSearch, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'textForSearch',
        lower: [],
        upper: [textForSearch],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchBetween(
    String? lowerTextForSearch,
    String? upperTextForSearch, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'textForSearch',
        lower: [lowerTextForSearch],
        includeLower: includeLower,
        upper: [upperTextForSearch],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchStartsWith(
      String TextForSearchPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'textForSearch',
        lower: [TextForSearchPrefix],
        upper: ['$TextForSearchPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'textForSearch',
        value: [''],
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterWhereClause> textForSearchIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'textForSearch',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'textForSearch',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'textForSearch',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'textForSearch',
              upper: [''],
            ));
      }
    });
  }
}

extension MessageQueryFilter
    on QueryBuilder<Message, Message, QFilterCondition> {
  QueryBuilder<Message, Message, QAfterFilterCondition> actionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'action',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'action',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actorUserId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actorUserId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actorUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actorUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> actorUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      actorUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actorUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'affectedUserIds',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'affectedUserIds',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'affectedUserIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'affectedUserIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> affectedUserIdsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'affectedUserIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'affectedUserIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      affectedUserIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'affectedUserIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'caption',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'caption',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caption',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'caption',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'caption',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caption',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> captionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'caption',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactAvatar',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactAvatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactAvatar',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactAvatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactAvatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactAvatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactAvatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactAvatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactEmail',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactEmail',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> contactPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      contactPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdEqualTo(
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

  QueryBuilder<Message, Message, QAfterFilterCondition>
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

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdLessThan(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdBetween(
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

  QueryBuilder<Message, Message, QAfterFilterCondition>
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

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdEndsWith(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'editedAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'editedAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'editedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'editedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'editedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> editedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'editedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eventTimestamp',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      eventTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eventTimestamp',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTimestampEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      eventTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eventType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eventType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> eventTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'faviconUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'faviconUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> faviconUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileSize',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileSize',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> fileSizeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'forwardedFromConversationId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'forwardedFromConversationId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'forwardedFromConversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'forwardedFromConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'forwardedFromConversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFromConversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromConversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'forwardedFromConversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'forwardedFromMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'forwardedFromMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'forwardedFromMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'forwardedFromMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'forwardedFromMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFromMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      forwardedFromMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'forwardedFromMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hashtags',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hashtags',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashtags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hashtags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hashtags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashtags',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> hashtagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hashtags',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> heightBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> isAnonymousIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isAnonymous',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> isAnonymousIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isAnonymous',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> isAnonymousEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAnonymous',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> isEditedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEdited',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      isMultipleChoiceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isMultipleChoice',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      isMultipleChoiceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isMultipleChoice',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> isMultipleChoiceEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMultipleChoice',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> isPinnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkDescription',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkDescription',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkDescriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkImageUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkImageUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      linkImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkTitle',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkTitle',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> linkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mediaUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mediaUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mediaUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipActor',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipActor',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipActor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipActor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> membershipActorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipActor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipActor',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipActorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipActor',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipAffectedMembers',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipAffectedMembers',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipAffectedMembers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipAffectedMembers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipAffectedMembers',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipAffectedMembers',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipAffectedMembersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipAffectedMembers',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipEventType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipEventType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipEventType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipEventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipEventType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipEventType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipEventTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipEventType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipInviteLink',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipInviteLink',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipInviteLink',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipInviteLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipInviteLink',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipInviteLink',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipInviteLinkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipInviteLink',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipMetadata',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipMetadata',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipMetadata',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipMetadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipMetadata',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipMetadata',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipMetadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipMetadata',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipNewRole',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipNewRole',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipNewRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipNewRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipNewRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipNewRoleBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipNewRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipPreviousRole',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipPreviousRole',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipPreviousRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipPreviousRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipPreviousRole',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipPreviousRoleBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipPreviousRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'membershipRemovalReason',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'membershipRemovalReason',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membershipRemovalReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membershipRemovalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membershipRemovalReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membershipRemovalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      membershipRemovalReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membershipRemovalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mentions',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mentions',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mentions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mentions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mentions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mentions',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mentionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mentions',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'messageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> messageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadata',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadata',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> metadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mimeType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mimeType',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mimeType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mimeType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mimeType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> mimeTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mimeType',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'params',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'params',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'params',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'params',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'params',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'params',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> paramsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'params',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pollId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pollId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pollId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pollId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pollId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pollId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> pollIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pollId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'question',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'question',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'question',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'question',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quotedMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quotedMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quotedMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quotedMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> quotedMessageIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quotedMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quotedMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      quotedMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quotedMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reactions',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reactions',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reactions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reactions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reactions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reactions',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> reactionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reactions',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'repliedToMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'repliedToMessageId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repliedToMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repliedToMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repliedToMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repliedToMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      repliedToMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repliedToMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      senderAvatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderAvatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderAvatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderAvatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      senderAvatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> senderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'siteName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'siteName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> siteNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusEqualTo(
    MessageStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusGreaterThan(
    MessageStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusLessThan(
    MessageStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusBetween(
    MessageStatus lower,
    MessageStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stickerId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stickerId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stickerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stickerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stickerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stickerId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stickerPackId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stickerPackId',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stickerPackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stickerPackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stickerPackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerPackId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stickerPackId',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stickerPackName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stickerPackName',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stickerPackName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stickerPackName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerPackNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stickerPackName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerPackName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      stickerPackNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stickerPackName',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stickerUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stickerUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stickerUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stickerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stickerUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> stickerUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stickerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'text',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'text',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textForSearch',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      textForSearchIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textForSearch',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      textForSearchGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textForSearch',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textForSearch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textForSearch',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> textForSearchIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textForSearch',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      textForSearchIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textForSearch',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition>
      thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> typeEqualTo(
    MessageType value, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeGreaterThan(
    MessageType value, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeLessThan(
    MessageType value, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeBetween(
    MessageType lower,
    MessageType upper, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeContains(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<Message, Message, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<Message, Message, QAfterFilterCondition> widthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'width',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> widthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'width',
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> widthEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> widthGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> widthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> widthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MessageQueryObject
    on QueryBuilder<Message, Message, QFilterCondition> {}

extension MessageQueryLinks
    on QueryBuilder<Message, Message, QFilterCondition> {
  QueryBuilder<Message, Message, QAfterFilterCondition> conversation(
      FilterQuery<Conversation> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'conversation');
    });
  }

  QueryBuilder<Message, Message, QAfterFilterCondition> conversationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'conversation', 0, true, 0, true);
    });
  }
}

extension MessageQuerySortBy on QueryBuilder<Message, Message, QSortBy> {
  QueryBuilder<Message, Message, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByActorUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUserId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByActorUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUserId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByAffectedUserIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'affectedUserIds', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByAffectedUserIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'affectedUserIds', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByCaption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caption', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByCaptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caption', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactAvatar', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactAvatar', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactEmail', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactEmail', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editedAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEditedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editedAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEventTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEventTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByForwardedFromConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromConversationId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByForwardedFromConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromConversationId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByForwardedFromMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByForwardedFromMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByHashtags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashtags', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByHashtagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashtags', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsAnonymous() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnonymous', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsAnonymousDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnonymous', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEdited', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEdited', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsMultipleChoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultipleChoice', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsMultipleChoiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultipleChoice', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkDescription', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkDescription', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkTitle', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkTitle', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLinkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMediaUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMediaUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipActor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipActor', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipActorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipActor', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByMembershipAffectedMembers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipAffectedMembers', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByMembershipAffectedMembersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipAffectedMembers', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipEventType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipEventType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipInviteLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipInviteLink', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByMembershipInviteLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipInviteLink', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipMetadata', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipMetadata', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipNewRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipNewRole', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipNewRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipNewRole', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipPreviousRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipPreviousRole', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByMembershipPreviousRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipPreviousRole', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMembershipRemovalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipRemovalReason', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      sortByMembershipRemovalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipRemovalReason', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMentions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mentions', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMentionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mentions', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageIndex', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageIndex', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByParams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'params', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByParamsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'params', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByPollId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pollId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByPollIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pollId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByQuotedMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quotedMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByQuotedMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quotedMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByReactions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reactions', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByReactionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reactions', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByRepliedToMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repliedToMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByRepliedToMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repliedToMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerPackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByStickerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTextForSearch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textForSearch', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTextForSearchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textForSearch', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension MessageQuerySortThenBy
    on QueryBuilder<Message, Message, QSortThenBy> {
  QueryBuilder<Message, Message, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByActorUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUserId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByActorUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUserId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByAffectedUserIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'affectedUserIds', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByAffectedUserIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'affectedUserIds', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByCaption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caption', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByCaptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caption', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactAvatar', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactAvatar', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactEmail', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactEmail', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editedAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEditedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editedAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEventTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEventTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByForwardedFromConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromConversationId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByForwardedFromConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromConversationId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByForwardedFromMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByForwardedFromMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFromMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByHashtags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashtags', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByHashtagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashtags', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsAnonymous() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnonymous', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsAnonymousDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnonymous', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEdited', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEdited', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsMultipleChoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultipleChoice', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsMultipleChoiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultipleChoice', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkDescription', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkDescription', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkTitle', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkTitle', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLinkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMediaUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMediaUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipActor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipActor', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipActorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipActor', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByMembershipAffectedMembers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipAffectedMembers', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByMembershipAffectedMembersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipAffectedMembers', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipEventType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipEventType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipEventTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipEventType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipInviteLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipInviteLink', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByMembershipInviteLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipInviteLink', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipMetadata', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipMetadata', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipNewRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipNewRole', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipNewRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipNewRole', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipPreviousRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipPreviousRole', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByMembershipPreviousRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipPreviousRole', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMembershipRemovalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipRemovalReason', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy>
      thenByMembershipRemovalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membershipRemovalReason', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMentions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mentions', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMentionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mentions', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageIndex', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMessageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageIndex', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByParams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'params', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByParamsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'params', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByPollId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pollId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByPollIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pollId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByQuotedMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quotedMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByQuotedMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quotedMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByReactions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reactions', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByReactionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reactions', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByRepliedToMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repliedToMessageId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByRepliedToMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repliedToMessageId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackId', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerPackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackId', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackName', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerPackName', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByStickerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickerUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTextForSearch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textForSearch', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTextForSearchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textForSearch', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<Message, Message, QAfterSortBy> thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension MessageQueryWhereDistinct
    on QueryBuilder<Message, Message, QDistinct> {
  QueryBuilder<Message, Message, QDistinct> distinctByAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByActorUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByAffectedUserIds(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'affectedUserIds',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByCaption(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caption', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByContactAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactAvatar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByContactEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactEmail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByContactId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByContactName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByContactPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByConversationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'editedAt');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByEventTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventTimestamp');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByEventType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByFaviconUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize');
    });
  }

  QueryBuilder<Message, Message, QDistinct>
      distinctByForwardedFromConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'forwardedFromConversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByForwardedFromMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'forwardedFromMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByHashtags(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashtags', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByIsAnonymous() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAnonymous');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByIsEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEdited');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByIsMultipleChoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMultipleChoice');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByLinkDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByLinkImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkImageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByLinkTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByLinkUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMediaUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipActor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipActor',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipAffectedMembers(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipAffectedMembers',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipEventType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipEventType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipInviteLink(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipInviteLink',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipMetadata(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipMetadata',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipNewRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipNewRole');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipPreviousRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipPreviousRole');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMembershipRemovalReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membershipRemovalReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMentions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mentions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMessageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageIndex');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMetadata(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadata', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByMimeType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mimeType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByParams(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'params', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByPollId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pollId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByQuestion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'question', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByQuotedMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quotedMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByReactions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reactions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByRepliedToMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repliedToMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctBySenderAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderAvatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctBySenderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctBySenderName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctBySiteName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siteName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByStickerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stickerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByStickerPackId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stickerPackId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByStickerPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stickerPackName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByStickerUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stickerUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByTags(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByTextForSearch(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textForSearch',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByThumbnailUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<Message, Message, QDistinct> distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension MessageQueryProperty
    on QueryBuilder<Message, Message, QQueryProperty> {
  QueryBuilder<Message, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> actorUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorUserId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> affectedUserIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'affectedUserIds');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> captionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caption');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> contactAvatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactAvatar');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> contactEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactEmail');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> contactIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> contactNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactName');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> contactPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactPhone');
    });
  }

  QueryBuilder<Message, String, QQueryOperations> conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<Message, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Message, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<Message, DateTime?, QQueryOperations> editedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'editedAt');
    });
  }

  QueryBuilder<Message, DateTime?, QQueryOperations> eventTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventTimestamp');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> eventTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventType');
    });
  }

  QueryBuilder<Message, DateTime?, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> faviconUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconUrl');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<Message, double?, QQueryOperations> fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      forwardedFromConversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'forwardedFromConversationId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      forwardedFromMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'forwardedFromMessageId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> hashtagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashtags');
    });
  }

  QueryBuilder<Message, int?, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<Message, bool?, QQueryOperations> isAnonymousProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAnonymous');
    });
  }

  QueryBuilder<Message, bool, QQueryOperations> isEditedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEdited');
    });
  }

  QueryBuilder<Message, bool?, QQueryOperations> isMultipleChoiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMultipleChoice');
    });
  }

  QueryBuilder<Message, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> linkDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkDescription');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> linkImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkImageUrl');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> linkTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkTitle');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> linkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkUrl');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPath');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> mediaUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaUrl');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> membershipActorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipActor');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      membershipAffectedMembersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipAffectedMembers');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      membershipEventTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipEventType');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      membershipInviteLinkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipInviteLink');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      membershipMetadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipMetadata');
    });
  }

  QueryBuilder<Message, int?, QQueryOperations> membershipNewRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipNewRole');
    });
  }

  QueryBuilder<Message, int?, QQueryOperations>
      membershipPreviousRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipPreviousRole');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      membershipRemovalReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membershipRemovalReason');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> mentionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mentions');
    });
  }

  QueryBuilder<Message, String, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<Message, int, QQueryOperations> messageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageIndex');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> mimeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mimeType');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> paramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'params');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> pollIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pollId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> questionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'question');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> quotedMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quotedMessageId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> reactionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reactions');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations>
      repliedToMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repliedToMessageId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> senderAvatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderAvatar');
    });
  }

  QueryBuilder<Message, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> senderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderName');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> siteNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siteName');
    });
  }

  QueryBuilder<Message, MessageStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> stickerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickerId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> stickerPackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickerPackId');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> stickerPackNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickerPackName');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> stickerUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickerUrl');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> textForSearchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textForSearch');
    });
  }

  QueryBuilder<Message, String?, QQueryOperations> thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<Message, MessageType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<Message, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Message, int?, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}
