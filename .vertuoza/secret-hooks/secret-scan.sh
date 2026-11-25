#!/bin/sh
# Vertuoza secret scan, run before each commit of this repository. It scans only what the
# commit adds, with gitleaks, offline once gitleaks is cached. The repository's .gitleaks.toml and
# .gitleaksignore apply.
#
# It stops a commit for one reason only: a secret found. Anything else (no network for the first
# download, an unsupported system, a failed download, gitleaks crashing) lets the commit through with
# a one-line notice, so it never blocks anyone's work.
#
# Managed from vertuoza/vertuo-qa (tools/secret-hooks/kit): do not edit here, the next update
# replaces this file. Docs: https://github.com/vertuoza/vertuo-qa/tree/main/tools/secret-hooks
# POSIX sh: git and husky run it with sh, on macOS, Linux and Windows (Git Bash).

GITLEAKS_VERSION=8.30.1
LEAKS=42

# Two things start this scan on a commit:
#   - git itself, from the repository's config (hook.vertuoza-secret-scan, set by `prepare`). The
#     config is shared by every worktree of the repository, so a worktree with no install is scanned
#     too. Needs git 2.54 or newer;
#   - husky's .husky/pre-commit, with --from-husky, for older git. When git already runs the scan
#     from its config, this one stops here, so a commit is scanned once.
if [ "${1:-}" = --from-husky ] && [ -n "$(git config --get hook.vertuoza-secret-scan.command 2>/dev/null)" ]; then
  # "git version 2.56.0 (Apple Git-…)" or "git version 2.47.1.windows.1".
  set -- $(git --version | sed -n 's/^git version \([0-9]*\)\.\([0-9]*\).*/\1 \2/p')
  if [ "${1:-0}" -gt 2 ] || { [ "${1:-0}" -eq 2 ] && [ "${2:-0}" -ge 54 ]; }; then
    exit 0
  fi
fi

skip() {
  echo "secret scan skipped: $1. This commit is not checked for secrets." >&2
  exit 0
}

case "$(uname -s)/$(uname -m)" in
  Darwin/arm64) plat=darwin_arm64 sum=b40ab0ae55c505963e365f271a8d3846efbc170aa17f2607f13df610a9aeb6a5 ;;
  Darwin/x86_64) plat=darwin_x64 sum=dfe101a4db2255fc85120ac7f3d25e4342c3c20cf749f2c20a18081af1952709 ;;
  Linux/x86_64) plat=linux_x64 sum=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb ;;
  Linux/aarch64 | Linux/arm64) plat=linux_arm64 sum=e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080 ;;
  *) skip "no gitleaks for $(uname -s) $(uname -m)" ;;
esac

cache=${XDG_CACHE_HOME:-$HOME/.cache}/vertuoza/gitleaks-$GITLEAKS_VERSION
gitleaks=$cache/gitleaks

sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    sha256sum "$1" | cut -d' ' -f1
  fi
}

# Downloaded once per machine, checked against the pinned SHA-256 before anything is extracted.
# SECRET_SCAN_GITLEAKS_TARBALL (tests) gives the archive instead of the release.
fetch_gitleaks() {
  tmp=$(mktemp -d 2>/dev/null) || return 1
  archive=$tmp/gitleaks.tar.gz
  if [ -n "${SECRET_SCAN_GITLEAKS_TARBALL:-}" ]; then
    cp "$SECRET_SCAN_GITLEAKS_TARBALL" "$archive" || { rm -rf "$tmp"; return 1; }
  else
    echo "secret scan: downloading gitleaks $GITLEAKS_VERSION once for this machine…" >&2
    curl -fsSL --max-time 60 -o "$archive" \
      "https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/gitleaks_${GITLEAKS_VERSION}_$plat.tar.gz" ||
      { rm -rf "$tmp"; return 1; }
  fi
  if [ "$(sha256 "$archive")" != "$sum" ]; then
    echo "secret scan: the gitleaks download does not match its pinned checksum, not used." >&2
    rm -rf "$tmp"
    return 1
  fi
  tar -xzf "$archive" -C "$tmp" gitleaks && mkdir -p "$cache" && mv "$tmp/gitleaks" "$gitleaks.$$" &&
    chmod +x "$gitleaks.$$" && mv "$gitleaks.$$" "$gitleaks"
  status=$?
  rm -rf "$tmp" "$gitleaks.$$"
  return $status
}

[ -x "$gitleaks" ] || fetch_gitleaks || skip "gitleaks could not be downloaded"

"$gitleaks" git --pre-commit --staged --redact --no-banner --log-level error \
  --exit-code "$LEAKS" --verbose . 1>&2
status=$?

case $status in
  0) exit 0 ;;
  "$LEAKS")
    cat >&2 <<'EOF'

✋ Secret found in what you are committing: the commit was stopped.

  1. Take the value out of the file. Secrets live in the vault or a .env that is never committed.
  2. Nothing reached git. But if this value was ever pushed, shared or pasted elsewhere,
     ROTATE it (revoke it, issue a new one). Deleting it from the file is not enough.
  3. Not a secret (test data, an example)? Put its Fingerprint line in the repository's
     .gitleaksignore, or mark the line inline as the README says:
     https://github.com/vertuoza/vertuo-qa/tree/main/tools/secret-hooks#handling-a-finding

People only, at your own risk: `git commit --no-verify` skips this check. Agents may not.
EOF
    exit 1
    ;;
  *) skip "gitleaks failed (exit $status)" ;;
esac
