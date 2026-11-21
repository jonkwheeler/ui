import { Tree } from "@ui-sdk/octane/tree"
import { createRoot, useEffect, useState } from "octane"
import { treeLinksFixture } from "tests/fixtures/tree.ts"
import { Items } from "../tree/octane-tsrx.tsrx"

// A tree of links, rendered with the tree fixture's classes. The current page follows the address.
function Fixture() @{
  const [current, setCurrent] = useState(location.hash.slice(1) || "usage")
  useEffect(() => {
    const changed = () => setCurrent(location.hash.slice(1))
    window.addEventListener("hashchange", changed)
    return () => window.removeEventListener("hashchange", changed)
  }, [])

  <div class="fixture">
    <button>Before</button>
    <Tree
      className="tree"
      aria-label={treeLinksFixture.label}
      items={treeLinksFixture.items}
      mode="none"
      current={current}
    >
      <Items items={treeLinksFixture.items} checkable={false} />
    </Tree>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {current as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
