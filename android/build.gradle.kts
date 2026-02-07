plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {

    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val project = this
    project.plugins.whenPluginAdded {
        if (this is com.android.build.gradle.AppPlugin || this is com.android.build.gradle.LibraryPlugin) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = if (project.name == "isar_flutter_libs") {
                    "dev.isar.isar_flutter_libs"
                } else {
                    "com.antigravity.period_tracker"
                }
            }
            // Configure compileSdk based on package
            if (project.name == "isar_flutter_libs") {
                android.compileSdkVersion(33)  // isar doesn't support lStar attribute in SDK 34+
            } else {
                android.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
