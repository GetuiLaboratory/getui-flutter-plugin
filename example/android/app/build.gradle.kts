plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ent.com.getui.getuiflut_example"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ent.com.getui.getuiflut_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0"
        manifestPlaceholders.putAll(mapOf(
            "GETUI_APPID" to "djYjSlFVMf6p5YOy2OQUs8",
            "GETUI_APP_ID" to "djYjSlFVMf6p5YOy2OQUs8",
            "XIAOMI_APP_ID" to "",
            "XIAOMI_APP_KEY" to "",
            "MEIZU_APP_ID" to "",
            "MEIZU_APP_KEY" to "",
            "HUAWEI_APP_ID" to "",
            "OPPO_APP_KEY" to "",
            "OPPO_APP_SECRET" to "",
            "VIVO_APP_ID" to "",
            "VIVO_APP_KEY" to ""
        ))

    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("com.getui:gtsdk:3.3.12.0") // 修复：使用 () 和双引号
    implementation("com.getui:gtc:3.2.18.0")  // 修复：使用 () 和双引号

}