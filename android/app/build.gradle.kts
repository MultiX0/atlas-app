import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}


plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.atlas_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    bundle {
        abi {
            enableSplit = true
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.atlas.manhwa.app"
        
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a")) // Ensure support for Android Go devices
        }
        
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }
    
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}



dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("com.google.firebase:firebase-bom:32.7.0")
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")

    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("com.github.awxkee:avif-coder:1.8.0")
}