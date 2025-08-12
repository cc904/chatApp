import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// 通过 Gradle 属性控制 ABI 拆分
// -PenableAbiSplits=true|false      是否启用 ABI 拆分（默认 true）
// -PabiInclude=arm64-v8a,armeabi-v7a 指定包含的 ABI（默认 arm64-v8a,armeabi-v7a）
// -PenableUniversalApk=true|false   是否生成通用 APK（默认 false）
val enableAbiSplits: Boolean = (project.findProperty("enableAbiSplits") as String?)?.toBoolean() ?: true
val abiIncludeList: List<String> = (project.findProperty("abiInclude") as String?)
    ?.split(",")
    ?.map { it.trim() }
    ?.filter { it.isNotEmpty() }
    ?: listOf("arm64-v8a", "armeabi-v7a")
val enableUniversalApk: Boolean = (project.findProperty("enableUniversalApk") as String?)?.toBoolean() ?: false

android {
    namespace = "com.xoxchat.cc"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // 启用核心库脱糖
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xoxchat.cc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // 设置为24以满足flutter_sound插件要求
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 仅在未启用 ABI 分包时限制 ABI，避免与 splits.abi 冲突
        if (!enableAbiSplits) {
            ndk {
                abiFilters += abiIncludeList
            }
        }
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = if (keystoreProperties["storeFile"] != null) {
                    file(keystoreProperties["storeFile"] as String)
                } else null
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            // 启用R8完整模式以获得更好的优化
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
    
    // APK分包配置 - 按ABI分包减小单个APK大小（可由属性开关控制）
    splits {
        abi {
            isEnable = enableAbiSplits
            reset()
            include(*abiIncludeList.toTypedArray())
            isUniversalApk = enableUniversalApk
        }
    }
    
    // 压缩配置
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module",
                "META-INF/versions/**",
                "kotlin/**",
                "DebugProbesKt.bin"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
    
    // 核心库脱糖支持
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
