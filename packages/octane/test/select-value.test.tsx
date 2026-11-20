/** @jsxImportSource octane */
import { act, createRoot, hydrateRoot, type Root } from "octane"
import { afterAll, beforeAll, expect, test } from "vitest"
import { createSelectController, type SelectValueState } from "../src/select"
import { ExternalValue } from "./select-value-app"
import { type Server, startServer, startTimeout } from "./server-html"

Element.prototype.getAnimations ??= () => []

let server: Server
let onServer: {
  app: typeof import("./select-value-app")
  select: typeof import("../src/select")
}

beforeAll(async () => {
  server = await startServer()
  onServer = {
    app: await server.load("./select-value-app.tsx"),
    select: await server.load("../src/select.tsx"),
  }
}, startTimeout)

afterAll(() => server.close())

for (const hydrate of [false, true]) {
  for (const callback of ["className", "render"] as const) {
    test(`an external select value connects its ${callback} callback after ${hydrate ? "hydration" : "mount"}`, async () => {
      const controller = createSelectController<string>()
      const states: SelectValueState[] = []
      const count = (state: SelectValueState) => {
        states.push(state)
        return state.labels.length
      }
      const props = { callback, controller, count }
      const container = document.body.appendChild(document.createElement("div"))
      const errors: unknown[] = []
      const options = {
        onUncaughtError: (error: unknown) => errors.push(error),
        onRecoverableError: (error: unknown) => errors.push(error),
      }
      let root: Root | undefined
      try {
        if (hydrate) {
          container.innerHTML = server.html(onServer.app.ExternalValue, {
            ...props,
            controller: onServer.select.createSelectController(),
          })
        }
        await act(async () => {
          root = hydrate
            ? hydrateRoot(container, <ExternalValue {...props} />, options)
            : createRoot(container, options)
          if (!hydrate) {
            root.render(<ExternalValue {...props} />)
          }
        })
        expect(errors).toEqual([])
        expect(states[0]).toEqual({
          value: null,
          label: "",
          labels: [],
          placeholder: true,
        })
        expect(states.at(-1)).toEqual({
          value: "pro",
          label: "Pro",
          labels: ["Pro"],
          placeholder: false,
        })
        const trigger = container.querySelector("button")!
        expect(trigger.textContent).toBe("Pro")
        expect(
          trigger
            .querySelector("span")!
            .getAttribute(callback === "className" ? "class" : "data-count")
        ).toBe(callback === "className" ? "selected-1" : "1")
      } finally {
        await act(async () => root?.unmount())
        container.remove()
      }
    })
  }
}
