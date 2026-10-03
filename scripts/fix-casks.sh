#!/usr/bin/env bash
# GoReleaser writes the quarantine hook as a postflight block, which Homebrew rejects
# with Cask/InstallSteps. Rewrite it to postflight_steps.
set -euo pipefail

for cask in Casks/*.rb; do
  perl -0pi -e 's|  postflight do\n    if OS\.mac\?\n      system_command "/usr/bin/xattr",\n\s+args: \["-dr", "com\.apple\.quarantine", "#\{staged_path\}/([\w-]+)"\]\n    end\n  end\n|  postflight_steps do\n    on_macos do\n      run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{staged_path}}/$1"]\n    end\n  end\n|' "$cask"
done
