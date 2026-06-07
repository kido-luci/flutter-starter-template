# Contributing

Thanks for contributing to **Flutter Starter Template**! This guide covers the
branch, verification, and pull-request workflow. For project setup, see the
[README](README.md#-quick-start).

## Git Workflow & PRs

The `main` branch is protected. Direct pushes to `main` are disabled, and all
changes must be merged via Pull Requests.

### 1. Create a Branch

Branch names should follow conventions:

* `feat/your-feature-name` or `feature/your-feature-name`
* `fix/bug-description`
* `docs/documentation-update`

### 2. Verify Locally

Before pushing your branch, run local checks to ensure the CI will pass:

```bash
fvm dart format .
fvm flutter analyze
fvm flutter test --exclude-tags golden

for package in packages/*; do
  if [ -d "$package/test" ]; then
    (cd "$package" && fvm flutter test --exclude-tags golden)
  fi
done
```

To run the formatting and analyzer gates automatically on every `git push`,
enable the repo's pre-push hook once per clone:

```bash
git config core.hooksPath .githooks
```

The hook (`.githooks/pre-push`) runs the same `dart format` and
`flutter analyze` checks CI enforces, so a formatting slip can't reach CI.
Bypass in an emergency with `git push --no-verify`.

### 3. Open a Pull Request

Push your branch to the remote and create a Pull Request (PR) targeting `main`.

* The **`Analyze & Test`** GitHub Actions workflow will run automatically.
* **CodeRabbit** posts an AI review automatically (see below).
* Once the checks pass, the PR can be merged.

### 4. Cleanup

After merging, delete the remote branch. You can prune your local tracking
branches with:

```bash
git fetch --prune
```

## 🐰 AI Code Review (CodeRabbit)

Every PR targeting `main` is reviewed automatically by
[CodeRabbit](https://coderabbit.ai) — free for this public repo. It posts a
high‑level summary plus inline, line‑by‑line suggestions, and you can chat with
it directly in PR comments.

Behavior is configured in [`.coderabbit.yaml`](.coderabbit.yaml): generated and
vendored files are skipped, and the reviewer is fed this project's
`core` / `shared` / `features` layering rules so feedback respects the
architecture. Reviews use the `chill` profile to avoid style nitpicks already
covered by `dart format` + `very_good_analysis`.

| Comment in a PR        | Action                              |
|------------------------|-------------------------------------|
| `@coderabbitai review` | Re‑run the review                   |
| `@coderabbitai summary`| Regenerate the PR summary           |
| `@coderabbitai pause`  | Pause reviews on the PR             |
| `@coderabbitai resume` | Resume reviews on the PR            |
| `@coderabbitai help`   | List all commands                   |

## 🛡 Security Scanning

GitHub's [**CodeQL**](.github/workflows/codeql.yml) workflow scans the project's
GitHub Actions workflows for insecure patterns — on pushes to `main`, on PRs
that touch `.github/workflows/`, and weekly. (CodeQL has no Dart support, so the
Flutter app code is covered by `flutter analyze` in `ci.yml` instead.) To report
a vulnerability privately, see [`SECURITY.md`](SECURITY.md).
