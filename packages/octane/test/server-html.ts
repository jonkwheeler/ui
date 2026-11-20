import { octane } from "octane/compiler/vite"
import { createServer } from "vite"

// Octane renders on the server only from modules compiled for it, so a DOM
// test loads its fixtures through Vite's server loader for the server's HTML.
async function startServer() {
  const vite = await createServer({
    root: import.meta.dirname,
    configFile: false,
    logLevel: "silent",
    appType: "custom",
    server: { middlewareMode: true, hmr: false, ws: false },
    plugins: [octane({ ssr: true })],
  })
  const { renderToString } = await vite.ssrLoadModule("octane/server")
  return {
    load: <Module = Record<string, any>>(id: string) =>
      vite.ssrLoadModule(id) as Promise<Module>,
    html: (component: unknown, props?: object) =>
      renderToString(component, props).html as string,
    close: () => vite.close(),
  }
}

type Server = Awaited<ReturnType<typeof startServer>>

// Compiling a fixture's module graph for the server takes a while on a busy machine.
const startTimeout = 120_000

export { type Server, startServer, startTimeout }
