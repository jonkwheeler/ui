/** @jsxImportSource octane */
import { renderToString } from "octane/server"
import { expect, test } from "vitest"
import { Field, FieldControl, FieldDescription } from "../src/field"

function Descriptions() {
  return (
    <Field>
      <FieldDescription>First</FieldDescription>
      <FieldControl />
      <FieldDescription>Second</FieldDescription>
    </Field>
  )
}

test("on a server, each description gets an id of its own, and the control names the first", () => {
  const { html } = renderToString(Descriptions)
  const descriptions = [
    ...html.matchAll(/<p[^>]*\sid="([^"]+)"[^>]*>([^<]*)<\/p>/g),
  ].map(([, id, text]) => ({ id, text }))
  const described = html.match(/<input[^>]*aria-describedby="([^"]+)"/)![1]
  expect(new Set(descriptions.map(({ id }) => id)).size).toBe(2)
  expect(descriptions.find(({ id }) => id === described)?.text).toBe("First")
})
