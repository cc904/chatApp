import 'app_localizations.dart';
import 'package:intl/intl.dart';

/// 英文本地化实现
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appName => 'ThisApp';

  // 按钮文本
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';

  @override
  String get imageLoadFailed => 'Image load failed';

  @override
  String get sendFile => 'Send File';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get done => 'Done';

  // 错误消息
  @override
  String get errorOccurred => 'Error Occurred';
  @override
  String get networkError => 'Network Error';
  @override
  String get unknownError => 'Unknown Error';

  // 认证相关
  @override
  String get login => 'Login';
  @override
  String get register => 'Register';
  @override
  String get logout => 'Logout';
  @override
  String get username => 'Username';
  @override
  String get password => 'Password';
  @override
  String get forgotPassword => 'Forgot Password';
  @override
  String get quickLogin => 'Quick Login';
  @override
  String get passwordLogin => 'Password Login';
  @override
  String get verificationCode => 'Verification Code';
  @override
  String get enterVerificationCode => 'Enter verification code';
  @override
  String get getVerificationCode => 'Get Code';
  @override
  String get sending => 'Sending...';
  @override
  String get resend => 'Resend';

  // 聊天相关
  @override
  String get newMessage => 'New Message';
  @override
  String get typing => 'Typing...';
  @override
  String get online => 'Online';
  @override
  String get offline => 'Offline';
  @override
  String get lastSeen => 'Last Seen';
  @override
  String get sendMessage => 'Send Message';
  @override
  String get attachment => 'Attachment';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Gallery';
  @override
  String get audio => 'Audio';
  @override
  String get file => 'File';
  @override
  String get location => 'Location';
  @override
  String get contact => 'Contact';
  @override
  String get chats => 'Chats';
  @override
  String get allChats => 'All Chats';
  @override
  String get privateChats => 'Private';
  @override
  String get groupChats => 'Groups';
  @override
  String get channelChats => 'Channels';
  @override
  String get unreadChats => 'Unread';
  @override
  String get search => 'Search';
  @override
  String get searchButton => 'Search';
  @override
  String get noChats => 'No Chats';
  @override
  String get noMatchingChats => 'No matching chats found';

  // 设置相关
  @override
  String get settings => 'Settings';
  @override
  String get profile => 'Profile';
  @override
  String get privacy => 'Privacy';
  @override
  String get notifications => 'Notifications';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get lightMode => 'Light Mode';
  @override
  String get systemMode => 'System Mode';

  // 群组相关
  @override
  String get createGroup => 'Create Group';
  @override
  String get addMembers => 'Add Members';
  @override
  String get removeMembers => 'Remove Members';
  @override
  String get leaveGroup => 'Leave Group';
  @override
  String get deleteGroup => 'Delete Group';

  // 联系人相关
  @override
  String get contacts => 'Contacts';
  @override
  String get addContact => 'Add Contact';
  @override
  String get removeContact => 'Remove Contact';
  @override
  String get blockContact => 'Block Contact';
  @override
  String get unblockContact => 'Unblock Contact';

  // 媒体相关
  @override
  String get photos => 'Photos';
  @override
  String get videos => 'Videos';
  @override
  String get documents => 'Documents';
  @override
  String get links => 'Links';
  @override
  String get voice => 'Voice';

  // 时间相关
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get justNow => 'Just Now';

  // 格式化消息
  @override
  String formatMinutesAgo(int minutes) {
    return Intl.plural(
      minutes,
      zero: 'Just now',
      one: '1 minute ago',
      other: '$minutes minutes ago',
      locale: 'en',
    );
  }

  @override
  String formatHoursAgo(int hours) {
    return Intl.plural(
      hours,
      one: '1 hour ago',
      other: '$hours hours ago',
      locale: 'en',
    );
  }

  @override
  String formatDaysAgo(int days) {
    return Intl.plural(
      days,
      one: '1 day ago',
      other: '$days days ago',
      locale: 'en',
    );
  }

  // 自定义消息
  @override
  String get cannotCreatePrivateChat =>
      'Cannot create private chat with yourself';
  @override
  String get failedToCreateChat => 'Failed to create private chat';
  @override
  String get failedToGetConversation => 'Failed to get conversation info';
  @override
  String get failedToOpenChat => 'Failed to open private chat';

  // 聊天信息页面
  @override
  String get back => 'Back';
  @override
  String get chatCancel => 'Cancel';
  @override
  String get chatDone => 'Done';
  @override
  String get call => 'Call';
  @override
  String get video => 'Video';
  @override
  String get mute => 'Mute';
  @override
  String get unmute => 'Unmute';
  @override
  String get more => 'More';
  @override
  String get leave => 'Leave';
  @override
  String get chatAddMembers => 'Add Members';
  @override
  String get deleteContact => 'Delete Contact';
  @override
  String get confirmDeleteContact =>
      'You will no longer receive messages from this contact after deletion';
  @override
  String get chatLeaveGroup => 'Delete and Exit';
  @override
  String get confirmLeaveGroup =>
      'You will no longer receive messages from this group after leaving';
  @override
  String get leaveChannel => 'Leave Channel';
  @override
  String get confirmLeaveChannel =>
      'You will no longer receive messages from this channel after leaving';
  @override
  String get members => 'Members';
  @override
  String get media => 'Media';
  @override
  String get files => 'Files';
  @override
  String get music => 'Music';
  @override
  String get chatVoice => 'Voice';
  @override
  String get chatLinks => 'Links';
  @override
  String get noMedia => 'No media files';
  @override
  String get noFiles => 'No files';
  @override
  String get noMusic => 'No music files';
  @override
  String get noVoice => 'No voice messages';
  @override
  String get noLinks => 'No links';
  @override
  String get userId => 'User ID';
  @override
  String get groupId => 'Group ID';
  @override
  String get channelId => 'Channel ID';
  @override
  String get userIdCopied => 'User ID copied';
  @override
  String get groupIdCopied => 'Group ID copied';
  @override
  String get channelIdCopied => 'Channel ID copied';

  // 通用操作
  @override
  String get copy => 'Copy';
  @override
  String get qrCodeCopied => 'QR code data copied';

  // 新建对话底部弹窗
  @override
  String get newGroup => 'New Group';
  @override
  String get newChannel => 'New Channel';
  @override
  String get next => 'Next';
  @override
  String get whoToAdd => 'Who would you like to add?';
  @override
  String get selected => 'Selected';

  // 联系人页面
  @override
  String get searchContacts => 'Search';
  @override
  String get serverConnectionError => 'Cannot connect to server';
  @override
  String get retry => 'Retry';
  @override
  String cannotOpenChatWith(String name) => 'Cannot open chat with $name';

  // 语言设置
  @override
  String get languageSwitched => 'Language changed, restart app to take effect';
  @override
  String get languageSwitchFailed => 'Failed to change language';

  // 频道信息页面
  @override
  String get channelTitle => 'Channel';
  @override
  String get channelMembers => 'members';
  @override
  String get channelViews => 'views';
  @override
  String get whatIsChannel => 'What is a Channel?';
  @override
  String get channelDescription =>
      'Channels are a one-to-many tool\nfor broadcasting your messages\nto unlimited audiences.';
  @override
  String get createChannel => 'Create Channel';

  // Profile 页面相关
  @override
  String get myProfile => 'Profile';
  @override
  String get loadingUserInfo => 'Loading user info...';
  @override
  String get loadFailed => 'Load failed';
  @override
  String get refreshProfile => 'Refresh';
  @override
  String get phoneNumber => 'Phone';
  @override
  String get phoneNotBound => 'Not bound';
  @override
  String get myQRCode => 'My QR Code';
  @override
  String get accountSecurity => 'Account & Security';
  @override
  String get privacySettings => 'Privacy Settings';
  @override
  String get notificationSettings => 'Notification Settings';
  @override
  String get aboutUs => 'About Us';
  @override
  String get confirmLogout => 'Logout';
  @override
  String get confirmLogoutMessage => 'Are you sure you want to logout?';
  @override
  String get logoutFailed => 'Error occurred during logout';
  @override
  String get refreshUserInfo => 'Refresh User Info';

  // 开发者选项
  @override
  String get developerOptions => 'Developer Options';
  @override
  String get viewUserInfo => 'View User Info';
  @override
  String get debugDatabaseStatus => 'Debug Database Status';
  @override
  String get tokenStatusDiagnosis => 'Token Status Diagnosis';
  @override
  String get resetData => 'Reset Data';
  @override
  String get refreshToken => 'Refresh Token';
  @override
  String get serverSettings => 'Server Settings';
  @override
  String get currentUserInfo => 'Current User Info';
  @override
  String get noUserInfoLoaded => 'User info not loaded';
  @override
  String get close => 'Close';
  @override
  String get currentServer => 'Current Server';
  @override
  String get availableServers => 'Available Servers';
  @override
  String get switchTo => 'Switch';
  @override
  String get reset => 'Reset';
  @override
  String get resetToMainServer => 'Reset to main server';
  @override
  String get autoFailover => 'Auto failover when connection fails';
  @override
  String get tokenRefreshTest => 'Token Refresh Test';
  @override
  String get tokenTestDescription =>
      'Test current token status and refresh functionality';
  @override
  String get testTokenStatus => 'Testing token status...';
  @override
  String get testResults => 'Token Test Results';
  @override
  String get manualRefreshTest => 'Manual refresh';
  @override
  String get testFailed => 'Test failed';
  @override
  String get testSuccess => 'Test';
  @override
  String get resetDataWarning =>
      'This will clear all data, including contacts, conversations and messages.\n\nThis operation is irreversible. Are you sure you want to continue?';
  @override
  String get confirmReset => 'Confirm Reset';
  @override
  String get dataResetComplete => 'Data Reset Complete';
  @override
  String get dataResetCompleteMessage =>
      'All data has been cleared. The app needs to restart for the reset to take effect.';
  @override
  String get exitNow => 'Exit Now';
  @override
  String get resetDataFailed => 'Reset data failed';
  @override
  String get userInfoDiagnosis => 'Diagnose User Info';
  @override
  String get diagnosisComplete =>
      'User info diagnosis complete, check console logs';
  @override
  String get diagnosisFailed => 'User info diagnosis failed';
  @override
  String get messageSort => 'Test Message Sort';
  @override
  String get messageSortTest => 'Testing message sort...';
  @override
  String get conversationSyncManagement => 'Conversation Sync Management';
  @override
  String get syncStatusInfo => 'Sync status info:';
  @override
  String get lastSyncTime => 'Last sync time:';
  @override
  String get neverSynced => 'Never synced';
  @override
  String get operationOptions => 'Operation options:';
  @override
  String get incrementalSync => 'Incremental Sync';
  @override
  String get incrementalSyncDesc =>
      '• Incremental sync: Get updates since last sync only';
  @override
  String get fullSync => 'Full Sync';
  @override
  String get fullSyncDesc => '• Full sync: Get all conversation data';
  @override
  String get clearSyncRecord => 'Clear Record';
  @override
  String get clearSyncRecordDesc =>
      '• Clear record: Clear sync time, next sync will be full';
  @override
  String get performingIncrementalSync => 'Performing incremental sync...';
  @override
  String get performingFullSync => 'Performing full sync...';
  @override
  String get incrementalSyncTriggered =>
      'Incremental sync triggered, check conversation list updates';
  @override
  String get fullSyncTriggered =>
      'Full sync triggered, check conversation list updates';
  @override
  String get syncTimeClearSuccess =>
      'Sync time record cleared, next sync will be full';
  @override
  String get clearSyncTimeFailed => 'Clear failed';
  @override
  String get fixUserDataIssue => 'Try Fix';
  @override
  String get fixingUserData => 'Trying to fix...';
  @override
  String get userDataFixSuccess =>
      'User data fix successful, check page updates';
  @override
  String get userDataFixFailed => 'Fix failed: No valid user info found';
  @override
  String get noValidUserInfo => 'Fix failed';
  @override
  String get databaseDebugInfo => 'Database Debug Info';
  @override
  String get databaseInitialized => 'Database initialized';
  @override
  String get databaseUserExists => 'Database user exists';
  @override
  String get userInfoInDatabase => 'User info in database:';
  @override
  String get noDatabaseUserRecord =>
      'No user record in database!\nThis may be why user info was not properly saved after login.';
  @override
  String get secureStorageInfo => 'Secure storage info:';
  @override
  String get storedToken => 'Stored Token';
  @override
  String get refreshedToken => 'Refreshed Token';
  @override
  String get autoRefresh => 'Auto refresh';
  @override
  String get tokenPrefix => 'Token prefix';
  @override
  String get profileCubitStatus => 'ProfileCubit status:';
  @override
  String get cubitStatus => 'Status';
  @override
  String get cubitUserExists => 'User exists';
  @override
  String get cubitUserName => 'Cubit user name';
  @override
  String get cubitAvatar => 'Cubit avatar';
  @override
  String get debugInfoCollected => 'Debug info collected';
  @override
  String get debugFailed => 'Debug failed';
  @override
  String get cannotGetDebugInfo => 'Cannot get debug info';
  @override
  String get tryFix => 'Try Fix';
  @override
  String get fixAttempt => 'Attempt to fix user data issue';
  @override
  String get fixing => 'Fixing...';
  @override
  String get feedback => 'Feedback';

  // Chat page related
  @override
  String get unknownContact => 'Unknown Contact';

  @override
  String get inputMessage => 'Type a message...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get holdToSpeakButtonText => 'Hold to speak';

  @override
  String get releaseToFinish => 'Release to finish';

  @override
  String get sendingVoice => 'Sending voice...';

  @override
  String get fileUploadFailed => 'File upload failed';

  @override
  String get recordingTooShort => 'Recording too short';

  @override
  String get recordingFailed => 'Recording failed';

  @override
  String get voiceSendFailed => 'Voice sending failed';

  @override
  String get imageSendFailed => 'Image sending failed';

  @override
  String get fileSendFailed => 'File sending failed';

  @override
  String get debugStateFailed => 'Debug failed';

  @override
  String get cannotLocateMessage => 'Cannot locate message';

  @override
  String get messageTooLong =>
      'Message too long, please limit to 4000 characters';

  @override
  String get messageTooLongDetails =>
      'Message too long, please limit to 4000 characters';

  @override
  String get sendFailed => 'Send failed';

  @override
  String get recordingFailedPermission =>
      'Recording failed, please check microphone permission';

  @override
  String get videoRecordingComingSoon => 'Video recording feature coming soon';

  @override
  String get macOSGalleryTip => 'Will select image from gallery on macOS';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get imageSelectionFailed => 'Image selection failed';

  @override
  String get sendingImage => 'Sending image...';

  @override
  String get uploadingImage => 'Uploading image...';

  @override
  String get sendingFile => 'Sending file...';

  @override
  String get uploadingFile => 'Uploading file...';

  @override
  String get fileSelectionFailed => 'File selection failed';

  @override
  String get picture => 'Picture';

  @override
  String get shoot => 'Shoot';

  @override
  String get fileOption => 'File';

  @override
  String get contactOption => 'Contact';

  @override
  String get contactFeatureComingSoon => 'Contact feature coming soon...';

  @override
  String get recordVideo => 'Record Video';

  @override
  String get longPressToRecord =>
      'Long press the button below to start recording';

  @override
  String get recording => 'Recording...';

  @override
  String get longPressRecordVideo => 'Record Video';

  @override
  String get recordingInProgress => 'Recording...';

  @override
  String get longPressRecord => 'Long press to record';

  @override
  String get revokeFeatureComingSoon => 'Revoke feature coming soon';

  @override
  String get messageRevoked => 'Message revoked';

  @override
  String get revokeFailed => 'Revoke failed';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get messageExpiredCannotRevoke =>
      'Message sent more than 2 minutes ago, cannot revoke';

  @override
  String get networkErrorCannotRevoke => 'Network error, cannot revoke message';

  @override
  String get revokeMessage => 'Revoke Message';

  @override
  String get confirmRevokeMessage =>
      'Are you sure you want to revoke this message?';

  @override
  String get revokeTimeRemaining => 'Time remaining to revoke';

  @override
  String get revokeInstructions =>
      'After revoking, the other party will see "This message has been revoked"';

  @override
  String get revokingMessage => 'Revoking message...';

  @override
  String get deletingMessage => 'Deleting message...';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this message?';

  @override
  String get onlineStatus => 'Online';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get searchMessages => 'Search messages...';

  @override
  String get allEmojis => 'All Emojis';

  @override
  String get noMessagesInChat => 'No messages in this chat';

  @override
  String get jumpedToFirstMessage => 'Jumped to first message';

  @override
  String get jumpFailed => 'Jump failed, please try again';

  @override
  String get resendingMessage => 'Resending message...';

  @override
  String get jumpToLatestFailed =>
      'Jump to latest message failed, please try again';

  @override
  String get unreadNotInList =>
      'Unread messages not in current list, loading...';

  @override
  String get jumpToUnreadFailed => 'Jump failed, please try again';

  @override
  String get selectDate => 'Select Date';

  @override
  String get addImageCaption => 'Add image caption...';

  @override
  String get addFileCaption => 'Add file caption...';

  @override
  String get jumpToDate => 'Jump to Date';

  @override
  String get searching => 'Searching...';

  @override
  String get noMatchFound => 'No matches found';

  @override
  String get debugStateOutputToConsole => 'ChatState status output to console';

  @override
  String get noMessagesFoundOnDate => 'No messages found';

  @override
  String get send => 'Send';

  @override
  String get recordingMaxDuration => 'Recording reached maximum duration';

  @override
  String get recordingAutoSend =>
      'Recording reached maximum duration, auto-sending';

  // Message actions
  @override
  String get reply => 'Reply';

  @override
  String get forward => 'Forward';

  @override
  String get revoke => 'Revoke';

  @override
  String get deleteAction => 'Delete';

  @override
  String get nickname => 'Nickname';

  @override
  String get remark => 'Remark';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get syncRetrying => 'Retrying Sync';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registerInfo =>
      'Please fill in the information to complete registration';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get pleaseEnterNickname => 'Please enter nickname';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get alreadyHaveAccount => 'Already have an account? Back to login';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInfo =>
      'Please complete the following steps to reset your password';

  @override
  String get verifyPhone => 'Verify Phone Number';

  @override
  String get codeVerification => 'Code Verification';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get completeReset => 'Complete Reset';

  @override
  String get nextStep => 'Next';

  @override
  String get newPassword => 'New Password';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get pleaseEnterCorrectPhoneNumber =>
      'Please enter correct phone number';

  @override
  String get pleaseEnterVerificationCode => 'Please enter verification code';

  @override
  String get pleaseEnterNewPassword => 'Please enter new password';

  @override
  String get passwordLengthAtLeast6 => 'Password must be at least 6 characters';

  @override
  String get twoInputPasswordsNotMatch => 'The two passwords do not match';

  @override
  String get phoneVerificationInfo =>
      'We will send a verification code to your phone, please make sure to enter the correct phone number.';

  @override
  String get codeVerificationInfo =>
      'Please enter the verification code you received, the code is valid for 5 minutes.';

  @override
  String get newPasswordInfo =>
      'Please set a secure new password and remember it.';

  @override
  String get passwordResetSuccess => 'Password Reset Successful';

  @override
  String get passwordResetSuccessMessage =>
      'Your password has been successfully reset, please use the new password to login.';

  @override
  String get backToLogin => 'Back to Login';

  // Server switching related
  @override
  String get switchServer => 'Switch Server';

  @override
  String get cloudServer => 'Cloud Server';

  @override
  String get localServer => 'Local Server';
}
