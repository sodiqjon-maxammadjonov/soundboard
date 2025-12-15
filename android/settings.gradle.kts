pluginManagement {
    val flutterSdkPath: String = run {
        val properties = java.util.Properties()
        java.io.FileInputStream(file("local.properties")).use {
            properties.load(it)
        }
        properties.getProperty("flutter.sdk") ?:
        throw GradleException("flutter.sdk not set in local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
}

include(":app")