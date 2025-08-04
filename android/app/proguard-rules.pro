# Flutter相关保持规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 权限处理相关 - 重要修复
-keep class com.baseflow.permissionhandler.** { *; }
-keep interface com.baseflow.permissionhandler.** { *; }
-keep class androidx.core.app.ActivityCompat { *; }
-keep class androidx.core.content.ContextCompat { *; }
-keep class android.content.res.XmlBlock$Parser { *; }
-dontwarn com.baseflow.permissionhandler.**

# WebRTC相关
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class org.webrtc.** { *; }

# 音频相关
-keep class com.dooboolab.fluttersound.** { *; }
-keep class xyz.canardoux.fluttersound.** { *; }

# 通用保持规则
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# 避免混淆泛型
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 保持本地方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保持反射调用的类和方法
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 避免警告和缺失类
-dontwarn com.google.errorprone.annotations.**
-dontwarn java.lang.instrument.ClassFileTransformer
-dontwarn sun.misc.SignalHandler
-dontwarn com.google.android.play.core.**
-dontwarn androidx.window.**
-dontwarn androidx.activity.**

# Play Core 相关类的虚拟实现（避免R8错误）
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ========== APK大小优化规则 ==========

# 移除日志代码（Release版本）
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 移除调试相关代码
-assumenosideeffects class java.io.PrintStream {
    public void println(%);
    public void println(**);
}

# R8兼容的代码压缩
-allowaccessmodification
-repackageclasses ''

# 移除未使用的资源
-keepclassmembers class **.R$* {
    public static <fields>;
}

# 移除断言
-assumenosideeffects class * {
    boolean assert*(...);
}

# 保持必要的调试信息（R8推荐）
-keepattributes SourceFile,LineNumberTable

# R8优化配置
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*