// What an `octane-ssr` fixture does: fetches its server HTML from `/__ssr`,
// shows it, records what the specs read, then hydrates it. Every mismatch
// Octane reports is recorded.
import { hydrateRoot } from "octane"
import { serializeForm } from "tests/fixtures/select.ts"

async function hydrateFixture(
  root: HTMLElement,
  fixture: string,
  component: (props: { data?: boolean }) => unknown
) {
  const errors: string[] = []
  const page = window as unknown as Record<string, unknown>
  page.__hydrationErrors = errors
  const request = new URLSearchParams({
    fixture,
    framework: "octane",
    url: location.href,
  })
  const response = await fetch(`/__ssr?${request}`)
  root.innerHTML = await response.text()
  if (!response.ok) {
    throw new Error(`Server rendering ${fixture} failed:\n${root.textContent}`)
  }
  // What the page shows before hydration, whether open content shows before
  // any script runs on it, and what the server markup submits.
  page.__serverHtml = root.innerHTML
  page.__visibleBeforeHydration = !!root
    .querySelector<HTMLElement>('[data-slot$="-content"]')
    ?.checkVisibility()
  const form = root.querySelector("form")
  page.__serverForm = form ? serializeForm(form) : ""
  const run = () => {
    const error = console.error
    console.error = (...args: unknown[]) => {
      errors.push(args.map(String).join(" "))
      error(...args)
    }
    // ?data renders the same fixture from `items`, as the server did.
    const data = new URLSearchParams(location.search).has("data")
    hydrateRoot(
      root,
      component,
      { data },
      {
        onRecoverableError: (cause) => errors.push(String(cause)),
      }
    )
  }
  // With ?hydrate=manual, the page stays server markup until window.hydrate() runs.
  if (new URLSearchParams(location.search).get("hydrate") === "manual") {
    page.hydrate = run
  } else {
    run()
  }
}

export { hydrateFixture }
