# License texts

Full texts for the licenses covering the redistributed macOS Wine runtime. See
[`../THIRD-PARTY-NOTICES.md`](../THIRD-PARTY-NOTICES.md) for the component → license mapping.

- `LGPL-2.1.txt` — Wine core, gnutls, libtasn1, gettext/libintl (and the LGPL side of the
  dual-licensed nettle/hogweed, gmp, idn2, unistring).
- `Apache-2.0.txt` — MoltenVK.
- `zlib.txt` — DXVK, libpng.

Still to drop in at first public release (standard upstream texts; add the exact copy shipped by each
bottle so versions match the pinned binaries):

- `LGPL-3.0.txt` and `GPL-2.0.txt` — the primary side of the dual-licensed nettle/hogweed, gmp,
  libidn2, libunistring (each is offered under either GPL or LGPL; we rely on the LGPL grant, but the
  full GPL text is included with the source drop for completeness).
- `FTL.txt` — FreeType License (we elect FTL over freetype's GPL-2 option).
- `BSD-3-Clause.txt` — p11-kit.

At release time, regenerate the pinned component/version list from the actual bundled dylibs (see the
packaging check at the bottom of `THIRD-PARTY-NOTICES.md`) and confirm every license referenced there
has its text present here.
