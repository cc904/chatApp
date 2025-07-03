import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// 应用本地化代理类
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // 支持的语言
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale"');
}

/// 应用本地化基类
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文简体
    Locale('en', 'US'), // 英文
  ];

  // 通用文本
  String get appName;

  // 按钮文本
  String get cancel;
  String get confirm;
  String get imageLoadFailed;
  String get sendFile;
  String get save;
  String get delete;
  String get edit;
  String get done;

  // 错误消息
  String get errorOccurred;
  String get networkError;
  String get unknownError;

  // 认证相关
  String get login;
  String get register;
  String get logout;
  String get username;
  String get password;
  String get forgotPassword;

  // 聊天相关
  String get newMessage;
  String get typing;
  String get online;
  String get offline;
  String get lastSeen;
  String get sendMessage;
  String get attachment;
  String get camera;
  String get gallery;
  String get audio;
  String get file;
  String get location;
  String get contact;
  String get chats;
  String get allChats;
  String get privateChats;
  String get groupChats;
  String get channelChats;
  String get unreadChats;
  String get search;
  String get searchButton;
  String get noChats;
  String get noMatchingChats;

  // 聊天信息页面
  String get back;
  String get chatCancel;
  String get chatDone;
  String get call;
  String get video;
  String get mute;
  String get unmute;
  String get more;
  String get leave;
  String get chatAddMembers;
  String get deleteContact;
  String get confirmDeleteContact;
  String get chatLeaveGroup;
  String get confirmLeaveGroup;
  String get leaveChannel;
  String get confirmLeaveChannel;
  String get members;
  String get media;
  String get files;
  String get music;
  String get chatVoice;
  String get chatLinks;
  String get noMedia;
  String get noFiles;
  String get noMusic;
  String get noVoice;
  String get noLinks;
  String get userId;
  String get groupId;
  String get channelId;
  String get userIdCopied;
  String get groupIdCopied;
  String get channelIdCopied;

  // 设置相关
  String get settings;
  String get profile;
  String get privacy;
  String get notifications;
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get systemMode;

  // 群组相关
  String get createGroup;
  String get addMembers;
  String get removeMembers;
  String get leaveGroup;
  String get deleteGroup;

  // 联系人相关
  String get contacts;
  String get addContact;
  String get removeContact;
  String get blockContact;
  String get unblockContact;

  // 媒体相关
  String get photos;
  String get videos;
  String get documents;
  String get links;
  String get voice;

  // 时间相关
  String get today;
  String get yesterday;
  String get justNow;

  // 格式化消息
  String formatMinutesAgo(int minutes) {
    return Intl.plural(
      minutes,
      zero: '刚刚',
      one: '1分钟前',
      other: '$minutes分钟前',
      locale: 'zh',
    );
  }

  String formatHoursAgo(int hours) {
    return Intl.plural(
      hours,
      one: '1小时前',
      other: '$hours小时前',
      locale: 'zh',
    );
  }

  String formatDaysAgo(int days) {
    return Intl.plural(
      days,
      one: '1天前',
      other: '$days天前',
      locale: 'zh',
    );
  }

  // 自定义消息
  String get cannotCreatePrivateChat;
  String get failedToCreateChat;
  String get failedToGetConversation;
  String get failedToOpenChat;

  // 通用操作
  String get copy;
  String get qrCodeCopied;

  // 新建对话底部弹窗
  String get newGroup;
  String get newChannel;
  String get next;
  String get whoToAdd;
  String get selected;

  // 联系人页面
  String get searchContacts;
  String get serverConnectionError;
  String get retry;
  String cannotOpenChatWith(String name);

  // 语言设置
  String get languageSwitched;
  String get languageSwitchFailed;

  // 频道信息页面
  String get channelTitle;
  String get channelMembers;
  String get channelViews;
  String get whatIsChannel;
  String get channelDescription;
  String get createChannel;

  // Profile 页面相关
  String get myProfile;
  String get loadingUserInfo;
  String get loadFailed;
  String get refreshProfile;
  String get phoneNumber;
  String get phoneNotBound;
  String get myQRCode;
  String get accountSecurity;
  String get privacySettings;
  String get notificationSettings;
  String get aboutUs;
  String get confirmLogout;
  String get confirmLogoutMessage;
  String get logoutFailed;
  String get refreshUserInfo;

  // 开发者选项
  String get developerOptions;
  String get viewUserInfo;
  String get debugDatabaseStatus;
  String get tokenStatusDiagnosis;
  String get resetData;
  String get refreshToken;
  String get serverSettings;
  String get currentUserInfo;
  String get noUserInfoLoaded;
  String get close;
  String get currentServer;
  String get availableServers;
  String get switchTo;
  String get reset;
  String get resetToMainServer;
  String get autoFailover;
  String get tokenRefreshTest;
  String get tokenTestDescription;
  String get testTokenStatus;
  String get testResults;
  String get manualRefreshTest;
  String get testFailed;
  String get testSuccess;
  String get resetDataWarning;
  String get confirmReset;
  String get dataResetComplete;
  String get dataResetCompleteMessage;
  String get exitNow;
  String get resetDataFailed;
  String get userInfoDiagnosis;
  String get diagnosisComplete;
  String get diagnosisFailed;
  String get messageSort;
  String get messageSortTest;
  String get conversationSyncManagement;
  String get syncStatusInfo;
  String get lastSyncTime;
  String get neverSynced;
  String get operationOptions;
  String get incrementalSync;
  String get incrementalSyncDesc;
  String get fullSync;
  String get fullSyncDesc;
  String get clearSyncRecord;
  String get clearSyncRecordDesc;
  String get performingIncrementalSync;
  String get performingFullSync;
  String get incrementalSyncTriggered;
  String get fullSyncTriggered;
  String get syncTimeClearSuccess;
  String get clearSyncTimeFailed;
  String get fixUserDataIssue;
  String get fixingUserData;
  String get userDataFixSuccess;
  String get userDataFixFailed;
  String get noValidUserInfo;
  String get databaseDebugInfo;
  String get databaseInitialized;
  String get databaseUserExists;
  String get userInfoInDatabase;
  String get noDatabaseUserRecord;
  String get secureStorageInfo;
  String get storedToken;
  String get refreshedToken;
  String get autoRefresh;
  String get tokenPrefix;
  String get profileCubitStatus;
  String get cubitStatus;
  String get cubitUserExists;
  String get cubitUserName;
  String get cubitAvatar;
  String get debugInfoCollected;
  String get debugFailed;
  String get cannotGetDebugInfo;
  String get tryFix;
  String get fixAttempt;
  String get fixing;
  String get feedback;

  // Chat页面相关
  String get unknownContact;
  String get inputMessage;
  String get connecting;
  String get holdToSpeakButtonText;
  String get releaseToFinish;
  String get sendingVoice;
  String get fileUploadFailed;
  String get recordingTooShort;
  String get recordingFailed;
  String get voiceSendFailed;
  String get imageSendFailed;
  String get fileSendFailed;
  String get debugStateFailed;
  String get cannotLocateMessage;
  String get messageTooLong;
  String get messageTooLongDetails;
  String get sendFailed;
  String get recordingFailedPermission;
  String get videoRecordingComingSoon;
  String get macOSGalleryTip;
  String get selectFromGallery;
  String get takePhoto;
  String get imageSelectionFailed;
  String get sendingImage;
  String get uploadingImage;
  String get sendingFile;
  String get uploadingFile;
  String get fileSelectionFailed;
  String get picture;
  String get shoot;
  String get fileOption;
  String get contactOption;
  String get contactFeatureComingSoon;
  String get recordVideo;
  String get longPressToRecord;
  String get recording;
  String get longPressRecordVideo;
  String get recordingInProgress;
  String get longPressRecord;
  String get revokeFeatureComingSoon;
  String get messageRevoked;
  String get revokeFailed;
  String get copiedToClipboard;
  String get messageExpiredCannotRevoke;
  String get networkErrorCannotRevoke;
  String get revokeMessage;
  String get confirmRevokeMessage;
  String get revokeTimeRemaining;
  String get revokeInstructions;
  String get revokingMessage;
  String get deletingMessage;
  String get messageDeleted;
  String get deleteFailed;
  String get deleteMessage;
  String get confirmDeleteMessage;
  String get onlineStatus;
  String get offlineStatus;
  String get searchMessages;
  String get allEmojis;
  String get noMessagesInChat;
  String get jumpedToFirstMessage;
  String get jumpFailed;
  String get resendingMessage;
  String get jumpToLatestFailed;
  String get unreadNotInList;
  String get jumpToUnreadFailed;
  String get selectDate;
  String get addImageCaption;
  String get addFileCaption;
  String get jumpToDate;
  String get searching;
  String get noMatchFound;
  String get debugStateOutputToConsole;
  String get noMessagesFoundOnDate;
  String get send;
  String get recordingMaxDuration;
  String get recordingAutoSend;

  // 消息操作
  String get reply;
  String get forward;
  String get revoke;
  String get deleteAction;

  // 联系人编辑相关
  String get nickname;
  String get remark;

  // 同步状态相关
  String get syncFailed;
  String get syncRetrying;
}
