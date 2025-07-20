import 'app_localizations.dart';

/// 中文本地化实现
class AppLocalizationsZh extends AppLocalizations {
  @override
  String get appName => 'ThisApp';

  // 按钮文本
  @override
  String get cancel => '取消';
  @override
  String get confirm => '确认';

  @override
  String get imageLoadFailed => '图片加载失败';

  @override
  String get sendFile => '发送文件';
  @override
  String get save => '保存';
  @override
  String get delete => '删除';
  @override
  String get edit => '编辑';
  @override
  String get done => '完成';

  // 错误消息
  @override
  String get errorOccurred => '发生错误';
  @override
  String get networkError => '网络错误';
  @override
  String get unknownError => '未知错误';

  // 认证相关
  @override
  String get login => '登录';
  @override
  String get register => '注册';
  @override
  String get logout => '退出登录';
  @override
  String get username => '用户名';
  @override
  String get password => '密码';
  @override
  String get forgotPassword => '忘记密码';
  @override
  String get quickLogin => '快捷登录';
  @override
  String get passwordLogin => '密码登录';
  @override
  String get verificationCode => '验证码';
  @override
  String get enterVerificationCode => '请输入验证码';
  @override
  String get getVerificationCode => '获取验证码';
  @override
  String get sending => '发送中...';
  @override
  String get resend => '重新发送';

  // 聊天相关
  @override
  String get newMessage => '新消息';
  @override
  String get typing => '正在输入...';
  @override
  String get online => '在线';
  @override
  String get offline => '离线';
  @override
  String get lastSeen => '最后在线';
  @override
  String get sendMessage => '发送消息';
  @override
  String get attachment => '附件';
  @override
  String get camera => '相机';
  @override
  String get gallery => '相册';
  @override
  String get audio => '语音';
  @override
  String get file => '文件';
  @override
  String get location => '位置';
  @override
  String get contact => '联系人';
  @override
  String get chats => '聊天';
  @override
  String get allChats => '全部';
  @override
  String get privateChats => '私密';
  @override
  String get groupChats => '群组';
  @override
  String get channelChats => '频道';
  @override
  String get unreadChats => '未读';
  @override
  String get search => '搜索';
  @override
  String get searchButton => '搜索';
  @override
  String get noChats => '没有会话';
  @override
  String get noMatchingChats => '没有找到匹配的会话';

  // 设置相关
  @override
  String get settings => '设置';
  @override
  String get profile => '个人资料';
  @override
  String get privacy => '隐私';
  @override
  String get notifications => '通知';
  @override
  String get language => '语言';
  @override
  String get theme => '主题';
  @override
  String get darkMode => '深色模式';
  @override
  String get lightMode => '浅色模式';
  @override
  String get systemMode => '跟随系统';

  // 群组相关
  @override
  String get createGroup => '创建群组';
  @override
  String get addMembers => '添加成员';
  @override
  String get removeMembers => '移除成员';
  @override
  String get leaveGroup => '退出群组';
  @override
  String get deleteGroup => '删除群组';

  // 角色相关
  @override
  String get owner => '群主';
  @override
  String get admin => '管理员';
  @override
  String get member => '成员';

  // 描述相关
  @override
  String get description => '描述';

  // 操作相关
  @override
  String get block => '屏蔽';
  @override
  String get remove => '移除';
  @override
  String get editContact => '编辑联系人';
  @override
  String get report => '举报';
  @override
  String get clearChatHistory => '清空聊天记录';

  // 功能开发提示
  @override
  String get featureInDevelopment => '功能暂未开放';
  @override
  String get voiceCallInDevelopment => '功能暂未开放';
  @override
  String get videoCallInDevelopment => '功能暂未开放';
  @override
  String get blockUserInDevelopment => '功能暂未开放';
  @override
  String get clearChatInDevelopment => '功能暂未开放';
  @override
  String get featureNotAvailable => '该功能暂未开放\n敬请期待';
  @override
  String get pleaseStayTuned => '敬请期待更新';

  // 成员管理
  @override
  String get removeMember => '移除成员';
  @override
  String get blockMember => '屏蔽成员';
  @override
  String confirmRemoveMember(String name) => '确定要将 $name 从群组中移除吗？';
  @override
  String confirmBlockMember(String name) => '确定要屏蔽 $name 吗？屏蔽后该成员将无法发送消息。';
  @override
  String get toggleAdminRole => '设为管理员';
  @override
  String get removeAdminRole => '取消管理员';
  @override
  String get setAsAdmin => '设为管理员';
  @override
  String confirmRemoveAdminRole(String name) => '确定要取消 $name 的管理员权限吗？';
  @override
  String confirmSetAsAdmin(String name) => '确定要将 $name 设为管理员吗？管理员可以管理群成员和群设置。';
  @override
  String get adminCanManageMembers => '管理员可以管理群成员和群设置';
  @override
  String memberRemoved(String name) => '已移除 $name';
  @override
  String memberBlocked(String name) => '已屏蔽 $name';
  @override
  String get adminRoleUpdated => '管理员权限已更新';
  @override
  String removeAdminRoleSuccess(String name) => '已取消 $name 的管理员权限';
  @override
  String setAsAdminSuccess(String name) => '已将 $name 设为管理员';
  @override
  String get operationFailed => '操作失败';
  @override
  String blockMemberFailed(String error) => '屏蔽成员失败：$error';
  @override
  String get toggleAdminFailed => '管理员权限切换失败';

  // 联系人相关
  @override
  String get contacts => '联系人';
  @override
  String get addContact => '添加联系人';
  @override
  String get removeContact => '删除联系人';
  @override
  String get blockContact => '拉黑联系人';
  @override
  String get unblockContact => '取消拉黑';

  // 媒体相关
  @override
  String get photos => '照片';
  @override
  String get videos => '视频';
  @override
  String get documents => '文档';
  @override
  String get links => '链接';
  @override
  String get voice => '语音';

  // 时间相关
  @override
  String get today => '今天';
  @override
  String get yesterday => '昨天';
  @override
  String get justNow => '刚刚';

  // 自定义消息
  @override
  String get cannotCreatePrivateChat => '不能与自己创建私聊';
  @override
  String get failedToCreateChat => '无法创建私聊会话';
  @override
  String get failedToGetConversation => '无法获取会话信息';
  @override
  String get failedToOpenChat => '打开私聊失败';

  // 聊天信息页面
  @override
  String get back => '返回';
  @override
  String get chatCancel => '取消';
  @override
  String get chatDone => '完成';
  @override
  String get call => '通话';
  @override
  String get video => '视频';
  @override
  String get mute => '静音';
  @override
  String get unmute => '取消静音';
  @override
  String get more => '更多';
  @override
  String get less => '收起';
  @override
  String get leave => '退出';
  @override
  String get chatAddMembers => '添加成员';
  @override
  String get deleteContact => '删除联系人';
  @override
  String get confirmDeleteContact => '删除后,将不再接收此联系人的消息';
  @override
  String get chatLeaveGroup => '删除并退出';
  @override
  String get confirmLeaveGroup => '退出后,将不再接收此群聊信息';
  @override
  String get leaveChannel => '退出频道';
  @override
  String get confirmLeaveChannel => '退出后,将不再接收此频道信息';
  @override
  String get members => '成员';
  @override
  String get media => '媒体';
  @override
  String get files => '文件';
  @override
  String get music => '音乐';
  @override
  String get chatVoice => '语音';
  @override
  String get chatLinks => '链接';
  @override
  String get noMedia => '暂无媒体文件';
  @override
  String get noFiles => '暂无文件';
  @override
  String get noMusic => '暂无音乐文件';
  @override
  String get noVoice => '暂无语音消息';
  @override
  String get noLinks => '暂无链接';
  @override
  String get userId => '用户ID';
  @override
  String get groupId => '群组ID';
  @override
  String get channelId => '频道ID';
  @override
  String get userIdCopied => '已复制用户ID';
  @override
  String get groupIdCopied => '已复制群组ID';
  @override
  String get channelIdCopied => '已复制频道ID';

  // 通用操作
  @override
  String get copy => '复制';
  @override
  String get qrCodeCopied => '二维码数据已复制';

  // 新建对话底部弹窗
  @override
  String get newGroup => '新建群组';
  @override
  String get newChannel => '新建频道';
  @override
  String get next => '下一步';
  @override
  String get whoToAdd => '你想添加谁？';
  @override
  String get selected => '已选择';

  // 联系人页面
  @override
  String get searchContacts => '搜索';
  @override
  String get serverConnectionError => '无法连接服务器';
  @override
  String get retry => '重试';
  @override
  String cannotOpenChatWith(String name) => '无法打开与$name的聊天';

  // 语言设置
  @override
  String get languageSwitched => '语言已切换，重启应用后生效';
  @override
  String get languageSwitchFailed => '切换语言失败';

  // 频道信息页面
  @override
  String get channelTitle => '频道';
  @override
  String get channelMembers => '成员';
  @override
  String get channelViews => '浏览量';
  @override
  String get whatIsChannel => '什么是频道？';
  @override
  String get channelDescription => '频道是一种一对多的工具\n用于向无限受众广播您的消息。';
  @override
  String get createChannel => '创建频道';
  @override
  String get joinChannel => '加入频道';
  @override
  String get channelMemberCannotSend => '只有管理员和频道拥有者才能发送消息';

  // Profile 页面相关
  @override
  String get myProfile => '我的';
  @override
  String get loadingUserInfo => '加载用户信息中...';
  @override
  String get loadFailed => '加载失败';
  @override
  String get refreshProfile => '刷新';
  @override
  String get phoneNumber => '手机号';
  @override
  String get phoneNotBound => '未绑定';
  @override
  String get myQRCode => '我的二维码';
  @override
  String get accountSecurity => '账号与安全';
  @override
  String get privacySettings => '隐私设置';
  @override
  String get notificationSettings => '通知设置';
  @override
  String get aboutUs => '关于我们';
  @override
  String get confirmLogout => '退出登录';
  @override
  String get confirmLogoutMessage => '确定要退出登录吗？';
  @override
  String get logoutFailed => '登出过程中发生错误';
  @override
  String get refreshUserInfo => '刷新用户信息';

  // 开发者选项
  @override
  String get developerOptions => '开发者选项';
  @override
  String get viewUserInfo => '查看用户信息';
  @override
  String get debugDatabaseStatus => '调试数据库状态';
  @override
  String get tokenStatusDiagnosis => 'Token状态诊断';
  @override
  String get resetData => '重置数据';
  @override
  String get refreshToken => '刷新令牌';
  @override
  String get serverSettings => '服务器设置';
  @override
  String get currentUserInfo => '当前用户信息';
  @override
  String get noUserInfoLoaded => '用户信息未加载';
  @override
  String get close => '关闭';
  @override
  String get currentServer => '当前服务器';
  @override
  String get availableServers => '可用服务器列表';
  @override
  String get switchTo => '切换';
  @override
  String get reset => '重置';
  @override
  String get resetToMainServer => '已重置到主服务器';
  @override
  String get autoFailover => '连接失败时会自动尝试备用服务器';
  @override
  String get tokenRefreshTest => 'Token刷新测试';
  @override
  String get tokenTestDescription => '测试当前的Token状态和刷新功能';
  @override
  String get testTokenStatus => '正在测试Token状态...';
  @override
  String get testResults => 'Token测试结果';
  @override
  String get manualRefreshTest => '手动刷新';
  @override
  String get testFailed => '测试失败';
  @override
  String get testSuccess => '测试';
  @override
  String get resetDataWarning => '这将清除所有数据,包括联系人、会话和消息。\n\n此操作不可撤销,确定要继续吗？';
  @override
  String get confirmReset => '确定重置';
  @override
  String get dataResetComplete => '数据已重置';
  @override
  String get dataResetCompleteMessage => '所有数据已清除。为确保重置生效,应用需要重启。';
  @override
  String get exitNow => '立即退出';
  @override
  String get resetDataFailed => '重置数据失败';
  @override
  String get userInfoDiagnosis => '诊断用户信息';
  @override
  String get diagnosisComplete => '用户信息诊断完成，请查看控制台日志';
  @override
  String get diagnosisFailed => '用户信息诊断失败';
  @override
  String get messageSort => '测试消息排序';
  @override
  String get messageSortTest => '正在测试消息排序...';
  @override
  String get conversationSyncManagement => '会话同步管理';
  @override
  String get syncStatusInfo => '同步状态信息：';
  @override
  String get lastSyncTime => '上次同步时间：';
  @override
  String get neverSynced => '尚未进行过同步';
  @override
  String get operationOptions => '操作选项：';
  @override
  String get incrementalSync => '增量同步';
  @override
  String get incrementalSyncDesc => '• 增量同步：只获取自上次同步以来的更新';
  @override
  String get fullSync => '全量同步';
  @override
  String get fullSyncDesc => '• 全量同步：获取所有会话数据';
  @override
  String get clearSyncRecord => '清除记录';
  @override
  String get clearSyncRecordDesc => '• 清除记录：清除同步时间，下次将全量同步';
  @override
  String get performingIncrementalSync => '正在执行增量同步...';
  @override
  String get performingFullSync => '正在执行全量同步...';
  @override
  String get incrementalSyncTriggered => '增量同步已触发，请查看会话列表更新';
  @override
  String get fullSyncTriggered => '全量同步已触发，请查看会话列表更新';
  @override
  String get syncTimeClearSuccess => '同步时间记录已清除，下次同步将执行全量同步';
  @override
  String get clearSyncTimeFailed => '清除失败';
  @override
  String get fixUserDataIssue => '尝试修复';
  @override
  String get fixingUserData => '正在尝试修复...';
  @override
  String get userDataFixSuccess => '用户信息修复成功，请查看页面更新';
  @override
  String get userDataFixFailed => '修复失败：没有找到有效的用户信息';
  @override
  String get noValidUserInfo => '修复失败';
  @override
  String get databaseDebugInfo => '数据库调试信息';
  @override
  String get databaseInitialized => '数据库初始化';
  @override
  String get databaseUserExists => '数据库用户存在';
  @override
  String get userInfoInDatabase => '数据库中的用户信息:';
  @override
  String get noDatabaseUserRecord => '数据库中没有用户记录！\n这可能是登录后用户信息没有正确保存的原因。';
  @override
  String get secureStorageInfo => '安全存储信息:';
  @override
  String get storedToken => '存储Token';
  @override
  String get refreshedToken => '刷新Token';
  @override
  String get autoRefresh => '自动刷新';
  @override
  String get tokenPrefix => 'Token前缀';
  @override
  String get profileCubitStatus => 'ProfileCubit状态:';
  @override
  String get cubitStatus => '状态';
  @override
  String get cubitUserExists => '用户存在';
  @override
  String get cubitUserName => 'Cubit用户名';
  @override
  String get cubitAvatar => 'Cubit头像';
  @override
  String get debugInfoCollected => '调试信息收集完成';
  @override
  String get debugFailed => '调试失败';
  @override
  String get cannotGetDebugInfo => '无法获取调试信息';
  @override
  String get tryFix => '尝试修复';
  @override
  String get fixAttempt => '尝试修复用户数据问题';
  @override
  String get fixing => '正在尝试修复...';
  @override
  String get feedback => '反馈建议';

  // Chat页面相关
  @override
  String get unknownContact => '未知联系人';

  @override
  String get inputMessage => '输入消息...';

  @override
  String get connecting => '连接中...';

  @override
  String get holdToSpeakButtonText => '按住 说话';

  @override
  String get releaseToFinish => '松开结束';

  @override
  String get sendingVoice => '正在发送语音...';

  @override
  String get fileUploadFailed => '文件上传失败';

  @override
  String get recordingTooShort => '录音时间太短';

  @override
  String get recordingFailed => '录音失败';

  @override
  String get voiceSendFailed => '语音发送失败';

  @override
  String get imageSendFailed => '图片发送失败';

  @override
  String get fileSendFailed => '文件发送失败';

  @override
  String get debugStateFailed => '调试失败';

  @override
  String get cannotLocateMessage => '无法定位到该消息';

  @override
  String get messageTooLong => '消息内容过长，请控制在4000字符以内';

  @override
  String get messageTooLongDetails => '消息内容过长，请控制在4000字符以内';

  @override
  String get sendFailed => '发送失败';

  @override
  String get recordingFailedPermission => '录音失败，请检查麦克风权限';

  @override
  String get permissionRequired => '需要权限';

  @override
  String get permissionGrantedRetry => '麦克风权限已开启，请重新长按录音按钮开始录音';

  @override
  String get microphonePermissionMessage => '需要麦克风权限才能录制语音消息。请到设置中开启麦克风权限。';

  @override
  String get goToSettings => '去设置';

  @override
  String get videoRecordingComingSoon => '功能暂未开放';

  @override
  String get macOSGalleryTip => 'macOS平台将从相册选择图片';

  @override
  String get selectFromGallery => '从相册选择';

  @override
  String get takePhoto => '拍照';

  @override
  String get imageSelectionFailed => '图片选择失败';

  @override
  String get sendingImage => '正在发送图片...';

  @override
  String get uploadingImage => '正在上传图片...';

  @override
  String get sendingFile => '正在发送文件...';

  @override
  String get uploadingFile => '正在上传文件...';

  @override
  String get fileSelectionFailed => '文件选择失败';

  @override
  String get picture => '图片';

  @override
  String get shoot => '拍摄';

  @override
  String get fileOption => '文件';

  @override
  String get contactOption => '联系人';

  @override
  String get contactFeatureComingSoon => '功能暂未开放';

  @override
  String get recordVideo => '录制视频';

  @override
  String get longPressToRecord => '长按下方按钮开始录制视频';

  @override
  String get recording => '正在录制...';

  @override
  String get longPressRecordVideo => '录制视频';

  @override
  String get recordingInProgress => '正在录音...';

  @override
  String get longPressRecord => '长按录制';

  @override
  String get revokeFeatureComingSoon => '撤回功能待实现';

  @override
  String get messageRevoked => '消息已撤回';

  @override
  String get revokeFailed => '撤回失败';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get messageExpiredCannotRevoke => '消息发送已超过2分钟，无法撤回';

  @override
  String get networkErrorCannotRevoke => '网络连接异常，无法撤回消息';

  @override
  String get revokeMessage => '撤回消息';

  @override
  String get confirmRevokeMessage => '确定要撤回这条消息吗？';

  @override
  String get revokeTimeRemaining => '剩余撤回时间';

  @override
  String get revokeInstructions => '撤回后，对方将看到"此消息已被撤回"';

  @override
  String get revokingMessage => '正在撤回消息...';

  @override
  String get deletingMessage => '正在删除消息...';

  @override
  String get messageDeleted => '消息已删除';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get deleteMessage => '删除消息';

  @override
  String get confirmDeleteMessage => '确定要删除这条消息吗？';

  @override
  String get onlineStatus => '在线';

  @override
  String get offlineStatus => '离线';

  @override
  String get searchMessages => '搜索消息...';

  @override
  String get allEmojis => '所有表情';

  @override
  String get noMessagesInChat => '当前会话暂无消息';

  @override
  String get jumpedToFirstMessage => '已跳转到第一条消息';

  @override
  String get jumpFailed => '跳转失败，请重试';

  @override
  String get resendingMessage => '正在重发消息...';

  @override
  String get jumpToLatestFailed => '跳转到最新消息失败，请重试';

  @override
  String get unreadNotInList => '未读消息不在当前列表中，正在加载...';

  @override
  String get jumpToUnreadFailed => '跳转失败，请重试';

  @override
  String get selectDate => '选择日期';

  @override
  String get addImageCaption => '添加图片说明...';

  @override
  String get addFileCaption => '添加文件说明...';

  @override
  String get jumpToDate => '跳转到日期';

  @override
  String get searching => '搜索中...';

  @override
  String get noMatchFound => '无匹配结果';

  @override
  String get debugStateOutputToConsole => 'ChatState状态已输出到控制台';

  @override
  String get noMessagesFoundOnDate => '没有找到消息';

  @override
  String get send => '发送';

  @override
  String get recordingMaxDuration => '录音达到最大时长';

  @override
  String get recordingAutoSend => '录音已达到最大时长，自动发送';

  // 消息操作
  @override
  String get reply => '回复';

  @override
  String get forward => '转发';

  @override
  String get revoke => '撤回';

  @override
  String get deleteAction => '删除';

  @override
  String get nickname => '昵称';

  @override
  String get remark => '备注';

  @override
  String get syncFailed => '同步失败';

  @override
  String get syncRetrying => '正在重试同步';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get registerInfo => '请填写以下信息完成注册';

  @override
  String get passwordLength => '密码长度至少6位';

  @override
  String get passwordMismatch => '两次输入的密码不一致';

  @override
  String get passwordTooShort => '密码长度至少6位';

  @override
  String get pleaseEnterNickname => '请输入昵称';

  @override
  String get registerSuccess => '注册成功';

  @override
  String get alreadyHaveAccount => '已有账号？返回登录';

  @override
  String get resetPassword => '重置密码';

  @override
  String get resetPasswordInfo => '请完成以下步骤重置您的密码';

  @override
  String get verifyPhone => '验证手机号';

  @override
  String get codeVerification => '验证码验证';

  @override
  String get setNewPassword => '设置新密码';

  @override
  String get completeReset => '完成重置';

  @override
  String get nextStep => '下一步';

  @override
  String get newPassword => '新密码';

  @override
  String get pleaseEnterPhoneNumber => '请输入手机号码';

  @override
  String get pleaseEnterCorrectPhoneNumber => '请输入正确的手机号码';

  @override
  String get pleaseEnterVerificationCode => '请输入验证码';

  @override
  String get pleaseEnterNewPassword => '请输入新密码';

  @override
  String get passwordLengthAtLeast6 => '密码长度至少6位';

  @override
  String get twoInputPasswordsNotMatch => '两次输入的密码不一致';

  @override
  String get phoneVerificationInfo => '我们将向您的手机发送验证码,请确保输入正确的手机号。';

  @override
  String get codeVerificationInfo => '请输入您收到的验证码,验证码有效期为5分钟。';

  @override
  String get newPasswordInfo => '请设置一个安全的新密码,并牢记您的密码。';

  @override
  String get passwordResetSuccess => '密码重置成功';

  @override
  String get passwordResetSuccessMessage => '您的密码已成功重置,请使用新密码登录。';

  @override
  String get backToLogin => '返回登录';

  // 服务器切换相关
  @override
  String get switchServer => '切换服务器';

  @override
  String get cloudServer => '云端服务器';

  @override
  String get localServer => '本地服务器';
}
