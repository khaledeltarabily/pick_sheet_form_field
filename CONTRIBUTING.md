# Contributing to pick_sheet_form_field

Thanks for helping improve this package! This guide covers the project rules
and the steps for opening a pull request.

## Before you start

- **Bug fixes and small changes** (typos, docs, small fixes) can go straight
  to a pull request.
- **New features or public API changes:** open an issue first so the design
  can be agreed before you write code. Search the
  [existing issues](https://github.com/khaledeltarabily/pick_sheet_form_field/issues)
  first to avoid duplicates.

## Development setup

Requirements: Flutter `>=3.32.0` and Dart `^3.8.0`.

1. Fork the repository on GitHub and clone your fork:

   ```bash
   git clone git@github.com:<your-username>/pick_sheet_form_field.git
   cd pick_sheet_form_field
   git remote add upstream git@github.com:khaledeltarabily/pick_sheet_form_field.git
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the example app to try your changes:

   ```bash
   cd example
   flutter run
   ```

## Project rules

### Public API

- Only `lib/pick_sheet_form_field.dart` is public API. Everything under
  `lib/src/` is internal and may change at any time.
- Every public class, constructor, method and property needs a `///` doc
  comment.
- Any change to the public API must also update the
  [API reference](README.md#api-reference) in the README.
- Breaking changes must be discussed in an issue first.

### Code style

- Format with `dart format .`. CI fails on unformatted code.
- Fix every warning from `flutter analyze`. The lint rules live in
  [`analysis_options.yaml`](analysis_options.yaml) (single quotes, `const`
  constructors, `final` locals, `super` parameters, and so on).
- Do not add new runtime dependencies without discussing it first. The
  package depends on Flutter only.

### Tests

- Every bug fix comes with a regression test that fails without the fix
  (see `test/features/pick_sheet/presentation/regressions_test.dart`).
- New features come with unit or widget tests. Test files mirror the
  `lib/src/` layout under `test/features/...`.
- All tests must pass: `flutter test`.

### Changelog and versioning

- Add a line describing your change to `CHANGELOG.md` under an
  `## Unreleased` heading at the top (create the heading if it is missing).
- Do not change the version in `pubspec.yaml`. The maintainer bumps it at
  release time, following [Semantic Versioning](https://semver.org).

## Branches

Branch from `main` and name the branch after the type of change:

| Prefix      | Use for                      | Example                         |
| ----------- | ---------------------------- | ------------------------------- |
| `feat/`     | New features                 | `feat/max-selection-hint`       |
| `fix/`      | Bug fixes                    | `fix/reset-and-toolbar-overflow` |
| `docs/`     | Documentation only           | `docs/theming-guide`            |
| `refactor/` | Code changes with no new behaviour | `refactor/list-controller` |
| `test/`     | Tests only                   | `test/search-edge-cases`        |
| `chore/`    | Tooling, CI, dependencies    | `chore/update-lints`            |

Keep one logical change per branch and pull request.

## Commit messages: Conventional Commits

All commits **must** follow
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
<type>(<optional scope>): <description>

<optional body: explain why, not what>

<optional footer(s)>
```

**Types**

| Type       | Meaning                                         | SemVer impact |
| ---------- | ----------------------------------------------- | ------------- |
| `feat`     | A new feature                                   | minor         |
| `fix`      | A bug fix                                       | patch         |
| `docs`     | Documentation only                              | none          |
| `style`    | Formatting, no code change                      | none          |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none  |
| `perf`     | Performance improvement                         | patch         |
| `test`     | Adding or fixing tests                          | none          |
| `build`    | Build system or dependencies                    | none          |
| `ci`       | CI configuration                                | none          |
| `chore`    | Other maintenance                               | none          |
| `revert`   | Reverts a previous commit                       | depends       |

**Rules**

- Description in lowercase, imperative mood ("add", not "added" or
  "adds"), no trailing period.
- Keep the first line at 72 characters or fewer.
- Scope is optional and names the area changed, for example `field`,
  `sheet`, `controller`, `theme`, `strings`, `example`.
- **Breaking changes** add `!` after the type or scope and explain the
  change in a `BREAKING CHANGE:` footer. This means a major version bump.

**Examples**

```text
feat(sheet): add hint text when max selections is reached
fix(field): restore dropped values on form reset
docs: add theming example to README
test(controller): cover select all with disabled items
feat(theme)!: rename chipColor to chipBackgroundColor

BREAKING CHANGE: PickSheetTheme.chipColor is now chipBackgroundColor.
```

## How to open a pull request

1. **Sync with `main`** so your branch is up to date:

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run the same checks as CI** and make sure they all pass:

   ```bash
   flutter pub get
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```

3. **Push your branch** to your fork:

   ```bash
   git push -u origin <your-branch>
   ```

4. **Open the pull request** against `main`, on GitHub or with the
   [GitHub CLI](https://cli.github.com):

   ```bash
   gh pr create --base main --title "fix(field): restore dropped values on form reset"
   ```

   - The **PR title must be a Conventional Commit** message. Pull requests
     are squash-merged, so the title becomes the commit on `main`. A CI
     check rejects titles that do not follow the format.
   - Fill in the pull request template.
   - Link the issue it solves with `Closes #<issue-number>`.
   - For UI changes, add before/after screenshots or a short GIF.
   - Open it as a **draft** if it is not ready for review yet.

5. **Get it reviewed and merged.**
   - All CI checks must be green.
   - Answer review comments and push fixes as new commits. Do not
     force-push after review has started unless you are asked to.
   - The maintainer squash-merges the pull request once it is approved.

## Reporting bugs and requesting features

Open an [issue](https://github.com/khaledeltarabily/pick_sheet_form_field/issues)
and include:

- Package version and the output of `flutter --version`.
- A minimal code sample that reproduces the problem.
- What you expected to happen and what happened instead.
- Screenshots or logs if relevant.

## Code of conduct

Be respectful and constructive. Harassment or personal attacks are not
tolerated.
