plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// dependencies {
//     classpath 'com.google.gms:google-services:4.3.15' 
//          classpath 'com.android.tools.build:gradle:8.3.2'
//         classpath 'com.google.gms:google-services:4.3.15'
// }
android {
    namespace = "com.example.gemini_gpt"
    compileSdk = flutter.compileSdkVersion

    // Force correct NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.gemini_gpt"
        minSdk =  24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
