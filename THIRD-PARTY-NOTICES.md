# Third-party notices

The macOS Wine runtime that the Lith launcher redistributes (in `LithMS/Lith-Artifacts` releases)
bundles the following third-party components. This file is the required attribution + source-offer
record. Full license texts are in [`LICENSES/`](LICENSES/).

## Wine (the core)

- **Component:** Wine, built from CodeWeavers CrossOver sources `26.2.0`.
- **License:** LGPL-2.1-or-later (`LICENSES/LGPL-2.1.txt`).
- **Source:** `https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.2.0.tar.gz`,
  built with the scripts in this repo. A mirror of the exact tarball is kept with each Lith-Artifacts
  release that ships the runtime.
- **Obligation met by:** publishing the complete corresponding source (the CrossOver tarball) + the
  build scripts here; Wine is invoked as a separate process, satisfying the LGPL relink allowance.

## Bundled dylib closure

These macOS libraries are `dlopen`ed by the Wine build at runtime (gnutls for TLS, freetype for
fonts, MoltenVK for the Vulkan→Metal path) and are shipped alongside it, with their transitive
dependencies. Versions are the x86_64 Homebrew bottles used at build time; exact versions are
pinned per release in the shipped `LICENSES/` manifest.

| Library | Purpose | License | Upstream source |
|---|---|---|---|
| libgnutls.30 | TLS (server auth) | LGPL-2.1-or-later | https://gnutls.org/ |
| libnettle.9 / libhogweed.7 | crypto (gnutls dep) | LGPL-3 / GPL-2 dual | https://www.lysator.liu.se/~nisse/nettle/ |
| libgmp.10 | bignum (nettle dep) | LGPL-3-or-later / GPL-2 dual | https://gmplib.org/ |
| libp11-kit.0 | PKCS#11 (gnutls dep) | BSD-3-Clause | https://p11-glue.github.io/p11-glue/ |
| libtasn1.6 | ASN.1 (gnutls dep) | LGPL-2.1-or-later | https://www.gnu.org/software/libtasn1/ |
| libidn2.0 | IDN (gnutls dep) | LGPL-3 / GPL-2 dual | https://www.gnu.org/software/libidn/ |
| libunistring.5 | Unicode (idn2 dep) | LGPL-3-or-later | https://www.gnu.org/software/libunistring/ |
| libintl.8 (gettext) | i18n (dep) | LGPL-2.1-or-later | https://www.gnu.org/software/gettext/ |
| libfreetype.6 | font rendering | FTL or GPL-2 (we elect FTL) | https://freetype.org/ |
| libpng16.16 | PNG (freetype dep) | zlib/libpng | http://www.libpng.org/pub/png/libpng.html |
| libMoltenVK | Vulkan-on-Metal | Apache-2.0 | https://github.com/KhronosGroup/MoltenVK |

## DXVK

- **Component:** `d3d9.dll` (Direct3D 9 → Vulkan).
- **License:** zlib (`LICENSES/zlib.txt`).
- **Source:** https://github.com/doitsujin/dxvk — the shipping build compiles DXVK from the DXVK
  tree included in the CrossOver `26.2.0` source drop (`sources/dxvk`). (The current test bundle
  reuses the compiled `d3d9.dll` from retail CrossOver as a proven-rendering shortcut; that is
  replaced by our own DXVK build before any public release.)

---

**Packaging check (do at release time):** the redistributed runtime must contain only the Wine build
output + the closure above + DXVK. Confirm no other component from the CrossOver source tree leaks
into the shipped bundle, and regenerate the version-pinned `LICENSES/` manifest from the actual
bundled dylibs.
