# lith-wine

Build recipe and source-availability record for the **Wine runtime that the Lith launcher bundles
on macOS**, so Lith can run MapleStory 2 without the user installing CrossOver.

This repository exists to satisfy the **LGPL** obligations that attach when we redistribute compiled
Wine binaries (and their LGPL dependency libraries) in the public `LithMS/Lith-Artifacts` releases.
It is the "complete corresponding source + build instructions" offer for those binaries. See
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the per-component license and upstream-source
list.

> The Lith launcher itself is a separate program that only *invokes* Wine as a subprocess (the same
> way it invokes `umu-run` on Linux). It is not a derivative work of Wine and is not covered by this
> repository.

## What we build

Wine, compiled from **CodeWeavers' published CrossOver sources** (LGPL). CrossOver-lineage Wine is
what clears the client's WinLicense/Themida anti-tamper — vanilla/Gcenx wine-staging does not. There
is no longer any prebuilt CrossOver-lineage Wine to download (Gcenx's wine-crossover is unpublished,
WhiskyWine 404s, Kegworks/Sikarugir engines stop at CrossOver 21), so we build it ourselves.

- **CrossOver source version:** `26.2.0`
- **Source URL:** `https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.2.0.tar.gz`
  (CodeWeavers rotates old versions off their server; a mirror of the exact tarball we built from is
  kept with each Lith-Artifacts release that ships this runtime.)
- **Target:** `x86_64` (runs under Rosetta 2 on Apple Silicon; the game client is x64 and Agarcium's
  MinHook is x86/x64-only — never build ARM64).
- **Recipe origin:** adapted from
  [`neptuwunium/wine-cx-build`](https://github.com/neptuwunium/wine-cx-build), itself derived from
  the now-deleted `Gcenx/crossover-wine-ci`.

## Repository layout

| Path | What |
|---|---|
| `scripts/setup.sh` | Provisions the build host: x86_64 Homebrew (`/usr/local`, under Rosetta), Wine build deps, and downloads + extracts the CrossOver sources. |
| `scripts/build.sh` | `configure` + `make` + `make install-image` → `wine-cx26.2.0/`. The exact flags used. |
| `scripts/distversion.h` | Stub that stands in for the CodeWeavers-generated `programs/winedbg/distversion.h` (not present in the LGPL source drop). |
| `scripts/mkbundle.sh` | Assembles the shippable runtime: the Wine build + the full macOS dylib closure it `dlopen`s (MoltenVK / freetype / gnutls + transitive deps) + a DXVK `d3d9.dll`, with soname symlink fixups and a closure-completeness check. This is B3 packaging R&D, kept here because it defines what actually gets redistributed. |
| `scripts/accept.sh` | Acceptance test: launches the client under the built Wine and checks for the WinLicense-pass signature. |

## Build (on an Apple Silicon Mac with Xcode Command Line Tools)

```bash
export LITH_WINE_WORK="$HOME/b1"          # working dir the scripts use (see note below)
bash scripts/setup.sh                     # x86_64 brew + deps + CrossOver sources  (~20 min)
bash scripts/build.sh                     # configure + make -j + install-image      (long, Rosetta)
bash scripts/mkbundle.sh                  # assemble the redistributable bundle + dylib closure
```

> **Path note:** the scripts as committed use a hardcoded `~/b1` working directory (the exact paths
> from the machine they were proven on). They are preserved verbatim as the record of what was built.
> Adjust the `B1=`/`OUT=` lines at the top if you build elsewhere.

Prerequisites installed by `setup.sh`: `bison mingw-w64 llvm lld gettext pkgconf freetype gnutls
molten-vk sdl2` (x86_64 bottles). Rosetta 2 must be present (`softwareupdate --install-rosetta`).

## Acceptance status

The `26.2.0` build **passes WinLicense** on the acceptance test: Agarcium loads fully
(`MinHook initialized` → `win::Hook OK` → `winsock::Hook OK` → `MousePerf` hook) and the real game
window is created (`CreateWindowExA class=[MapleStory2]`). On a machine without a real GPU it then
dies at 3D device creation (WineD3D pixel-format / DXVK device), which is the expected headless wall,
not a WinLicense failure. Real-hardware render validation of the bundled DXVK + MoltenVK path is done
separately via the tester kit.

## License

The build scripts in this repo are provided under the MIT license (see `LICENSE`). The **binaries
they produce** are governed by the licenses of Wine and its dependencies — see
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
