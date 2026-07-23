#!/bin/bash
# B1 setup: x86_64 Homebrew + wine build deps + CrossOver 26.2.0 sources
set -uxo pipefail
export NONINTERACTIVE=1 CI=1
cd "$HOME/b1"

echo "== step 1: x86_64 Homebrew =="
if ! /usr/local/bin/brew --version >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o brew-install.sh
  arch -x86_64 /bin/bash brew-install.sh || { echo "SETUP_FAIL=brew-install"; exit 1; }
fi
arch -x86_64 /usr/local/bin/brew --version

echo "== step 2: build deps (x86_64 bottles) =="
arch -x86_64 /usr/local/bin/brew install bison mingw-w64 llvm lld gettext pkgconf freetype gnutls molten-vk sdl2 || { echo "SETUP_FAIL=deps"; exit 1; }

echo "== step 3: CrossOver 26.2.0 sources =="
if [ ! -f crossover-sources-26.2.0.tar.gz ]; then
  curl -fL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -o crossover-sources-26.2.0.tar.gz \
    https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.2.0.tar.gz || { echo "SETUP_FAIL=sources"; exit 1; }
fi
ls -lh crossover-sources-26.2.0.tar.gz
if [ ! -d sources ]; then
  tar xf crossover-sources-26.2.0.tar.gz || { echo "SETUP_FAIL=extract"; exit 1; }
fi
ls sources/ | head
echo "SETUP_DONE"
