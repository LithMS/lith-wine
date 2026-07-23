#!/bin/bash
# Assemble a self-contained Lith-Wine test bundle: our wine-cx build + full dylib closure
# (MoltenVK/freetype/gnutls + everything they pull in) + DXVK d3d9 + a run script.
# bash 3.2 compatible (no assoc arrays: dedup by checking the dest file).
set -uo pipefail
B1="$HOME/b1"
SRC="$B1/install/wine-cx26.2.0"
CX=/Applications/CrossOver.app/Contents/SharedSupport/CrossOver
OUT="$B1/bundle/lith-wine"
rm -rf "$B1/bundle"; mkdir -p "$OUT/wine" "$OUT/lib" "$OUT/dxvk"

echo "== copy wine =="
cp -R "$SRC/." "$OUT/wine/"

copy_closure() {
  local f base dep real
  f="$1"; [ -f "$f" ] || return
  base="$(basename "$f")"
  [ -f "$OUT/lib/$base" ] && return       # already copied -> dedup
  cp -L "$f" "$OUT/lib/$base" 2>/dev/null || return
  otool -L "$f" 2>/dev/null | awk 'NR>1{print $1}' \
    | grep -E "^(/usr/local/|/opt/homebrew/)" | while read -r dep; do
        real="$(python3 -c "import os,sys;print(os.path.realpath(sys.argv[1]))" "$dep" 2>/dev/null || echo "$dep")"
        copy_closure "$real"
      done
}

echo "== gather dylib closure =="
for root in \
    /usr/local/lib/libMoltenVK.dylib \
    /usr/local/opt/freetype/lib/libfreetype.6.dylib \
    /usr/local/opt/gnutls/lib/libgnutls.30.dylib ; do
  if [ -f "$root" ]; then copy_closure "$root"; else echo "  MISSING root: $root"; fi
done
echo "  libs collected: $(ls "$OUT/lib" | wc -l | tr -d ' ')"

echo "== DXVK d3d9 (x64, from proven retail CrossOver build; zlib-licensed) =="
if [ -f "$CX/lib/dxvk/x86_64-windows/d3d9.dll" ]; then
  cp "$CX/lib/dxvk/x86_64-windows/d3d9.dll" "$OUT/dxvk/d3d9.dll"; echo "  copied d3d9.dll"
else echo "  NO dxvk d3d9.dll"; fi
cp "$B1/sources/dxvk/LICENSE" "$OUT/dxvk/LICENSE" 2>/dev/null || true
ls -l "$OUT/dxvk"
echo "== bundle size =="; du -sh "$B1/bundle"

echo "== fix soname symlinks (install-name leaves that cp -L stored under realpath names) =="
for f in "$OUT"/lib/*.dylib; do
  otool -L "$f" 2>/dev/null | awk "NR>1{print \$1}" | grep -E "^(/usr/local/|/opt/homebrew/)" | while read -r dep; do
    leaf=$(basename "$dep")
    if [ ! -e "$OUT/lib/$leaf" ]; then
      stem=${leaf%.dylib}
      real=$(ls "$OUT/lib/${stem}".*.dylib 2>/dev/null | head -1)
      [ -z "$real" ] && real=$(ls "$OUT/lib/${stem%.*}".*.dylib 2>/dev/null | head -1)
      [ -n "$real" ] && ln -sf "$(basename "$real")" "$OUT/lib/$leaf" && echo "  linked $leaf -> $(basename "$real")"
    fi
  done
done
echo "== final closure check =="
bad=0
for f in "$OUT"/lib/*.dylib; do
  otool -L "$f" 2>/dev/null | awk "NR>1{print \$1}" | grep -E "^(/usr/local/|/opt/homebrew/)" | while read -r dep; do
    [ ! -e "$OUT/lib/$(basename "$dep")" ] && echo "  STILL MISSING: $(basename "$dep")"
  done
done
echo "  (no STILL MISSING lines = closure complete)"
echo "BUNDLE_DONE ($(du -sh "$B1/bundle" | cut -f1))"
