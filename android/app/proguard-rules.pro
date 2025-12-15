# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart VM Service Protocol
-keep class io.flutter.embedding.** { *; }

# Google Play Services / AdMob
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.ads.** { *; }

# AudioPlayers Plugin
-keep class xyz.luan.audioplayers.** { *; }

# Hive (Database)
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class io.flutter.embedding.engine.loader.FlutterLoader { *; }

# Share Plus Plugin
-keep class dev.fluttercommunity.plus.share.** { *; }

# Path Provider Plugin
-keep class io.flutter.plugins.pathprovider.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Device Info Plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JavaScript interfaces
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Crashlytics (if you add it later)
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}