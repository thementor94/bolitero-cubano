#!/usr/bin/env bash
set -e

echo "=== Configurando Android SDK y Compatibilidad ==="

# 1. Configurar app/build.gradle
if [ -f "android/app/build.gradle" ]; then
    sed -i 's/compileSdk = flutter.compileSdkVersion/compileSdk = 34/g' android/app/build.gradle || true
    sed -i 's/compileSdkVersion flutter.compileSdkVersion/compileSdkVersion 34/g' android/app/build.gradle || true
    sed -i 's/targetSdk = flutter.targetSdkVersion/targetSdk = 34/g' android/app/build.gradle || true
    sed -i 's/targetSdkVersion flutter.targetSdkVersion/targetSdkVersion 34/g' android/app/build.gradle || true
    sed -i 's/minSdkVersion = flutter.minSdkVersion/minSdkVersion = 21/g' android/app/build.gradle || true
    sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 21/g' android/app/build.gradle || true
fi

# 2. Inyectar configuración obligatoria a subproyectos en android/build.gradle
if [ -f "android/build.gradle" ]; then
    cat << 'EOF' >> android/build.gradle

subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                compileSdkVersion 34
                buildToolsVersion "34.0.0"
            }
        }
    }
}
EOF
fi

echo "=== android/build.gradle configurado ==="
if [ -f "android/build.gradle" ]; then
    tail -n 15 android/build.gradle
fi
