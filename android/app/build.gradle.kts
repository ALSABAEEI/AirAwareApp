plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Apply Huawei AGConnect plugin
apply(plugin = "com.huawei.agconnect")

android {
    namespace = "com.example.airawareapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.airawareapp"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ✅ Enable ProGuard for release builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Huawei Mobile Services (HMS) dependencies
    // Use older version that doesn't require UCS credential
    implementation("com.huawei.hms:location:6.9.0.300")
    implementation("com.huawei.agconnect:agconnect-core:1.9.1.301")
    
    // HMS Core SDK for device capability detection
    implementation("com.huawei.hms:base:6.11.0.301")
}
