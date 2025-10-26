import org.gradle.api.file.Directory

// ✅ Add required Android Gradle plugin classpath here
buildscript {
    repositories {
        google()
        mavenCentral()
        // Huawei Maven repo
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
    dependencies {
        // Android Gradle plugin (required by Flutter)
        classpath("com.android.tools.build:gradle:8.3.0")
        // Huawei AGConnect plugin
        classpath("com.huawei.agconnect:agcp:1.5.2.300")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Huawei Maven repo
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
}

// ✅ Flutter custom build directory settings (keep this part)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
