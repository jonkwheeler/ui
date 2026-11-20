// Every `if`, `else`, `for`, `while` and `do` body is a block, even a one-line
// one, so adding a second statement never changes what runs. ESLint's `curly`
// rule alone, on every tracked script, Vue and Svelte file; `--fix` adds them.
import { execFileSync, spawnSync } from "node:child_process"
import { readFileSync } from "node:fs"
import path from "node:path"
import { ESLint } from "eslint"
import svelte from "eslint-plugin-svelte"
import vue from "eslint-plugin-vue"
import tseslint from "typescript-eslint"

const root = path.resolve(import.meta.dirname, "..")
const fix = process.argv.includes("--fix")
const rules = { curly: ["error", "all"] }

const files = execFileSync(
  "git",
  [
    "ls-files",
    "-z",
    "*.ts",
    "*.tsx",
    "*.mts",
    "*.js",
    "*.mjs",
    "*.vue",
    "*.svelte",
  ],
  { cwd: root, encoding: "utf8" }
)
  .split("\0")
  .filter(Boolean)

const eslint = new ESLint({
  cwd: root,
  fix,
  overrideConfigFile: true,
  overrideConfig: [
    {
      files: ["**/*.{ts,tsx,mts}"],
      languageOptions: { parser: tseslint.parser },
    },
    ...vue.configs["flat/base"],
    {
      files: ["**/*.vue"],
      languageOptions: { parserOptions: { parser: tseslint.parser } },
    },
    ...svelte.configs["flat/base"],
    {
      files: ["**/*.svelte", "**/*.svelte.{js,ts}"],
      languageOptions: { parserOptions: { parser: tseslint.parser } },
    },
    {
      files: ["**/*"],
      linterOptions: { reportUnusedDisableDirectives: "off" },
      rules,
    },
  ],
})

const results = await eslint.lintFiles(files)
if (fix) {
  await ESLint.outputFixes(results)
}

let failed = false
for (const result of results) {
  for (const message of result.messages) {
    failed = true
    const file = path.relative(root, result.filePath)
    console.log(
      `${file}:${message.line} ${message.ruleId ?? "parse"} ${message.message}`
    )
  }
}
for (const { filename, code, message, labels } of checkTemplates()) {
  failed = true
  const file = path.relative(root, filename)
  const offset = labels?.[0]?.span.offset ?? 0
  const line = readFileSync(filename, "utf8")
    .slice(0, offset)
    .split("\n").length
  console.log(`${file}:${line} ${code} ${message}`)
}
process.exitCode = failed ? 1 : 0

// ESLint can't parse a `.tsrx` template, so Oxlint for TSRX checks those.
function checkTemplates() {
  const templates = execFileSync("git", ["ls-files", "-z", "*.tsrx"], {
    cwd: root,
    encoding: "utf8",
  })
    .split("\0")
    .filter(Boolean)
  if (templates.length === 0) {
    return []
  }
  const lint = spawnSync(
    path.join(root, "node_modules/.bin/oxc-tsrx-lint"),
    ["-A", "all", "-D", "curly", ...(fix ? ["--fix"] : []), ...templates],
    { cwd: root, encoding: "utf8" }
  )
  if (lint.error || !lint.stdout) {
    throw lint.error ?? new Error(lint.stderr)
  }
  return JSON.parse(lint.stdout).diagnostics
}
