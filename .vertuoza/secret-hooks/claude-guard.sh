#!/usr/bin/env bash
# Vertuoza secret guard for Claude Code: a PreToolUse hook on Bash, declared in this repository's
# .claude/settings.json. It never scans by itself: it makes sure an agent's `git commit` goes through
# the repository's pre-commit hook (husky), which runs the secret scan. So it blocks a commit that skips
# the hook: --no-verify, -n, HUSKY=0, hooks switched off with -c core.hooksPath=… or GIT_CONFIG_*, also
# inside `bash -c '…'`, a subshell or a git alias for commit. It blocks nothing else, and if it fails
# for any reason (no jq, an error) the command goes ahead.
# It stops an agent's mistakes and plain workarounds, not a determined one (a script written to a file
# and run is not read): the enforced controls are on GitHub's side.
#
# Managed from vertuoza/vertuo-qa (tools/secret-hooks/kit): do not edit here, the next update
# replaces this file. Exit 2 blocks the call and shows the message to the agent. Bash 3.2 compatible.
set -u

block() {
  printf 'Vertuoza secret guard: %s\n' "$1" >&2
  exit 2
}

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

# The simple commands to read (cut at ;, &&, ||, |, newlines, subshells): those of the command
# without its quoted text, so a commit message that mentions --no-verify skips nothing; then those
# of each quoted text and of the quoted text inside it, so `bash -c '…'` and `sh -c "…"` are read too.
segments=$(printf '%s' "$command" | jq -Rrs --arg q "'" '
  def strip: gsub("\"(\\\\.|[^\"\\\\])*\""; "\"\"") | gsub($q + "[^" + $q + "]*" + $q; $q + $q);
  def inner: [
    (match("\"((\\\\.|[^\"\\\\])*)\""; "g") | .captures[0].string // "" | gsub("\\\\\""; "\"")),
    (match($q + "([^" + $q + "]*)" + $q; "g") | .captures[0].string // "")
  ];
  . as $c
  | ([$c] + ($c | inner) + [$c | inner[] | inner[]])[]
  | strip
  | gsub("[(){}`$]"; " ")
  | splits("&&|\\|\\||[;|\n]")
' 2>/dev/null) || exit 0

# Prints "<global options>|<commit arguments>" when the simple command is a git commit.
git_commit_parts() {
  local seen_git="" skip="" globals="" rest="" sub="" tok
  set -f
  for tok in $1; do
    if [ -n "$sub" ]; then
      rest="$rest $tok"
    elif [ -z "$seen_git" ]; then
      case $tok in git | */git) seen_git=1 ;; esac
    elif [ -n "$skip" ]; then
      globals="$globals $tok"
      skip=""
    else
      case $tok in
        -c | -C | --git-dir | --work-tree | --namespace | --exec-path | --config-env)
          globals="$globals $tok"
          skip=1
          ;;
        -*) globals="$globals $tok" ;;
        *) sub=$tok ;;
      esac
    fi
  done
  set +f
  # A git alias for commit (git ci = commit): its own arguments count too.
  if [ -n "$sub" ] && [ "$sub" != commit ]; then
    local expansion
    expansion=$(git config --get "alias.$sub" 2>/dev/null)
    case $expansion in
      commit | "commit "* | "!git commit"*)
        rest="${expansion#*commit} $rest"
        sub=commit
        ;;
    esac
  fi
  [ "$sub" = commit ] && printf '%s|%s' "$globals" "$rest"
}

# Short options of git commit that take a value: after one of them, the rest of the cluster is the value.
skips_hook() {
  local tok i c
  set -f
  for tok in $1; do
    case $tok in
      # git also takes an unambiguous prefix of it (--no-veri, --no-verif); --no-ver is ambiguous
      # with --no-verbose and git refuses it.
      --no-veri | --no-verif | --no-verify) set +f; return 0 ;;
      --*) ;;
      -*)
        i=1
        while [ "$i" -lt "${#tok}" ]; do
          c=${tok:$i:1}
          case $c in
            n) set +f; return 0 ;;
            m | F | c | C | t | S | u) break ;;
          esac
          i=$((i + 1))
        done
        ;;
    esac
  done
  set +f
  return 1
}

commit_seen=""
while IFS= read -r seg; do
  parts=$(git_commit_parts "$seg") || continue
  commit_seen=1
  globals=${parts%%|*}
  rest=${parts#*|}
  case $globals in
    *hook* | *--config-env*) block "this commit overrides git hook settings, which may switch off the secret hook. Commit without them." ;;
  esac
  skips_hook "$rest" &&
    block "agents may not skip the secret hook (--no-verify / -n). Commit without it; if the hook finds a secret, take it out of the change and tell the person, who decides whether it must be rotated."
done <<<"$segments"

[ -n "$commit_seen" ] || exit 0

# Husky reads HUSKY=0 to switch every hook off; git reads its config from the environment.
case $command in
  *HUSKY=* | *GIT_CONFIG_*)
    block "this command switches off or reconfigures git hooks (HUSKY, GIT_CONFIG_*), which skips the secret scan. Commit without it."
    ;;
esac
exit 0
