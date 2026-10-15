#!/bin/bash
# Classify every linked worktree of one repo.
# Usage: classify-worktrees.sh <repo-path>
# Output (TSV): status  size_kb  path  branch
#   status: MERGED_PR | MERGED_ANCESTOR | CLOSED_PR | OPEN | PRUNABLE, with +DIRTY
#   when tracked files are modified. Untracked files are NOT considered here;
#   check them before removing (see SKILL.md).
r="$1"
def=$(git -C "$r" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#origin/##'); def=${def:-main}
git -C "$r" fetch -q origin "$def" 2>/dev/null
merged=$(cd "$r" && gh pr list --state merged --limit 1000 --json headRefName -q '.[].headRefName' 2>/dev/null)
closed=$(cd "$r" && gh pr list --state closed --limit 1000 --json headRefName,state -q '.[]|select(.state=="CLOSED")|.headRefName' 2>/dev/null)
main=$(git -C "$r" rev-parse --show-toplevel)
git -C "$r" worktree list --porcelain | awk '/^worktree /{p=substr($0,10)} /^branch /{b=substr($0,19)} /^detached/{b="(detached)"} /^$/{print p"\t"b; b=""}' |
while IFS=$'\t' read -r p b; do
  [ "$p" = "$main" ] && continue
  if [ ! -d "$p" ]; then echo -e "PRUNABLE\t0\t$p\t$b"; continue; fi
  dirty=$(git -C "$p" status --porcelain --untracked-files=no 2>/dev/null | head -1)
  st=OPEN
  if [ "$b" != "(detached)" ] && echo "$merged" | grep -qxF "$b"; then st=MERGED_PR
  elif git -C "$p" merge-base --is-ancestor HEAD "origin/$def" 2>/dev/null; then st=MERGED_ANCESTOR
  elif [ "$b" != "(detached)" ] && echo "$closed" | grep -qxF "$b"; then st=CLOSED_PR
  fi
  [ -n "$dirty" ] && st="$st+DIRTY"
  sz=$(du -sk "$p" 2>/dev/null | cut -f1)
  echo -e "$st\t$sz\t$p\t$b"
done
