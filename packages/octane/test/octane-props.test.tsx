/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Combobox, ComboboxInput } from "../src/combobox"
import { Meter, MeterIndicator, MeterTrack } from "../src/meter"
import { mergeProps } from "../src/primitive"
import { Toggle } from "../src/toggle"

Element.prototype.getAnimations ??= () => []
HTMLElement.prototype.showPopover ??= function () {}
HTMLElement.prototype.hidePopover ??= function () {}

let root: Root | undefined

async function render(element: React.ReactElement) {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(element))
  return container
}

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a part sets each ref in an array, and clears each when it unmounts", async () => {
  const object = { current: null as HTMLButtonElement | null }
  const calls: (HTMLButtonElement | null)[] = []
  await render(
    <Toggle
      ref={[
        object,
        (el: HTMLButtonElement | null) => {
          calls.push(el)
        },
      ]}
    >
      Bold
    </Toggle>
  )
  expect(object.current).toBeInstanceOf(HTMLButtonElement)
  expect(calls).toEqual([object.current])
  await act(async () => root!.unmount())
  root = undefined
  expect(object.current).toBeNull()
  expect(calls.at(-1)).toBeNull()
})

test("a render element's array of refs gets the element", async () => {
  const object = { current: null as HTMLButtonElement | null }
  await render(<Toggle render={<button ref={[object]} />}>Bold</Toggle>)
  expect(object.current).toBeInstanceOf(HTMLButtonElement)
})

test("mergeProps merges a style written as text with an object", () => {
  expect(
    mergeProps(
      { style: { position: "absolute" } },
      { style: "color: red; --size: 2px" }
    ).style
  ).toEqual({ position: "absolute", color: "red", "--size": "2px" })
})

test("a render element's style written as text keeps the part's own styles", async () => {
  const view = await render(
    <Meter value={50} aria-label="Load">
      <MeterTrack>
        <MeterIndicator render={<div style="color: red" />} />
      </MeterTrack>
    </Meter>
  )
  const indicator = view.querySelector<HTMLElement>(
    '[data-slot="meter-indicator"]'
  )!
  expect(indicator.style.color).toBe("red")
  expect(indicator.style.width).toBe("50%")
})

test("a render element's class values compose with the part's className", async () => {
  const view = await render(
    <Toggle
      className="toggle"
      render={<button className={["link", { active: true, muted: false }]} />}
    >
      Bold
    </Toggle>
  )
  expect(view.querySelector("button")!.className).toBe("toggle link active")
})

test("an input takes attributes in the DOM's own spelling over the part's", async () => {
  const view = await render(
    <Combobox items={["Apple"]}>
      <ComboboxInput
        aria-label="Fruit"
        autocomplete="on"
        spellcheck="true"
        autocapitalize="words"
      />
    </Combobox>
  )
  const input = view.querySelector("input")!
  expect(input.getAttribute("autocomplete")).toBe("on")
  expect(input.getAttribute("spellcheck")).toBe("true")
  expect(input.getAttribute("autocapitalize")).toBe("words")
})
