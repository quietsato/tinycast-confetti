const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

function load(execFile, showHUD = async () => {}) {
  const context = {
    module: { exports: {} },
    require(name) {
      if (name === "@raycast/api") {
        return { environment: { assetsPath: "/tmp/Confetti assets ' $(echo nope)" }, showHUD };
      }
      if (name === "child_process") return { execFile };
      if (name === "path") return path;
      throw new Error(`Unexpected dependency: ${name}`);
    },
  };
  vm.runInNewContext(fs.readFileSync("confetti.js", "utf8"), context);
  return context.module.exports;
}

test("launches the bundled helper without a shell and waits for completion", async () => {
  let complete;
  let finished = false;
  const command = load((file, args, options, callback) => {
    assert.equal(file, "/tmp/Confetti assets ' $(echo nope)/Confetti.app/Contents/MacOS/confetti");
    assert.equal(args.length, 0);
    assert.equal(options.timeout, 10000);
    assert.equal(options.shell, undefined);
    complete = callback;
  });
  const promise = command().then(() => { finished = true; });
  await Promise.resolve();
  assert.equal(finished, false);
  complete(null);
  await promise;
  assert.equal(finished, true);
});

test("reports launch failures without exposing paths or process output", async () => {
  const messages = [];
  await load((file, args, options, callback) => callback(new Error("private process output")),
    async (text) => messages.push(text))();
  assert.deepEqual(messages, ["Confetti could not start. Rebuild and reinstall the extension."]);
});

test("handles a synchronous bridge failure", async () => {
  let shown = false;
  await load(() => { throw new Error("bridge failed"); }, async () => { shown = true; })();
  assert.equal(shown, true);
});

test("manifest points at the shipped command and icon", () => {
  const manifest = JSON.parse(fs.readFileSync("package.json", "utf8"));
  assert.equal(manifest.private, true);
  assert.equal(manifest.commands[0].mode, "no-view");
  assert.ok(fs.existsSync(`${manifest.commands[0].name}.js`));
  assert.ok(fs.existsSync(path.join("assets", manifest.icon)));
});
