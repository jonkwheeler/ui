import {
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  writeFileSync,
} from "node:fs"
import path from "node:path"
import { withJsExtension } from "./specifiers.mjs"

// `from "./menu"` and `import("./menu")` in a source file.
const relativeImport =
  /(\bfrom\s*|\bimport\s*\(\s*)(["'])(\.{1,2}(?:\/[^"']*)?)\2/g

/**
 * Copies every module in `src` to `outDir` as written, for a framework that
 * compiles the packages it owns itself, like Octane, whose output differs
 * between the client and the server. Each relative import names the file it
 * resolves to, like `./use-primitive.tsx`, so any bundler finds it.
 */
function copySources({ sourceDir, outDir }) {
  for (const file of listSourceFiles(sourceDir)) {
    const fromDir = path.dirname(path.join(sourceDir, file))
    const source = readFileSync(path.join(sourceDir, file), "utf8")
    const rewritten = source.replace(
      relativeImport,
      (_, keyword, quote, specifier) =>
        `${keyword}${quote}${withSourceExtension(specifier, fromDir)}${quote}`
    )
    const target = path.join(outDir, file)
    mkdirSync(path.dirname(target), { recursive: true })
    writeFileSync(target, rewritten)
  }
}

function listSourceFiles(sourceDir) {
  return readdirSync(sourceDir, { recursive: true }).filter(
    (file) => /\.tsx?$/.test(file) && !file.endsWith(".d.ts")
  )
}

function withSourceExtension(specifier, fromDir) {
  const base = withJsExtension(specifier, fromDir, [".ts", ".tsx"]).replace(
    /\.js$/,
    ""
  )
  return existsSync(path.resolve(fromDir, `${base}.tsx`))
    ? `${base}.tsx`
    : `${base}.ts`
}

export { copySources }
