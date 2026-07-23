#!/bin/bash
# B1 acceptance: run Lith client under the from-source wine-cx build, fresh prefix.
# PASS = agarcium hooks + CreateWindowExA [LoadingDialog], no blank OK box (3D-device death is expected on this VM).
set -uxo pipefail
B1="$HOME/b1"
WINEROOT="$B1/install/wine-cx26.2.0"
WINE="$WINEROOT/bin/wineloader"
export WINEPREFIX="${WINEPREFIX:-$B1/prefix}"
export WINEDEBUG="${WINEDEBUG:-+seh,err+all,fixme-all}"
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-}"
CLIENT="$HOME/LithClient"
LOG="$B1/game.log"

[ -x "$WINE" ] || { echo "wine binary missing: $WINE"; ls "$WINEROOT/bin" 2>/dev/null; exit 1; }
file "$WINE" "$WINEROOT/bin/wineserver" 2>/dev/null || true

# fresh prefix on request
[ "${FRESH:-0}" = "1" ] && rm -rf "$WINEPREFIX"
mkdir -p "$WINEPREFIX"

cd "$CLIENT/x64" || exit 1
rm -f agarcium.log
auid=$(id -u admin)
: > "$LOG"
echo "launching under $WINE (prefix $WINEPREFIX), log $LOG"
sudo launchctl asuser "$auid" sudo -u admin env \
  WINEPREFIX="$WINEPREFIX" WINEDEBUG="$WINEDEBUG" WINEDLLOVERRIDES="$WINEDLLOVERRIDES" \
  "$WINE" "$CLIENT/x64/MapleStory2.exe" --nxapp=nxl --ip=play.lith.cat --title=Lith --port=20001 \
  >> "$LOG" 2>&1 &
echo "dispatched host pid $!"
