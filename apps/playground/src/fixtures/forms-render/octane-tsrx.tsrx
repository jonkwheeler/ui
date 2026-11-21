import { Checkbox, CheckboxIndicator } from "@ui-sdk/octane/checkbox"
import { Field, FieldControl, FieldLabel } from "@ui-sdk/octane/field"
import { Radio, RadioGroup } from "@ui-sdk/octane/radio"
import { Switch, SwitchThumb } from "@ui-sdk/octane/switch"
import { createRoot, useState } from "octane"

function Fixture() @{
  const [action, setAction] = useState("")
  const [nickname, setNickname] = useState("")

  <div class="fixture">
    <button>Before</button>
    <form
      class="form"
      aria-label="Rendering"
      onSubmit={(event) => event.preventDefault()}
    >
      <label>
        <Checkbox
          className="checkbox"
          render={<span />}
          onCheckedChange={(checked) => setAction(`span:${checked}`)}
        >
          <CheckboxIndicator className="checkbox-indicator" />
        </Checkbox>
        Rendered as a span
      </label>
      <Checkbox
        aria-label="Render function"
        render={(props, state) => (
          <button {...props}>{state.checked ? "On" : "Off"}</button>
        )}
      />
      <Checkbox
        aria-label="Class from state"
        className={(state) =>
          `checkbox ${state.checked ? "is-checked" : "is-unchecked"}`
        }
      />
      <label>
        <Switch className="switch" defaultChecked>
          <SwitchThumb
            render={(props, state) => (
              <span {...props}>{state.checked ? "I" : "O"}</span>
            )}
          />
        </Switch>
        Labelled thumb
      </label>
      <RadioGroup
        aria-label="Size"
        defaultValue="small"
        onValueChange={(value) => setAction(`size:${value}`)}
      >
        @for (const value of ["small", "large"]; key value) {
          <label>
            <Radio className="radio" value={value} render={<span />} />
            {value === "small" ? "Small" : "Large"}
          </label>
        }
      </RadioGroup>
      <Field>
        <FieldLabel>Nickname</FieldLabel>
        <FieldControl
          value={nickname}
          onInput={(event) => setNickname(event.currentTarget.value)}
        />
      </Field>
    </form>
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
