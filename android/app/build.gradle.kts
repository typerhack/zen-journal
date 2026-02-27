import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun envOrProperty(properties: Properties, envKey: String, propertyKey: String): String? {
    return System.getenv(envKey) ?: properties.getProperty(propertyKey)
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val androidVersionCode = (System.getenv("ZEN_ANDROID_VERSION_CODE") ?: flutter.versionCode.toString()).toInt()
val androidVersionName = System.getenv("ZEN_ANDROID_VERSION_NAME") ?: flutter.versionName
val requireReleaseSigning = (System.getenv("ZEN_REQUIRE_RELEASE_SIGNING") ?: "false").toBoolean()

val releaseStoreFilePath = envOrProperty(keystoreProperties, "ZEN_ANDROID_KEYSTORE_PATH", "storeFile")
val releaseStorePassword = envOrProperty(keystoreProperties, "ZEN_ANDROID_STORE_PASSWORD", "storePassword")
val releaseKeyAlias = envOrProperty(keystoreProperties, "ZEN_ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = envOrProperty(keystoreProperties, "ZEN_ANDROID_KEY_PASSWORD", "keyPassword")

val hasReleaseSigning = !releaseStoreFilePath.isNullOrBlank() &&
    !releaseStorePassword.isNullOrBlank() &&
    !releaseKeyAlias.isNullOrBlank() &&
    !releaseKeyPassword.isNullOrBlank()

if (requireReleaseSigning && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is required, but Android signing credentials are missing. " +
            "Provide key.properties or ZEN_ANDROID_* environment variables."
    )
}

android {
    namespace = "com.zenjournal.zen_journal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.zenjournal.zen_journal"
        // Minimum 21 required for core library desugaring (flutter_local_notifications)
        minSdk = flutter.minSdkVersion  // flutter_local_notifications requires desugaring (minSdk ≥ 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = androidVersionCode
        versionName = androidVersionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Use real release signing when configured; otherwise keep local release builds possible.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for flutter_local_notifications (Java 8 time APIs on API < 26)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
