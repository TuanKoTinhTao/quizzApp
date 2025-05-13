plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.example.bookinghotel"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.bookinghotel"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.2"
    }
}

dependencies {
        implementation(platform(libs.androidx.compose.bom))

        // Core
        implementation(libs.androidx.core.ktx)
        implementation(libs.androidx.lifecycle.runtime.ktx)
        implementation(libs.androidx.activity.compose)

        // Compose
        implementation(libs.androidx.ui)
        implementation(libs.androidx.ui.tooling.preview)
        implementation(libs.androidx.material)
        implementation(libs.androidx.material3)
        implementation(libs.androidx.material.icons.extended)

        // AndroidX View system
        implementation(libs.androidx.appcompat)
        implementation(libs.material)
        implementation(libs.constraintlayout)

        // Testing
        testImplementation(libs.junit)
        androidTestImplementation(libs.androidx.junit)
        androidTestImplementation(libs.androidx.espresso.core)
        androidTestImplementation(libs.androidx.ui.test.junit4)

        // Debug
        debugImplementation(libs.androidx.ui.tooling)
        debugImplementation(libs.androidx.ui.test.manifest)
}