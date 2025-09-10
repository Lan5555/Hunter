plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be applied after the Android/Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
    // Google services plugin (for Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.hunter" // Change if needed
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.hunter" // Replace with your real app ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Needed if you hit 64K method limit
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Replace with release config in production
            isMinifyEnabled = false
            isShrinkResources = false
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
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // Firebase core services
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")

    // Google Sign-In (used by Firebase Auth for Google Sign-In)
    implementation("com.google.android.gms:play-services-auth:21.0.0")

    // Optional: Cloud Firestore or Realtime Database
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-database")

    // Optional: Firebase Cloud Messaging
    // implementation("com.google.firebase:firebase-messaging")

    // Optional: Firebase Storage
    // implementation("com.google.firebase:firebase-storage")
}
