// Builds this folder's .tsrx app against the packed @ui-sdk/octane and renders
// it in Node. A .tsrx template passes children as render bodies, so a part reads
// them only when it's marked `descriptorChildren`: the roots and item texts.
import { execFileSync } from "node:child_process"
import {
  cpSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import { octane } from "octane/compiler/vite"
import { build } from "vite"

const root = path.resolve(import.meta.dirname, "../../..")
const packages = ["core", "octane"]

const unbuilt = packages.filter(
  (name) => !existsSync(path.join(root, "packages", name, "dist"))
)
if (unbuilt.length) {
  console.error(
    `No dist in ${unbuilt.map((name) => `packages/${name}`).join(", ")}. Run \`pnpm --filter @ui-sdk/core --filter @ui-sdk/octane build\`.`
  )
  process.exit(1)
}

const app = mkdtempSync(path.join(tmpdir(), "octane-tsrx-"))
let failures = []
try {
  for (const file of ["app.tsrx", "client.ts", "server.ts", "index.html"]) {
    cpSync(path.join(import.meta.dirname, file), path.join(app, file))
  }
  writeFileSync(
    path.join(app, "package.json"),
    JSON.stringify({ name: "octane-tsrx-consumer", type: "module" })
  )
  const octaneLink = path.join(app, "node_modules/octane")
  mkdirSync(path.dirname(octaneLink), { recursive: true })
  symlinkSync(path.join(root, "node_modules/octane"), octaneLink, "dir")
  for (const name of packages) {
    install(name)
  }

  const config = {
    root: app,
    configFile: false,
    logLevel: "warn",
    plugins: [octane()],
  }
  await build({ ...config, build: { outDir: "dist/client" } })
  await build({
    ...config,
    build: { ssr: "server.ts", outDir: "dist/server" },
  })
  const { render } = await import(
    pathToFileURL(path.join(app, "dist/server/server.js")).href
  )
  failures = check(render())
} finally {
  rmSync(app, { recursive: true, force: true })
}

if (failures.length) {
  console.error(
    [
      ...failures,
      "A .tsrx template passes its children as compiled render bodies, so a root reads its items' labels, and an item text part its text, only when wrapped in `descriptorChildren`.",
    ].join("\n")
  )
  process.exit(1)
}
console.log(
  "The .tsrx app's server markup shows the selected labels and each item's text, and its client build succeeds."
)

// Packs a package as it's published and unpacks it into the app's node_modules.
function install(name) {
  const packageDir = path.join(root, "packages", name)
  const output = execFileSync(
    "pnpm",
    ["pack", "--pack-destination", path.join(app, "tarballs")],
    { cwd: packageDir, encoding: "utf8" }
  )
  const { name: packageName } = JSON.parse(
    readFileSync(path.join(packageDir, "package.json"), "utf8")
  )
  const target = path.join(app, "node_modules", packageName)
  mkdirSync(target, { recursive: true })
  execFileSync("tar", [
    "-xzf",
    output.trim().split("\n").at(-1),
    "-C",
    target,
    "--strip-components=1",
  ])
}

function check(html) {
  const comboboxInput = html.match(/<input[^>]*role="combobox"[^>]*>/)?.[0]
  const shown = [
    {
      part: "select's value",
      text: html.match(/data-slot="select-value"[^>]*>([^<]*)</)?.[1],
      label: "Pro plan",
    },
    {
      part: "combobox's input",
      text: comboboxInput?.match(/\svalue="([^"]*)"/)?.[1],
      label: "France",
    },
  ]
  const itemTexts = {
    select: ["Basic plan", "Pro plan"],
    combobox: ["Germany", "France"],
    command: ["Copy text", "Paste text"],
    autocomplete: ["Apple", "Banana"],
  }
  const texts = Object.entries(itemTexts).flatMap(([name, labels]) => {
    const found = [
      ...html.matchAll(
        new RegExp(`data-slot="${name}-item-text"[^>]*>([^<]*)<`, "g")
      ),
    ].map((match) => match[1])
    return labels
      .filter((label) => !found.includes(label))
      .map(
        (label) =>
          `The ${name}'s item text in a component of the app's own shows ${JSON.stringify(found)} on the server, without "${label}".`
      )
  })
  return [
    ...shown
      .filter(({ text, label }) => text !== label)
      .map(
        ({ part, text, label }) =>
          `The ${part} shows ${JSON.stringify(text)} on the server, not the selected item's label "${label}".`
      ),
    ...texts,
  ]
}
