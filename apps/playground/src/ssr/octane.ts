import { renderToString } from "octane/server"

// Renders an Octane fixture for `/__ssr`, from its module's server compile.
// Fixtures read their options from `location`, so the page's URL stands in.
const fixtures = import.meta.glob("../fixtures/*/octane.tsx") as Record<
  string,
  () => Promise<{ Fixture: (props: { data?: boolean }) => unknown }>
>

async function renderFixture(fixture: string, url: string) {
  const load = fixtures[`../fixtures/${fixture}/octane.tsx`]
  if (!load) {
    throw new Error(`No Octane fixture for ${fixture}.`)
  }
  const { Fixture } = await load()
  const location = new URL(url)
  // Requests overlap, and the render below is synchronous, so the stand-in is
  // in place for exactly one render at a time.
  const realm = globalThis as { location?: unknown }
  realm.location = location
  try {
    // ?data renders the same fixture from `items`, as the client does.
    const data = location.searchParams.has("data")
    return renderToString(Fixture, { data }).html
  } finally {
    delete realm.location
  }
}

export { renderFixture }
