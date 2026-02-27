#!/usr/bin/env bash
# package-linux.sh — Build .deb, .rpm, and .AppImage from Flutter Linux bundle
#
# Usage:
#   ./scripts/package-linux.sh <arch> <version>
#   arch:    x64 | arm64
#   version: e.g. 1.0.0
#
# Outputs (in dist/):
#   zen-journal_<version>_<deb-arch>.deb
#   zen-journal-<version>-1.<rpm-arch>.rpm
#   zen-journal-<version>-<appimage-arch>.AppImage

set -euo pipefail

ARCH="${1:-x64}"
VERSION="${2:-0.1.0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Derived values ─────────────────────────────────────────────────────────────

case "$ARCH" in
  x64)
    FLUTTER_ARCH="x64"
    DEB_ARCH="amd64"
    RPM_ARCH="x86_64"
    APPIMAGE_ARCH="x86_64"
    ;;
  arm64)
    FLUTTER_ARCH="arm64"
    DEB_ARCH="arm64"
    RPM_ARCH="aarch64"
    APPIMAGE_ARCH="aarch64"
    ;;
  *)
    echo "[failed] Unknown arch: $ARCH (must be x64 or arm64)"
    exit 1
    ;;
esac

BUNDLE_DIR="${REPO_ROOT}/build/linux/${FLUTTER_ARCH}/release/bundle"
DIST_DIR="${REPO_ROOT}/dist"
APP_NAME="zen-journal"
BINARY_NAME="zen_journal"
DISPLAY_NAME="Zen Journal"
DESCRIPTION="A calm, private, open-source journaling app"

mkdir -p "${DIST_DIR}"

echo "[ok] Packaging Zen Journal ${VERSION} for Linux ${ARCH}"

# ── Verify bundle exists ───────────────────────────────────────────────────────

if [[ ! -d "${BUNDLE_DIR}" ]]; then
  echo "[failed] Bundle not found at ${BUNDLE_DIR}"
  echo "         Run: flutter build linux --release first"
  exit 1
fi

# ── .deb ──────────────────────────────────────────────────────────────────────

build_deb() {
  echo "  Building .deb (${DEB_ARCH})..."

  local PKG_DIR="${DIST_DIR}/deb-staging"
  local INSTALL_DIR="${PKG_DIR}/opt/${APP_NAME}"

  rm -rf "${PKG_DIR}"
  mkdir -p "${INSTALL_DIR}"
  mkdir -p "${PKG_DIR}/usr/bin"
  mkdir -p "${PKG_DIR}/usr/share/applications"
  mkdir -p "${PKG_DIR}/DEBIAN"

  # Copy Flutter bundle
  cp -r "${BUNDLE_DIR}/." "${INSTALL_DIR}/"

  # Wrapper script at /usr/bin/zen-journal
  cat > "${PKG_DIR}/usr/bin/${APP_NAME}" << 'EOF'
#!/bin/sh
exec /opt/zen-journal/zen_journal "$@"
EOF
  chmod 755 "${PKG_DIR}/usr/bin/${APP_NAME}"

  # .desktop entry
  cat > "${PKG_DIR}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=${DISPLAY_NAME}
GenericName=Journal
Comment=${DESCRIPTION}
Exec=/usr/bin/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Office;Utility;
Keywords=journal;diary;mindfulness;writing;
StartupWMClass=zen_journal
EOF

  # DEBIAN/control
  cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${DEB_ARCH}
Maintainer: Zen Journal Project <noreply@github.com>
Homepage: https://github.com/typerhack/zen-journal
Description: ${DESCRIPTION}
 Zen Journal is a cross-platform mindfulness journaling app with
 on-device AI, end-to-end encrypted storage, and voice transcription.
EOF

  # DEBIAN/postinst — update icon cache
  cat > "${PKG_DIR}/DEBIAN/postinst" << 'EOF'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
EOF
  chmod 755 "${PKG_DIR}/DEBIAN/postinst"

  local OUT="${DIST_DIR}/${APP_NAME}_${VERSION}_${DEB_ARCH}.deb"
  dpkg-deb --build --root-owner-group "${PKG_DIR}" "${OUT}"
  rm -rf "${PKG_DIR}"
  echo "  [ok] ${OUT}"
}

# ── .rpm ──────────────────────────────────────────────────────────────────────

build_rpm() {
  if ! command -v rpmbuild &>/dev/null; then
    echo "  [warning] rpmbuild not found — skipping .rpm"
    return
  fi

  echo "  Building .rpm (${RPM_ARCH})..."

  local RPM_ROOT="${DIST_DIR}/rpm-staging"
  rm -rf "${RPM_ROOT}"
  mkdir -p "${RPM_ROOT}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
  mkdir -p "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/opt/${APP_NAME}"
  mkdir -p "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/usr/bin"
  mkdir -p "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/usr/share/applications"

  # Copy Flutter bundle
  cp -r "${BUNDLE_DIR}/." \
    "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/opt/${APP_NAME}/"

  # Wrapper script
  cat > "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/usr/bin/${APP_NAME}" << 'EOF'
#!/bin/sh
exec /opt/zen-journal/zen_journal "$@"
EOF
  chmod 755 "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/usr/bin/${APP_NAME}"

  # .desktop entry
  cat > "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=${DISPLAY_NAME}
GenericName=Journal
Comment=${DESCRIPTION}
Exec=/usr/bin/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Office;Utility;
Keywords=journal;diary;mindfulness;writing;
StartupWMClass=zen_journal
EOF

  # Build file list
  local FILES
  FILES=$(find "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}" \
    -type f -o -type l | sed "s|${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}||")

  # RPM spec
  cat > "${RPM_ROOT}/SPECS/${APP_NAME}.spec" << EOF
Name:           ${APP_NAME}
Version:        ${VERSION}
Release:        1
Summary:        ${DESCRIPTION}
License:        MIT
URL:            https://github.com/typerhack/zen-journal
BuildArch:      ${RPM_ARCH}

%description
Zen Journal is a cross-platform mindfulness journaling app with
on-device AI, end-to-end encrypted storage, and voice transcription.

%install
cp -r %{_builddir}/../BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}/. %{buildroot}/

%files
/opt/${APP_NAME}
/usr/bin/${APP_NAME}
/usr/share/applications/${APP_NAME}.desktop

%post
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
EOF

  rpmbuild -bb \
    --define "_topdir ${RPM_ROOT}" \
    --buildroot "${RPM_ROOT}/BUILDROOT/${APP_NAME}-${VERSION}-1.${RPM_ARCH}" \
    "${RPM_ROOT}/SPECS/${APP_NAME}.spec"

  local RPM_FILE
  RPM_FILE=$(find "${RPM_ROOT}/RPMS" -name "*.rpm" | head -1)
  if [[ -n "${RPM_FILE}" ]]; then
    local OUT="${DIST_DIR}/${APP_NAME}-${VERSION}-1.${RPM_ARCH}.rpm"
    cp "${RPM_FILE}" "${OUT}"
    echo "  [ok] ${OUT}"
  fi

  rm -rf "${RPM_ROOT}"
}

# ── .AppImage ─────────────────────────────────────────────────────────────────

build_appimage() {
  echo "  Building .AppImage (${APPIMAGE_ARCH})..."

  local APPDIR="${DIST_DIR}/AppDir"
  rm -rf "${APPDIR}"
  mkdir -p "${APPDIR}/usr/bin"
  mkdir -p "${APPDIR}/usr/share/applications"
  mkdir -p "${APPDIR}/usr/share/icons/hicolor/256x256/apps"

  # Copy Flutter bundle
  cp -r "${BUNDLE_DIR}/." "${APPDIR}/usr/bin/"

  # .desktop entry (must be at root of AppDir too)
  cat > "${APPDIR}/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=${DISPLAY_NAME}
GenericName=Journal
Comment=${DESCRIPTION}
Exec=${BINARY_NAME}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Office;Utility;
Keywords=journal;diary;mindfulness;writing;
StartupWMClass=zen_journal
EOF
  cp "${APPDIR}/${APP_NAME}.desktop" \
     "${APPDIR}/usr/share/applications/${APP_NAME}.desktop"

  # AppRun entrypoint
  cat > "${APPDIR}/AppRun" << 'EOF'
#!/bin/sh
SELF="$(readlink -f "$0")"
HERE="$(dirname "$SELF")"
export LD_LIBRARY_PATH="${HERE}/usr/bin/lib:${LD_LIBRARY_PATH:-}"
exec "${HERE}/usr/bin/zen_journal" "$@"
EOF
  chmod 755 "${APPDIR}/AppRun"

  # Placeholder icon (white square PNG) — replace with real icon in assets/
  local ICON_SRC="${REPO_ROOT}/assets/icons/zen-journal-256.png"
  if [[ -f "${ICON_SRC}" ]]; then
    cp "${ICON_SRC}" "${APPDIR}/${APP_NAME}.png"
    cp "${ICON_SRC}" "${APPDIR}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
  else
    # Create a minimal 1x1 transparent PNG as placeholder
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82' \
      > "${APPDIR}/${APP_NAME}.png"
    cp "${APPDIR}/${APP_NAME}.png" \
       "${APPDIR}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
  fi

  # Download appimagetool for the right arch
  local TOOL_URL
  case "$APPIMAGE_ARCH" in
    x86_64)  TOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" ;;
    aarch64) TOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-aarch64.AppImage" ;;
  esac

  local TOOL="${DIST_DIR}/appimagetool"
  if [[ ! -f "${TOOL}" ]]; then
    echo "  Downloading appimagetool..."
    curl -fsSL -o "${TOOL}" "${TOOL_URL}"
    chmod +x "${TOOL}"
  fi

  local OUT="${DIST_DIR}/${DISPLAY_NAME// /-}-${VERSION}-${APPIMAGE_ARCH}.AppImage"

  # APPIMAGE_EXTRACT_AND_RUN=1 avoids needing FUSE in CI
  APPIMAGE_EXTRACT_AND_RUN=1 "${TOOL}" "${APPDIR}" "${OUT}"

  rm -rf "${APPDIR}"
  echo "  [ok] ${OUT}"
}

# ── Run ───────────────────────────────────────────────────────────────────────

build_deb
build_rpm
build_appimage

echo ""
echo "[ok] All packages built → dist/"
ls -lh "${DIST_DIR}/"*.deb "${DIST_DIR}/"*.rpm "${DIST_DIR}/"*.AppImage 2>/dev/null || true
