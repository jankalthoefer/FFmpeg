# FFmpeg LGPL Compliance Report

## Overview

This document provides a comprehensive analysis of FFmpeg's LGPL compliance status for this repository.

## Executive Summary

**✓ FFmpeg is LGPL v2.1+ compliant by default**

This repository follows the LGPL (GNU Lesser General Public License) version 2.1 or later licensing model when built with default configuration options. The codebase contains some GPL-licensed components, but these are optional and excluded from LGPL builds by default.

## License Structure

FFmpeg uses a dual-licensing approach:

1. **Default License**: LGPL v2.1+ (most permissive, allows linking with proprietary software)
2. **Optional GPL License**: GPL v2+ (when `--enable-gpl` is used during configuration)
3. **Optional Version 3**: LGPL v3+ or GPL v3+ (when `--enable-version3` is used)
4. **Nonfree Components**: Available with `--enable-nonfree` (results in unredistributable binaries)

## LGPL Compliance Verification

### Automated Compliance Checker

A compliance verification script has been added to this repository:

```bash
./check_lgpl_compliance.sh
```

This script performs the following checks:

1. **License Documentation**: Verifies LICENSE.md and COPYING.LGPLv2.1 are present and correct
2. **GPL-Only Files**: Identifies GPL-licensed components (which must not be enabled for LGPL builds)
3. **Build Configuration**: Checks if GPL or nonfree options are enabled
4. **License Headers**: Scans source files for proper license declarations
5. **Configure Script**: Validates the build system correctly defaults to LGPL

### Current Status

✅ **PASSED** - Repository is LGPL v2.1+ compliant

Key findings:
- License documentation is complete and accurate
- No GPL or nonfree options are enabled in default configuration
- Build system correctly defaults to LGPL v2.1+
- All required license files are present

## Components by License

### LGPL Components (Default Build)

The following libraries are LGPL v2.1+ by default:

- **libavcodec**: Audio/video codec library
- **libavformat**: Audio/video container format library
- **libavutil**: Common utility library
- **libavfilter**: Audio/video filtering library (most filters)
- **libavdevice**: Device handling library
- **libswscale**: Image scaling and color conversion library
- **libswresample**: Audio resampling library

### GPL Components (Excluded by Default)

These components require `--enable-gpl` and are NOT included in LGPL builds:

#### Optional x86 Optimizations:
- `libavcodec/x86/flac_dsp_gpl.asm`
- `libavcodec/x86/idct_mmx.c`
- `libavfilter/x86/vf_removegrain.asm`

#### Video Filters (35 filters):
- vf_blackframe, vf_boxblur, vf_colormatrix, vf_cover_rect
- vf_cropdetect, vf_delogo, vf_eq, vf_find_rect
- vf_fspp, vf_histeq, vf_hqdn3d, vf_kerndeint
- vf_mcdeint, vf_mpdecimate, vf_nnedi, vf_owdenoise
- vf_perspective, vf_phase, vf_pp7, vf_pullup
- vf_repeatfields, vf_sab, vf_signature, vf_smartblur
- vf_spp, vf_stereo3d, vf_super2xsai, vf_tinterlace
- vf_uspp, vf_vaguedenoiser, vsrc_mptestsrc
- And others (see LICENSE.md for complete list)

#### Build/Test Tools:
- Tests in `tests/checkasm/*`
- `tests/tiny_ssim.c`
- Documentation tools in `doc/`

### Special Cases

#### IJG JPEG Code
Files `libavcodec/jfdctfst.c`, `libavcodec/jfdctint_template.c`, and `libavcodec/jrevdct.c` are from libjpeg:
- Require IJG credit in documentation for binary-only distributions
- Changes must be documented

#### External Libraries

When linking with external libraries, additional considerations apply:

**GPL-only libraries** (require `--enable-gpl`):
- avisynth, frei0r, libcdio, libdavs2, librubberband
- libvidstab, libx264, libx265, libxavs, libxavs2, libxvid

**LGPL v3 libraries** (require `--enable-version3`):
- gmp, libaribb24, liblensfun

**Apache 2.0 libraries** (incompatible with LGPL v2.1, require `--enable-version3`):
- VMAF, mbedTLS, RK MPI, OpenCORE, VisualOn

**Nonfree libraries** (require `--enable-nonfree`, result in unredistributable binaries):
- Fraunhofer FDK AAC, OpenSSL (when incompatible with GPL)

## Build Configuration for LGPL Compliance

### Compliant Configuration

To ensure LGPL compliance, use default configuration without GPL/nonfree flags:

```bash
./configure
# or with specific options:
./configure --disable-x86asm  # if nasm is not available
```

The build will report:
```
License: LGPL version 2.1 or later
```

### Non-Compliant Configurations

The following configurations are NOT LGPL compliant:

```bash
# GPL configuration
./configure --enable-gpl
# Output: License: GPL version 2 or later

# Nonfree configuration
./configure --enable-nonfree
# Output: License: nonfree and unredistributable

# GPL v3 configuration
./configure --enable-gpl --enable-version3
# Output: License: GPL version 3 or later
```

### LGPL v3 Configuration

To upgrade to LGPL v3 (still LGPL compliant, but with version 3):

```bash
./configure --enable-version3
# Output: License: LGPL version 3 or later
```

This is useful when linking with Apache 2.0 or LGPL v3 libraries.

## Maintaining LGPL Compliance

### For Users

1. **Use default configuration** without `--enable-gpl` or `--enable-nonfree`
2. **Verify license** by checking the configure output: `License: LGPL version 2.1 or later`
3. **Check external libraries** - avoid GPL-only libraries unless you accept GPL terms
4. **Run compliance checker** before releases: `./check_lgpl_compliance.sh`

### For Developers

1. **New code must be LGPL v2.1+** unless explicitly marked and guarded with `CONFIG_GPL`
2. **Mark GPL code** clearly with license headers and configure dependencies
3. **Test both configurations** - LGPL and GPL builds should both work
4. **Document license changes** in LICENSE.md when adding new components

### For Distributors

1. **Source distributions**: Include all license files (COPYING.LGPLv2.1, etc.)
2. **Binary distributions**: 
   - Must not enable `--enable-nonfree` (makes binaries unredistributable)
   - Document which configuration options were used
   - If using GPL libraries, the entire binary becomes GPL
3. **Provide source code** as required by LGPL when distributing binaries
4. **Credit IJG** if including JPEG code and distributing binaries only

## Testing LGPL Compliance

### Manual Testing

1. Clean configuration:
   ```bash
   make distclean
   ./configure
   grep "License:" ffbuild/config.log
   ```

2. Check for GPL/nonfree flags:
   ```bash
   grep -E "CONFIG_GPL|CONFIG_NONFREE" ffbuild/config.mak
   ```

3. Verify output shows LGPL:
   ```
   License: LGPL version 2.1 or later
   ```

### Automated Testing

Run the compliance checker:
```bash
./check_lgpl_compliance.sh
```

Expected output:
```
✓ FFmpeg appears to be LGPL v2.1+ compliant
```

## Frequently Asked Questions

### Q: Can I use FFmpeg in a closed-source commercial application?

**A: Yes**, if you build with LGPL configuration (default) and follow LGPL v2.1 requirements:
- Provide source code for FFmpeg (not your application)
- Allow users to relink with modified FFmpeg libraries
- Include LGPL license text and copyright notices

### Q: What if I need GPL-only features (e.g., x264 encoder)?

**A: Your entire binary becomes GPL**. You must:
- Release your application source code under GPL
- Or separate FFmpeg as a dynamically linked component
- Use `--enable-gpl` during configuration

### Q: Can I distribute binaries without source code?

**A: Yes, but with conditions**:
- Must not use `--enable-nonfree`
- Must provide FFmpeg source code (or offer to provide it)
- Must allow users to relink with modified FFmpeg
- See LGPL v2.1 section 6 for details

### Q: What about software patents?

**A**: LGPL does not grant patent licenses. Codec patents are separate legal issues. Consult a lawyer for your jurisdiction.

### Q: How do I check if a specific feature is GPL-only?

**A**: Check LICENSE.md or use:
```bash
./configure --list-decoders
./configure --list-encoders  
./configure --list-filters
# Then check LICENSE.md for GPL markers
```

## References

- **FFmpeg License**: [LICENSE.md](LICENSE.md)
- **LGPL v2.1 Full Text**: [COPYING.LGPLv2.1](COPYING.LGPLv2.1)
- **GPL v2 Full Text**: [COPYING.GPLv2](COPYING.GPLv2)
- **FFmpeg Official Licensing**: https://ffmpeg.org/legal.html
- **LGPL v2.1 Official**: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html

## Compliance Checklist

Use this checklist when preparing releases:

- [ ] Run `./check_lgpl_compliance.sh` - passes with no errors
- [ ] Configure with default options (no `--enable-gpl` or `--enable-nonfree`)
- [ ] Verify license output: `License: LGPL version 2.1 or later`
- [ ] Include all license files in distribution (COPYING.LGPLv2.1, LICENSE.md, etc.)
- [ ] Document any external libraries used and their licenses
- [ ] Provide source code or offer to provide it (for binary distributions)
- [ ] Include copyright notices and license text in documentation
- [ ] If using JPEG code, credit IJG in binary-only distribution documentation

## Conclusion

This FFmpeg repository is fully LGPL v2.1+ compliant when built with default configuration. The compliance checker script provides ongoing verification, and the documentation clearly identifies which components require GPL licensing.

**Current Status**: ✅ **LGPL v2.1+ COMPLIANT**

---

*Last Updated: 2025-10-22*  
*Compliance Checker Version: 1.0*
