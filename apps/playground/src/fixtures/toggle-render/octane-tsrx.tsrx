import { Button } from "@ui-sdk/octane/button"
import { Separator } from "@ui-sdk/octane/separator"
import { Toggle, ToggleGroup } from "@ui-sdk/octane/toggle"
import { createRoot, useState } from "octane"

function Star({ pressed }: { pressed: boolean }) @{
  <>
    <span aria-hidden="true">{(pressed ? "★" : "☆") as string}</span>
    {" Star"}
  </>
}

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Button
      className="button"
      render={<span />}
      onClick={() => setAction("span")}
    >
      Span button
    </Button>
    <Button className="button" disabled render={<a href="#old" />}>
      Old docs
    </Button>
    <Toggle
      className={(state) =>
        `toggle ${state.pressed ? "is-pressed" : "is-unpressed"}`
      }
      onPressedChange={(pressed) => setAction(pressed ? "star" : "unstar")}
    >
      {(state) => <Star pressed={state.pressed} />}
    </Toggle>
    <ToggleGroup
      className="toggle-group"
      aria-label="View"
      defaultValue={["grid"]}
      onValueChange={(value) => setAction(value.join(", "))}
    >
      <Toggle className="toggle" value="grid" render={<span />}>
        Grid
      </Toggle>
      <Toggle className="toggle" value="list" render={<span />}>
        List
      </Toggle>
    </ToggleGroup>
    <Separator className="rule" render={<hr />} />
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
