plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.example.nexo_staff_purchase"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    signingConfigs {
        create("release") {
            keyAlias = "release"
            keyPassword = "Legroom4-Yummy7-Qualifier4-Skyrocket9-Railing9"
            storeFile = file("nexo-pizza-staff-purchase-app-release-key.jks")
            storePassword = "Legroom4-Yummy7-Qualifier4-Skyrocket9-Railing9"
        }
        // FIX: Changed from 'create' to 'getByName' because debug config already exists
        getByName("debug") {
            keyAlias = "debug"
            keyPassword = "Husband7-Domain5-Recoil4-Happening1-Dweeb5"
            storeFile = file("nexo-pizza-staff-purchase-app-debug-key.jks")
            storePassword = "Husband7-Domain5-Recoil4-Happening1-Dweeb5"
        }
    }

    buildTypes {
        getByName("release") {
            // This connects the release config to the build
            signingConfig = signingConfigs.getByName("release")

            // Standard optimization settings
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nexopizza.staffpurchase"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}