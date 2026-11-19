/** @jsxImportSource octane */
import { renderToString } from "octane/server"
import { expect, test } from "vitest"
import { Combobox, ComboboxInput } from "../src/combobox"
import { Select, SelectTrigger } from "../src/select"

const plans = [
  { value: "basic", label: "Basic" },
  { value: "pro", label: "Pro" },
]

function PlanSelect({ required }: { required?: boolean }) {
  return (
    <Select
      items={plans}
      name="plan"
      defaultValue={required ? undefined : "pro"}
      required={required}
    >
      <SelectTrigger />
    </Select>
  )
}

function PlanCombobox() {
  return (
    <Combobox items={plans} name="plan" defaultValue="pro">
      <ComboboxInput />
    </Combobox>
  )
}

test("a select submits its value through a hidden textarea", () => {
  const { html } = renderToString(PlanSelect, {})
  expect(html).toMatch(/<textarea[^>]*name="plan"[^>]*>pro<\/textarea>/)
})

test("a required select's hidden textarea is required", () => {
  const { html } = renderToString(PlanSelect, { required: true })
  expect(html).toMatch(/<textarea[^>]*required/)
})

test("a combobox submits its value through a hidden textarea", () => {
  const { html } = renderToString(PlanCombobox)
  expect(html).toMatch(/<textarea[^>]*name="plan"[^>]*>pro<\/textarea>/)
})
