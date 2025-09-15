plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
id("com.google.gms.google-services") }



android {
    namespace = "com.example.gemini_gpt"
    compileSdk = 35 // Replace flutter.compileSdkVersion if undefined

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
        minSdk = 24
        targetSdk = 35 // Replace flutter.targetSdkVersion if undefined
        versionCode = 1 // Replace flutter.versionCode if undefined
        versionName = "1.0" // Replace flutter.versionName if undefined
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Kotlin DSL syntax: use double quotes and parentheses
   implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
