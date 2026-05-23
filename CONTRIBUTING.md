# Contributing to AroundZ

Welcome, and thank you for your interest in contributing to AroundZ! 

To keep the project stable and ensure a smooth review process, we follow a strictly structured Gitflow model.

## Branching Strategy

Our repository uses two main permanent branches:
1. **`main`**: This branch represents the stable, production-ready state of the app. **Do not submit PRs directly to `main`.** Only the core maintainers merge tested code into `main`.
2. **`development`**: This is our active integration branch for upcoming releases. All new features, bug fixes, and contributions must target this branch.

## How to Contribute

1. **Fork the Repository**: Start by forking the `AroundZ` repository to your own GitHub account.
2. **Clone Locally**: Clone your fork to your local machine.
3. **Checkout Development**: Add the upstream remote and ensure you are basing your work off the latest `development` branch.
   ```bash
   git remote add upstream https://github.com/robindev2026-a11y/AroundZ.git
   git fetch upstream
   git checkout -b feature/your-feature-name upstream/development
   ```
4. **Make Changes**: Write your code, ensuring you follow our architectural patterns (e.g., MVVM, SwiftUI best practices). Check the `docs/` folder for specific guidelines.
5. **Commit**: Write clear, concise commit messages explaining the *why* behind your changes.
6. **Push**: Push your feature branch to your fork.
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Submit a Pull Request**: Open a Pull Request on the main repository. 
   - **Important:** Ensure the "base" branch is set to `development` (not `main`).
   - Fill out the provided Pull Request Template completely.

## Code Review Process
- All PRs require review from a core maintainer before merging.
- You may be asked to make revisions based on feedback.
- Once approved and CI checks pass, a maintainer will squash and merge your PR into the `development` branch.

Happy coding, and thanks for helping build AroundZ!
