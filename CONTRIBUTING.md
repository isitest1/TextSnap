# Contributing to TextSnap

Thank you for your interest in contributing to TextSnap.

## Ways to Contribute

- **Bug reports** — Open an issue using the bug report template
- **Feature requests** — Open an issue using the feature request template
- **Pull requests** — Fix bugs or implement approved features

## Development Setup

1. Fork the repository and clone your fork
2. Open `TextSnap.xcodeproj` in Xcode 16 or later
3. Select the **TextSnap** scheme
4. Press `⌘R` to build and run

No external dependencies are required. The project uses only Apple system frameworks.

## Code Guidelines

- **Language:** Swift
- **Minimum deployment target:** macOS 14.0
- **Frameworks:** Apple system frameworks only — no external packages
- **Architecture:** Follow the existing file structure and separation of concerns
- **Comments:** English only; add comments only when the intent is non-obvious
- **UI text:** English only
- **Commit messages:** English, imperative mood ("Add feature" not "Added feature")

## Submitting a Pull Request

1. Create a branch from `main`
2. Make your changes
3. Ensure the project builds cleanly: `Product → Build` in Xcode
4. Run the unit test suite: `Product → Test` in Xcode
5. Open a pull request against `main` with a clear description of the change

## Scope

TextSnap is intentionally minimal. Please open an issue before starting work on new features so we can discuss whether they fit the project's goals. See the "Out of scope" section in `CLAUDE.md` for features that are explicitly excluded from the initial release.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
