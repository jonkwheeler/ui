/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { createAgent } from "../src/agent"
import { Field, FieldControl, FieldLabel } from "../src/field"
import {
  type TextEditorAdapter,
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuList,
  TriggerMenuStatus,
  textFieldAdapter,
} from "../src/trigger-menu"

let root: Root | undefined
afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

function Example() {
  const [editor, setEditor] = React.useState<TextEditorAdapter>()
  return (
    <TriggerMenu editor={editor} triggers={[{ char: "@", items: [] }]}>
      <Field>
        <FieldLabel>Notes</FieldLabel>
        <FieldControl
          render={
            <textarea
              ref={(field) => {
                if (field && editor?.element !== field) {
                  setEditor(textFieldAdapter(field))
                }
              }}
            />
          }
        />
      </Field>
      <TriggerMenuStatus />
      <TriggerMenuContent>
        <TriggerMenuList>{() => null}</TriggerMenuList>
      </TriggerMenuContent>
    </TriggerMenu>
  )
}

test("a trigger menu connected through its editor is named by that field", async () => {
  root = createRoot(document.body.appendChild(document.createElement("div")))
  await act(async () => root!.render(<Example />))
  const agent = createAgent()
  expect(agent.snapshot()).toContainEqual(
    expect.objectContaining({ component: "trigger-menu", label: "Notes" })
  )
})
