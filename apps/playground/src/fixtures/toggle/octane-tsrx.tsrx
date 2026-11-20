import { Button } from "@ui-sdk/octane/button"
import { Separator } from "@ui-sdk/octane/separator"
import {
  Toggle,
  ToggleGroup,
  createToggleGroupController,
} from "@ui-sdk/octane/toggle"
import { createRoot, useRef, useState } from "octane"
import { changedValue, toggleOptions } from "tests/fixtures/page.ts"
import { toggleAction, toggleFixture } from "tests/fixtures/toggle.ts"

const formatting = createToggleGroupController()

// A Promise and the buttons that settle it.
function useGate() {
  const settle = useRef<{
    resolve: () => void
    reject: (reason: Error) => void
  } | null>(null)
  return {
    wait: () =>
      new Promise<void>(
        (resolve, reject) => (settle.current = { resolve, reject })
      ),
    resolve: () => settle.current?.resolve(),
    reject: () => settle.current?.reject(new Error("Offline")),
  }
}

function Group({
  group,
  values,
  cancel,
  onAction,
  ...props
}: {
  group: typeof toggleFixture.alignment
  values: { current: Record<string, string[]> }
  cancel: string | null
  onAction: (action: string) => void
  orientation?: "horizontal" | "vertical"
  deselectable?: boolean
  loop?: boolean
  multiple?: boolean
  disabled?: boolean
  controller?: typeof formatting
}) @{
  <ToggleGroup
    className="toggle-group"
    aria-label={group.label}
    defaultValue={values.current[group.name]}
    {...props}
    onValueChange={(value, details) => {
      if (
        cancel &&
        changedValue(values.current[group.name], value) === cancel
      ) {
        return details.cancel()
      }
      values.current[group.name] = value
      onAction(toggleAction.group(group.name, value))
    }}
  >
    @for (const item of group.items; key item.value) {
      <Toggle
        className="toggle"
        value={item.value}
        disabled={item.disabled}
      >
        {item.label as string}
      </Toggle>
    }
  </ToggleGroup>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [pressedWith, setPressedWith] = useState("")
  const [submissions, setSubmissions] = useState(0)
  const { cancel, defaultPressed, disabled, alignment, ...groupOptions } =
    toggleOptions()
  const saving = useGate()
  const publishing = useGate()
  // Each group's value, to tell which toggle a change touches.
  const values = useRef<Record<string, string[]>>({
    alignment: alignment ? [alignment] : toggleFixture.alignment.defaultValue,
    formatting: toggleFixture.formatting.defaultValue,
  })

  <div class="fixture">
    <button>Before</button>
    <Toggle
      className="toggle"
      defaultPressed={defaultPressed}
      onPressedChange={(pressed, details) => {
        if (cancel === toggleFixture.toggle.value) {
          return details.cancel()
        }
        setAction(toggleAction.toggle(pressed))
      }}
    >
      {toggleFixture.toggle.label as string}
    </Toggle>
    <Group
      group={toggleFixture.alignment}
      values={values}
      cancel={cancel}
      onAction={setAction}
      {...groupOptions}
    />
    <Separator className="rule" orientation="vertical" />
    <Group
      group={toggleFixture.formatting}
      values={values}
      cancel={cancel}
      onAction={setAction}
      {...groupOptions}
      multiple
      disabled={disabled}
      controller={formatting}
    />
    <form
      aria-label={toggleFixture.form.label}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmissions((count) => count + 1)
      }}
    >
      <label>
        {toggleFixture.form.field as string}{" "}
        <input name="name" defaultValue={toggleFixture.form.defaultName} />
      </label>
      <Button className="button" type="submit" onClick={saving.wait}>
        Submit
      </Button>
      <Button className="button" type="reset">
        Reset
      </Button>
      <Button className="button" disabled onClick={() => setAction("delete")}>
        Delete
      </Button>
      <Button
        className="button"
        type="submit"
        disabled
        focusableWhenDisabled
        onClick={() => setAction("archive")}
      >
        Archive
      </Button>
    </form>
    <Button
      className="button"
      onClick={(_event, { source }) => {
        setAction("save")
        setPressedWith(source)
      }}
    >
      Save
    </Button>
    <Button
      className="button"
      onClick={async () => {
        setAction("publishing")
        await publishing.wait()
        setAction("published")
      }}
    >
      Publish
    </Button>
    <button onClick={() => formatting.setValue([])}>Clear formatting</button>
    <button onClick={saving.resolve}>Finish saving</button>
    <button onClick={publishing.resolve}>Finish publishing</button>
    <button onClick={publishing.reject}>Fail publishing</button>
    <Button className="button" render={<a href={toggleFixture.docs.href} />}>
      {toggleFixture.docs.label as string}
    </Button>
    <Button
      className="button"
      disabled
      render={<a href={toggleFixture.changelog.href} />}
    >
      {toggleFixture.changelog.label as string}
    </Button>
    <Separator className="rule" />
    <Separator className="rule" decorative />
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Submissions">{String(submissions)}</output>
    <output aria-label="Pressed with">{pressedWith as string}</output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
