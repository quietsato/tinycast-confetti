const { environment, showHUD } = require("@raycast/api");
const { execFile } = require("child_process");
const path = require("path");

module.exports = async function confetti() {
  try {
    await new Promise((resolve, reject) => {
      execFile(
        path.join(environment.assetsPath, "Confetti.app", "Contents", "MacOS", "confetti"),
        [],
        { timeout: 10000, maxBuffer: 4096 },
        (error) => (error ? reject(error) : resolve()),
      );
    });
  } catch {
    await showHUD("Confetti could not start. Rebuild and reinstall the extension.");
  }
};
