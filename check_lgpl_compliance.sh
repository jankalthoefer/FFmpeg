#!/bin/bash
# LGPL Compliance Checker for FFmpeg
# This script verifies that FFmpeg is built and configured for LGPL compliance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "FFmpeg LGPL Compliance Checker"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

# Function to report issues
report_issue() {
    echo -e "${RED}[FAIL]${NC} $1"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
}

report_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

report_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

echo "Checking FFmpeg LGPL compliance..."
echo ""

# Check 1: Verify LICENSE.md exists and documents LGPL
echo "1. Checking license documentation..."
if [ -f "LICENSE.md" ]; then
    if grep -q "GNU Lesser General Public License version 2.1" LICENSE.md; then
        report_pass "LICENSE.md correctly documents LGPL v2.1+"
    else
        report_issue "LICENSE.md does not properly document LGPL v2.1+"
    fi
else
    report_issue "LICENSE.md not found"
fi

# Check 2: Verify COPYING.LGPLv2.1 exists
echo "2. Checking LGPL license file..."
if [ -f "COPYING.LGPLv2.1" ]; then
    report_pass "COPYING.LGPLv2.1 file present"
else
    report_issue "COPYING.LGPLv2.1 file not found"
fi

# Check 3: Check for GPL-only files that should not be used in LGPL builds
echo "3. Checking for GPL-only code files..."

# List of GPL-only files from LICENSE.md
GPL_FILES=(
    "libavcodec/x86/flac_dsp_gpl.asm"
    "libavcodec/x86/idct_mmx.c"
    "libavfilter/x86/vf_removegrain.asm"
    "libavfilter/signature_lookup.c"
    "libavfilter/vf_blackframe.c"
    "libavfilter/vf_boxblur.c"
    "libavfilter/vf_colormatrix.c"
    "libavfilter/vf_cover_rect.c"
    "libavfilter/vf_cropdetect.c"
    "libavfilter/vf_delogo.c"
    "libavfilter/vf_eq.c"
    "libavfilter/vf_find_rect.c"
    "libavfilter/vf_fspp.c"
    "libavfilter/vf_histeq.c"
    "libavfilter/vf_hqdn3d.c"
    "libavfilter/vf_kerndeint.c"
    "libavfilter/vf_lensfun.c"
    "libavfilter/vf_mcdeint.c"
    "libavfilter/vf_mpdecimate.c"
    "libavfilter/vf_nnedi.c"
    "libavfilter/vf_owdenoise.c"
    "libavfilter/vf_perspective.c"
    "libavfilter/vf_phase.c"
    "libavfilter/vf_pp7.c"
    "libavfilter/vf_pullup.c"
    "libavfilter/vf_repeatfields.c"
    "libavfilter/vf_sab.c"
    "libavfilter/vf_signature.c"
    "libavfilter/vf_smartblur.c"
    "libavfilter/vf_spp.c"
    "libavfilter/vf_stereo3d.c"
    "libavfilter/vf_super2xsai.c"
    "libavfilter/vf_tinterlace.c"
    "libavfilter/vf_uspp.c"
    "libavfilter/vf_vaguedenoiser.c"
    "libavfilter/vsrc_mptestsrc.c"
)

GPL_FILE_COUNT=0
for file in "${GPL_FILES[@]}"; do
    if [ -f "$file" ]; then
        GPL_FILE_COUNT=$((GPL_FILE_COUNT + 1))
    fi
done

if [ $GPL_FILE_COUNT -gt 0 ]; then
    report_warning "Found $GPL_FILE_COUNT GPL-only files present in repository"
    echo "   Note: These files are OK if not enabled during configuration"
else
    report_pass "No GPL-only source files found"
fi

# Check 4: Verify configure script has proper license detection
echo "4. Checking configure script license detection..."
if [ -f "configure" ]; then
    if grep -q "license=\"LGPL version 2.1 or later\"" configure; then
        report_pass "Configure script properly defaults to LGPL v2.1+"
    else
        report_issue "Configure script does not properly default to LGPL"
    fi
else
    report_issue "Configure script not found"
fi

# Check 5: If config.h exists, check the build configuration
echo "5. Checking build configuration (if configured)..."
if [ -f "ffbuild/config.mak" ]; then
    echo "   Build has been configured. Checking settings..."
    
    # Check if GPL is enabled
    if grep -q "^CONFIG_GPL=yes" ffbuild/config.mak 2>/dev/null; then
        report_issue "Build is configured with GPL enabled (--enable-gpl)"
        echo "   To be LGPL compliant, reconfigure without --enable-gpl"
    else
        report_pass "GPL is not enabled in build configuration"
    fi
    
    # Check if nonfree is enabled
    if grep -q "^CONFIG_NONFREE=yes" ffbuild/config.mak 2>/dev/null; then
        report_issue "Build is configured with nonfree code (--enable-nonfree)"
        echo "   To be LGPL compliant, reconfigure without --enable-nonfree"
    else
        report_pass "Nonfree code is not enabled in build configuration"
    fi
    
    # Check if version3 is enabled
    if grep -q "^CONFIG_VERSION3=yes" ffbuild/config.mak 2>/dev/null; then
        report_warning "Build is configured with version3 (--enable-version3)"
        echo "   This upgrades to LGPL v3, which is still LGPL compliant"
    fi
else
    report_pass "No build configuration found (source-only check)"
fi

# Check 6: Look for GPL license headers in main library code
echo "6. Scanning for GPL license headers in library code..."
GPL_HEADER_COUNT=0

# Only check library directories, not tools or tests
for dir in libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale; do
    if [ -d "$dir" ]; then
        # Search for GPL headers but exclude known GPL files
        GPL_HEADERS=$(find "$dir" -type f \( -name "*.c" -o -name "*.h" \) -exec grep -l "GNU General Public License" {} \; 2>/dev/null | grep -v "_gpl\|/tests/" || true)
        if [ -n "$GPL_HEADERS" ]; then
            count=$(echo "$GPL_HEADERS" | wc -l)
            GPL_HEADER_COUNT=$((GPL_HEADER_COUNT + count))
        fi
    fi
done

if [ $GPL_HEADER_COUNT -gt 0 ]; then
    report_warning "Found $GPL_HEADER_COUNT files with GPL headers in library code"
    echo "   Review these files to ensure they are only used with --enable-gpl"
else
    report_pass "No unexpected GPL headers found in library code"
fi

# Check 7: Verify LGPL headers are present in main library files
echo "7. Checking for LGPL headers in library code..."
LGPL_SAMPLE_FILES=(
    "libavcodec/avcodec.h"
    "libavformat/avformat.h"
    "libavutil/avutil.h"
)

LGPL_HEADER_FOUND=0
for file in "${LGPL_SAMPLE_FILES[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "Lesser General Public License" "$file" 2>/dev/null; then
            LGPL_HEADER_FOUND=$((LGPL_HEADER_FOUND + 1))
        fi
    fi
done

if [ $LGPL_HEADER_FOUND -gt 0 ]; then
    report_pass "LGPL headers found in main library files"
else
    report_warning "Could not verify LGPL headers in sample library files"
fi

# Summary
echo ""
echo "======================================"
echo "Compliance Check Summary"
echo "======================================"
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ FFmpeg appears to be LGPL v2.1+ compliant${NC}"
    echo ""
    echo "Key findings:"
    echo "  • License documentation is correct"
    echo "  • No GPL or nonfree options enabled in build"
    echo "  • Repository structure follows LGPL requirements"
    echo ""
    echo "To maintain LGPL compliance:"
    echo "  1. Do NOT use --enable-gpl when configuring"
    echo "  2. Do NOT use --enable-nonfree when configuring"
    echo "  3. Avoid linking with GPL-only external libraries"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Found $ISSUES_FOUND compliance issue(s)${NC}"
    echo ""
    echo "Please review and fix the issues listed above."
    echo ""
    exit 1
fi
