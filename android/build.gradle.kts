import com.android.build.gradle.LibraryExtension

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

// Keep lint lightweight on plugin modules without breaking AAR packaging.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension> {
            lint {
                checkReleaseBuilds = false
                abortOnError = false
            }
        }
    }

    tasks.matching {
        it.name.contains("lint", ignoreCase = true)
    }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
