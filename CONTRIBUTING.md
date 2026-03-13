# Contributing to Tempo

Thanks for your interest in contributing! Tempo is a small open source project and every contribution helps.

## Getting Started

1. **Fork** the repository
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tempo-metronome.git
   ```
3. **Create a branch** for your change:
   ```bash
   git checkout -b fix/issue-42-description
   ```
4. **Make your changes**, test them on a real device if possible
5. **Push** and open a **Pull Request**

## Branch Naming

| Type | Example |
|------|---------|
| Bug fix | `fix/issue-12-tap-tempo-crash` |
| New feature | `feat/polyrhythm-support` |
| Documentation | `docs/update-readme` |
| Refactor | `refactor/audio-engine` |

## Code Style

- Follow Swift API Design Guidelines
- Use `@Observable` for state management (Swift 5.9+)
- Keep views small — extract logic into the `Engine/` layer
- No external dependencies — Apple frameworks only

## Commit Messages

Write clear, lowercase commit messages in English:

```
fix: tap tempo calculation off by one beat
feat: add 7/8 time signature
docs: add installation instructions
```

## Pull Requests

- Link the related issue in your PR description: `Fixes #12`
- Keep PRs focused — one issue per PR
- Add a short description of what changed and why
- Test on both iPhone simulator and Apple Watch simulator if relevant

## Reporting Bugs

Open an issue and include:
- iOS / watchOS version
- Device (or simulator)
- Steps to reproduce
- Expected vs actual behavior

## Feature Requests

Open an issue with the `enhancement` label. Before starting to build, comment on the issue so we can discuss and avoid duplicate work.

## Questions

Open a Discussion or comment on any issue — happy to help.
