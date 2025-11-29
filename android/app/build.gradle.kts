import java.util.Properties
import java.io.FileInputStream

// Keystore properties ni yuklash
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.soundboard"  // O'zingizga mos o'zgartiring
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Signing konfiguratsiyasi
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.example.soundboard"  // O'zingizga mos o'zgartiring, UNIQUE bo'lishi kerak
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // Signing qo'shish
            signingConfig = signingConfigs.getByName("release")

            // Code shrinking va obfuscation
            isMinifyEnabled = false
            isShrinkResources = false

            // ProGuard fayllar
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
        }

        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Agar kerak bo'lsa dependencies qo'shasiz
}
