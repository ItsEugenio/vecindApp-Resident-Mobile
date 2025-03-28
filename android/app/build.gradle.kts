plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ Firebase Google Services para FCM
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.vecindapp_residente"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.vecindapp_residente"
        minSdk = flutter.minSdkVersion
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

// ✅ Configuración correcta de dependencias en KTS
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.2.2")) // BOM de Firebase
    implementation("com.google.firebase:firebase-messaging:24.1.0") // Firebase Cloud Messaging
}


