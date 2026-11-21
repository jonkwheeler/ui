import {
  Toolbar,
  ToolbarButton,
  ToolbarSeparator,
} from "@ui-sdk/octane/toolbar"
import { createRoot, useState } from "octane"

// How many times each item's content rendered, so specs can check that moving
// focus renders only the items whose tab stop moved.
const renders: Record<string, number> = {}
;(window as unknown as { __renders: typeof renders }).__renders = renders

const count = (name: string) => {
  renders[name] = (renders[name] ?? 0) + 1
  return name
}

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Toolbar className="toolbar" aria-label="Tools">
      <ToolbarButton render={<span />} onClick={() => setAction("span")}>
        {() => count("Span tool")}
      </ToolbarButton>
      <ToolbarButton onClick={() => setAction("cut")}>
        {() => count("Cut")}
      </ToolbarButton>
      <ToolbarButton onClick={() => setAction("copy")}>
        {() => count("Copy")}
      </ToolbarButton>
      <ToolbarSeparator className="rule" render={<hr />} />
      <ToolbarButton
        disabled
        className={(state) => (state.disabled ? "is-disabled" : "is-enabled")}
        render={<a href="#old" />}
      >
        Old docs
      </ToolbarButton>
    </Toolbar>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
