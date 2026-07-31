pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // Android Gradle Plugin - Upgraded to minimum 8.11.1 as requested
    id("com.android.application") version "8.11.1" apply false

    // Kotlin - Upgraded to minimum 2.2.20 as requested
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false

    // Google Services
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
