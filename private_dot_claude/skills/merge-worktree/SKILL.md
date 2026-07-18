---
name: merge-worktree
description: Merge a git worktree's branch back into the main tree/branch. Use when the user wants to land, integrate, or merge worktree work back into main (e.g. "merge this worktree back", "land the worktree into main", "integrate my worktree branch"). ALWAYS updates the worktree from main and resolves divergences FIRST, then merges back, then cleans up.
---

# Merge a worktree back into the main tree

Land the work done in a git worktree onto the main branch, safely. The golden rule
the user cares about: **bring main into the worktree and fix divergences FIRST** — in
the worktree, where the work lives and where you can build/test the merge result —
**then** merge the (now up-to-date) branch back into main as a clean fast-forward.

Never do the naive `git checkout main && git merge <feature>` from a stale branch: a
worktree is often branched from an older commit, so main has moved on. Merging a stale
branch straight back invites conflicts resolved in the wrong place, or silently
reverting newer main-side work.

## When to use

The user asks to merge / land / integrate / "bring back" a worktree's branch into
main. Also use it proactively before proposing to remove a worktree that still holds
unmerged work.

## 0. Orient — never assume paths or branches

Run from the worktree you're merging (or wherever the user pointed you). Establish:

```sh
git worktree list                          # all trees; the FIRST is the primary (main) tree
WT=$(git rev-parse --show-toplevel)        # this worktree
WT_BRANCH=$(git -C "$WT" branch --show-current)
MAIN=$(git worktree list --porcelain | awk '/^worktree /{p=substr($0,10)} /^branch /{b=$2} /branch refs\/heads\/(main|master)$/{print p; exit}')
MAIN_BRANCH=$(git -C "$MAIN" branch --show-current)   # main | master
```

Confirm: `$WT_BRANCH` is NOT the same as `$MAIN_BRANCH` (a worktree on the same branch
as main is a degenerate case — stop and ask). Note whether the repo has a remote
(`git -C "$MAIN" remote`).

## 1. Commit the worktree's work

Merges move *commits*, not working-tree edits. Review and commit first:

```sh
git -C "$WT" status --short
# stage + commit the intended work (see the repo's commit conventions / CLAUDE.md)
git -C "$WT" add -A && git -C "$WT" commit -m "<message>"
```

Do **not** use bare `git stash` / `git stash pop` — in a worktree the stash stack is
shared across all worktrees and other sessions, so you can pop someone else's changes.
If you must set something aside, use a WIP commit or `git stash push -u -m "<unique-tag>"`
and re-apply by SHA.

## 2. Pull main and fix divergences — IN THE WORKTREE (the important step)

First make local main current, then merge it into the worktree branch and resolve any
conflicts here, where you can verify the result.

```sh
# (a) update local main from the remote, if there is one
git -C "$MAIN" fetch --prune
git -C "$MAIN" merge --ff-only origin/$MAIN_BRANCH        # fast-forward main to the remote; if this fails, main has local
                                                          # commits that diverge from origin — surface that to the user

# (b) bring main into the worktree branch
git -C "$WT" merge --ff-only $MAIN_BRANCH 2>/dev/null \
  || git -C "$WT" merge $MAIN_BRANCH                       # ff if the worktree is strictly behind; else a real merge
```

- If `merge --ff-only` succeeded, the worktree had no unique commits and is now equal to
  main — nothing to merge back; tell the user and stop (or they only had uncommitted work).
- If the real merge reports **conflicts**: resolve them in the worktree (`git status`
  shows them), `git add` the resolutions, `git commit`. Resolve toward keeping BOTH
  sides' intent — never blanket-favor one side, and never `--force`/reset.
- **A worktree may be missing shared state** (installed deps, generated clients, DB
  migrations already applied elsewhere). After pulling main in, re-run the repo's
  install/build/migrate steps as needed before trusting the tree.

## 3. Verify the merged worktree

Integrating main can break the branch. Run the repo's checks in the worktree **before**
merging back — lint, build, and the relevant tests/verification (see the project's
CLAUDE.md "before done"). Fix fallout as normal commits on the worktree branch. Do not
proceed to step 4 on a red build.

## 4. Merge the branch into main (now a clean fast-forward)

Because main is an ancestor of the worktree branch (step 2), this fast-forwards — no
merge commit, no surprises. Operate on the main tree with `git -C` (you cannot
`git checkout $MAIN_BRANCH` inside the worktree — main is checked out in the main tree):

```sh
git -C "$MAIN" merge --ff-only $WT_BRANCH \
  || git -C "$MAIN" merge --no-ff $WT_BRANCH -m "Merge $WT_BRANCH"   # fallback if you deliberately want a merge commit
```

If `--ff-only` unexpectedly fails, main moved again after step 2 — go back to step 2
(re-pull into the worktree) rather than forcing anything.

## 5. Push and clean up (only if the user wants)

- **Push** main only when the user asked to (pushing is outward-facing):
  `git -C "$MAIN" push`.
- **Remove the worktree** once its work is landed and you (and the user) are done with it:
  `git worktree remove "$WT"` (add `--force` only if it's clean but git complains about
  submodules/locks). Delete the merged branch if it's no longer needed:
  `git -C "$MAIN" branch -d $WT_BRANCH`.
- If the worktree carried **local-only build scaffolding** (symlinks, copied deps,
  `.env`), those are gitignored and vanish with the worktree — nothing to merge.

## Gotchas (hard-won)

- **Fix divergences in the worktree, not on main.** Resolving there lets you build/test
  the resolution and keeps main a fast-forward target.
- **`git -C <path>`, don't `cd`.** You generally can't (and shouldn't) check out main
  inside a worktree; target each tree explicitly.
- **Commit before you merge** — uncommitted edits don't move.
- **Shared stash stack across worktrees** — avoid bare stash; prefer WIP commits.
- **Never `--force`, reset, or clobber a shared branch.** If something doesn't
  fast-forward when you expected it to, re-sync and re-check — don't override.
- **A "stale worktree" is the norm.** Expect main to be ahead; the pull-first step is
  what turns a messy back-merge into a boring fast-forward.
