import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val isReleaseRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (isReleaseRequested && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Missing android/key.properties. Create it to build a release. " +
            "See tool/release_android.sh and the Android release prompt.",
    )
}

android {
    namespace = "com.forevernewvie.projectgtg"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (and other Android libs) when using Java 8+ APIs.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.forevernewvie.projectgtg"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFilePath = keystoreProperties.getProperty("storeFile")?.trim().orEmpty()
                val storePasswordValue = keystoreProperties.getProperty("storePassword")?.trim().orEmpty()
                val keyAliasValue = keystoreProperties.getProperty("keyAlias")?.trim().orEmpty()
                val keyPasswordValue = keystoreProperties.getProperty("keyPassword")?.trim().orEmpty()

                if (storeFilePath.isBlank() ||
                    storePasswordValue.isBlank() ||
                    keyAliasValue.isBlank() ||
                    keyPasswordValue.isBlank()
                ) {
                    throw GradleException(
                        "android/key.properties is missing required fields. " +
                            "Expected: storeFile, storePassword, keyAlias, keyPassword.",
                    )
                }

                storeFile = file(storeFilePath)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            // Signed via android/key.properties (gitignored). Release builds must fail if missing.
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
