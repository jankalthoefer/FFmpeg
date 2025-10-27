# LGPL Compliance Quick Reference

## TL;DR - Is FFmpeg LGPL Compliant?

**YES** ✅ - FFmpeg is LGPL v2.1+ compliant by default.

## Quick Check

```bash
# Run the automated compliance checker
./check_lgpl_compliance.sh
```

## Configuration Quick Reference

| Configuration | License | Redistributable | Commercial Use |
|--------------|---------|-----------------|----------------|
| `./configure` (default) | LGPL v2.1+ | ✅ Yes | ✅ Yes |
| `./configure --enable-gpl` | GPL v2+ | ✅ Yes* | ⚠️ Must open source |
| `./configure --enable-nonfree` | Nonfree | ❌ No | ❌ No |
| `./configure --enable-version3` | LGPL v3+ | ✅ Yes | ✅ Yes |
| `./configure --enable-gpl --enable-version3` | GPL v3+ | ✅ Yes* | ⚠️ Must open source |

\* GPL allows redistribution but requires releasing your source code under GPL

## Common Scenarios

### Scenario 1: Commercial Closed-Source Application
**Configuration**: Default (LGPL)
```bash
./configure
make
```
**Requirements**:
- ✅ Can keep your application closed-source
- ✅ Must provide FFmpeg source code to users
- ✅ Must allow users to relink with modified FFmpeg
- ✅ Must include license notices

### Scenario 2: Open Source Project (GPL)
**Configuration**: With GPL features
```bash
./configure --enable-gpl
make
```
**Requirements**:
- ⚠️ Your entire application must be GPL
- ✅ Can use additional features (x264, GPL filters, etc.)
- ✅ Must release your source code under GPL

### Scenario 3: Need x264 Encoder
**Problem**: x264 is GPL-only
**Solution Option A**: Use with GPL
```bash
./configure --enable-gpl --enable-libx264
```
**Requirements**: Your app becomes GPL

**Solution Option B**: Use LGPL alternative
```bash
./configure --enable-libx265  # Check if HEVC is suitable
# or use built-in LGPL codecs
```

### Scenario 4: Web Service / SaaS
**Configuration**: Default (LGPL)
```bash
./configure
make
```
**Requirements**:
- ✅ No need to release your server-side code (LGPL allows this)
- ✅ Must provide FFmpeg source to anyone you distribute binaries to
- ✅ If you don't distribute binaries, compliance is simpler

## What You MUST Do (LGPL)

1. **Include license files** in your distribution
   - COPYING.LGPLv2.1
   - LICENSE.md
   - Copyright notices

2. **Provide source code** for FFmpeg
   - Include source with binary distribution, OR
   - Offer source code in writing for 3 years, OR
   - Point to where you obtained the source

3. **Allow relinking** (for dynamically linked libraries)
   - Provide object files or source for your application's linking parts, OR
   - Use dynamic linking (preferred approach)

4. **Document modifications**
   - If you modified FFmpeg, document the changes
   - Maintain copyright notices

## What You CAN Do (LGPL)

✅ Use in closed-source commercial applications  
✅ Link with proprietary code  
✅ Charge for your software  
✅ Keep your application source private  
✅ Distribute binaries without application source  
✅ Use for SaaS / web services  

## What You CANNOT Do

❌ Remove copyright notices  
❌ Remove license terms  
❌ Use `--enable-nonfree` and redistribute  
❌ Claim you wrote FFmpeg  
❌ Prevent users from replacing FFmpeg libraries  

## Red Flags - Not LGPL Compliant

⚠️ Configure shows: `License: GPL version 2 or later`  
⚠️ Configure shows: `License: nonfree and unredistributable`  
⚠️ Using `--enable-gpl` flag  
⚠️ Using `--enable-nonfree` flag  
⚠️ Statically linking without providing object files  

## How to Verify Compliance

### Before Building
```bash
# Check the configure command output
./configure | grep "License:"
# Should show: License: LGPL version 2.1 or later
```

### After Building
```bash
# Run the compliance checker
./check_lgpl_compliance.sh

# Check the configuration
grep "CONFIG_GPL\|CONFIG_NONFREE" ffbuild/config.mak
# Should return nothing (empty) for LGPL builds
```

### Before Distributing
```bash
# Checklist:
# [ ] Ran ./check_lgpl_compliance.sh successfully
# [ ] Include COPYING.LGPLv2.1 with binaries
# [ ] Include LICENSE.md with binaries
# [ ] Provide FFmpeg source code or offer
# [ ] Document any modifications made
# [ ] Test that users can relink (for static linking)
```

## External Libraries Impact

| Library | License | Requires Flag | Impact |
|---------|---------|---------------|---------|
| libx264 | GPL | `--enable-gpl` | Makes binary GPL |
| libx265 | GPL | `--enable-gpl` | Makes binary GPL |
| libmp3lame | LGPL | none | LGPL compatible |
| libvpx | BSD | none | LGPL compatible |
| libopus | BSD | none | LGPL compatible |
| fdk-aac | Incompatible | `--enable-nonfree` | Unredistributable |
| OpenSSL (old) | Incompatible | `--enable-nonfree` | Unredistributable |

## Common Questions

**Q: Do I need to provide my application source code?**  
A: No, only FFmpeg source code (if you distribute FFmpeg binaries).

**Q: Can I sell software that uses FFmpeg?**  
A: Yes, LGPL allows commercial use.

**Q: What if I modify FFmpeg?**  
A: You must provide the modified FFmpeg source to your users.

**Q: Can I use static linking?**  
A: Yes, but you must provide object files to allow relinking, or use dynamic linking (easier).

**Q: Does LGPL mean free of charge?**  
A: No, "free" means freedom, not price. You can charge for your software.

## Get Help

- **Automated Check**: `./check_lgpl_compliance.sh`
- **Detailed Report**: See [LGPL_COMPLIANCE.md](LGPL_COMPLIANCE.md)
- **FFmpeg Legal**: https://ffmpeg.org/legal.html
- **LGPL FAQ**: https://www.gnu.org/licenses/gpl-faq.html

## Summary

✅ **FFmpeg is LGPL v2.1+ compliant by default**  
✅ **Safe for commercial closed-source use**  
✅ **Just follow standard LGPL requirements**  
⚠️ **Don't use `--enable-gpl` or `--enable-nonfree` if you want LGPL**  

---

*For comprehensive details, see [LGPL_COMPLIANCE.md](LGPL_COMPLIANCE.md)*
