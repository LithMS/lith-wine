# lith-wine

Build recipe + LGPL source-availability record for the **macOS Wine runtime the Lith launcher
bundles** (so users don't need CrossOver). This is the "corresponding source" offer for the Wine
binaries redistributed in `LithMS/Lith-Artifacts`. Full context, build steps, and the component
license list are in `README.md` and `THIRD-PARTY-NOTICES.md` — read those before changing anything.

## What this repo is (and isn't)

- **Is:** the build scripts (`scripts/`), the license texts (`LICENSES/`), and the notices that make
  our redistribution of Wine LGPL-compliant.
- **Isn't:** the launcher. The launcher invokes Wine as a subprocess and is a separate, private repo
  (`Lith-Launcher`). Nothing here obligates opening the launcher.

## Key facts (don't lose these)

- CrossOver-lineage Wine is what clears the client's **WinLicense/Themida** anti-tamper. Vanilla /
  Gcenx wine-staging fails it. There is no prebuilt CX-lineage Wine left to download, so we build
  from CodeWeavers' LGPL sources (`crossover-sources-<ver>.tar.gz`).
- **Build target is x86_64** (Rosetta on Apple Silicon). The client is x64 and Agarcium's MinHook is
  x86/x64-only — never build ARM64.
- The build `dlopen`s **MoltenVK** (Vulkan→Metal), **freetype** (fonts), **gnutls** (TLS) by soname
  at runtime, so they don't show in `otool -L` but MUST be bundled with their transitive deps.
  `scripts/mkbundle.sh` gathers that closure and fixes the soname symlinks (`cp -L` stores libs under
  their realpath name, e.g. `libnettle.9.0.dylib`, while consumers reference `libnettle.9.dylib`).
- Current source version built and proven: **`26.2.0`** (matches the retail CrossOver 26.2 that was
  WinLicense-proven on the test VM).
- The runtime is bundled by the launcher at `{userData}/wine/` (B3, in `Lith-Launcher`), resolving
  before the user's CrossOver — mirroring the Linux umu/GE-Proton shape.

## Conventions

- Shell scripts are LF-only (`.gitattributes` enforces `*.sh text eol=lf`); they run on macOS
  `bash` **3.2** — no associative arrays / no `declare -A`.
- The `scripts/*` are kept close to verbatim as the *record of what was actually built*. If you
  change build flags, note why in the script header and re-run the acceptance test (`scripts/accept.sh`).

## Cross-Repo Work

Part of the Lith multi-repo workspace. When a task spans repos, read `AGENTS.local.md` (gitignored)
for this machine's sibling checkout paths; the workspace root it names has the full system map in its
`AGENTS.md`. Related repos: `Lith-Launcher` (consumes this runtime, B3 integration), the master port
doc `macos-linux-port.md`, and the B1 write-up `prompts/macos-bundleable-wine-b1.md` at the workspace
root. If `AGENTS.local.md` is missing, ask the user for the paths rather than guessing, and offer to
create it.
