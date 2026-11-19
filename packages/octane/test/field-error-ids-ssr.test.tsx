/** @jsxImportSource octane */
import type { ValidityKey } from "@ui-sdk/core/field"
import { renderToString } from "octane/server"
import { expect, test } from "vitest"
import { Field, FieldControl, FieldError, FieldLabel } from "../src/field"

function Errors({
  matches,
}: {
  matches: readonly (boolean | ValidityKey | undefined)[]
}) {
  return (
    <Field name="email" invalid>
      <FieldLabel>Email</FieldLabel>
      <FieldControl type="email" />
      {matches.map((match, index) => (
        <FieldError key={index} match={match}>
          Error {index}
        </FieldError>
      ))}
    </Field>
  )
}

// The ids of the field's errors and of what its control's description names.
const errorIds = (html: string) => ({
  errors: [...html.matchAll(/<[^>]*data-slot="field-error"[^>]*>/g)].map(
    ([tag]) => tag.match(/\sid="([^"]+)"/)![1]
  ),
  described: html.match(/<input[^>]*aria-describedby="([^"]+)"/)![1].split(" "),
})

test.each([
  [[true]],
  [["valueMissing", true]],
  [[true, true]],
  [[undefined, true]],
] as const)(
  "errors shown on a server keep their own ids, and the first is described (%j)",
  (matches) => {
    const { html } = renderToString(Errors, { matches })
    const { errors: ids, described } = errorIds(html)
    expect(new Set(ids).size).toBe(ids.length)
    expect(described).toContain(ids[0])
  }
)
