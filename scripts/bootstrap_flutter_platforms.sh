#!/usr/bin/env bash
set -euo pipefail
flutter create . --platforms=android,ios,web,macos,windows,linux
flutter pub get
printf '\nPlatform wrappers generated. Re-check Android native voice hooks before release.\n'
