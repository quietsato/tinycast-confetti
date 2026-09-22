# TinyCast Confetti 🎉

A TinyCast extension that throws native confetti across your displays. Inspired by the Confetti command in Raycast; independently implemented without Raycast code or assets.

The overlay lets clicks pass through, leaves keyboard focus alone, and exits after 5.5 seconds. With macOS **Reduce motion** enabled, it shows a stationary arrangement with a short fade instead. No network requests, account, telemetry, or third-party runtime dependencies.

## Build and install

Requires macOS, Node.js with npm, Xcode Command Line Tools, and TinyCast with extension support. The build contains both Apple silicon and Intel code.

```sh
npm run build
```

In TinyCast, open **Settings → Extensions**, enable extensions, and choose **Install → Add from folder**. Select `dist/tinycast-confetti`. Search for **Confetti** in the launcher and press Return. A hotkey can be assigned in TinyCast's settings.

The archive `dist/tinycast-confetti.tar.gz` contains the same installable folder. The helper uses an ad-hoc signature and is not notarized. Distribution through downloads may require normal macOS approval. Rebuilding locally avoids a downloaded executable.

Remove it from TinyCast's Extensions settings to uninstall. There is no background service or separate application to remove.

## Development

```sh
npm run build
npm test
```

`confetti.js` is already a CommonJS command, so no JavaScript bundler or package installation is required. `native/` contains the AppKit overlay and particle model. The helper also accepts `--version` and `--reduced-motion` for local checks.

See [SECURITY.md](SECURITY.md) for security details.

## Compatibility

Uses TinyCast's documented [built extension layout](https://tinycast.dev/docs/extensions/installing/) and `child_process.execFile` bridge. It does not modify TinyCast or require Raycast to be installed.

Verified with TinyCast 0.9.8 on macOS 27 (Apple silicon): folder installation, launcher search, command execution, visible animation, and automatic process exit. The Intel slice is built and checked in CI but has not been run on Intel hardware. Particle tests cover the stationary reduced-motion layout.

## License

MIT. Not affiliated with TinyCast or Raycast.
