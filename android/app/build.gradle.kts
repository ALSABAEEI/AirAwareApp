plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

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

// ✅ Add AGConnect dependency
dependencies {
    implementation("com.huawei.agconnect:agconnect-core:1.5.2.300")
    // HMS Location SDK for native binding used by flutter_hms location plugin
    implementation("com.huawei.hms:location:6.12.0.300")
    // HMS Push SDK for Huawei Push Kit
    implementation("com.huawei.hms:push:6.12.0.300")
}

// ✅ Apply AGConnect plugin
apply(plugin = "com.huawei.agconnect")
