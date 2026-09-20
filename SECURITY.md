# Security

The extension launches only its bundled native helper, using an argument array without a shell. It does not read the clipboard, capture the screen, access user documents, send network requests, or store data. It requires no additional macOS privacy permissions. Each invocation exits automatically; the command also has a 10-second process timeout.

Do not add credentials or local configuration to this repository. `.gitignore` excludes environment files, common key formats, builds, logs, and local artifacts. This is an accidental-inclusion safeguard, not a secret detector.

Install Gitleaks and enable the tracked hook on every clone:

```sh
brew install gitleaks
git config core.hooksPath .githooks
```

The commit hook scans staged changes, and the push hook scans Git history before uploading. Both require Gitleaks to be installed. CI scans the working tree and complete Git history with the standard Gitleaks rules. Before making the repository public, run both scans again and review the tracked files and commit metadata. Use a GitHub noreply address for commits.

CI has read-only repository permissions, does not retain checkout credentials, and does not need repository secrets. Native helpers are built locally with an ad-hoc signature; no signing identity or provisioning profile is stored here.

If a secret is ever committed, revoke it before rewriting history. Making a repository private again does not retract a disclosed secret.
