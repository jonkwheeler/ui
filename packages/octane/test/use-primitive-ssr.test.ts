import { renderToString } from "octane/server"
import { expect, test } from "vitest"
import { DescribedInput, idNames } from "./described-input"

test("a part's three id props each get their own id in server HTML", () => {
  const { html } = renderToString(DescribedInput)
  const ids = idNames.map(
    (name) => html.match(new RegExp(`${name}="([^"]*)"`))?.[1]
  )
  expect(ids).not.toContain(undefined)
  expect(new Set(ids).size).toBe(3)
})
