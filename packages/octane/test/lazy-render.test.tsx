/** @jsxImportSource octane */
// A `render` element whose component comes from `lazy()`. Octane has no Server
// Components, so its lazy wrapper is an ordinary component, not a placeholder.
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Button } from "../src/button"
import { Field, FieldControl, FieldDescription } from "../src/field"
import { Tabs, TabsList, TabsPanel, TabsTab } from "../src/tabs"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

function lazyOf<P>(
  component: (props: P) => React.ReactNode,
  loading?: Promise<void>
) {
  return React.lazy(async () => {
    await loading
    return { default: component }
  })
}

async function mount(node: React.ReactElement) {
  const host = document.createElement("div")
  document.body.append(host)
  root = createRoot(host)
  await act(async () => root!.render(node))
  return host
}

test("a part renders a lazy render element once it has loaded", async () => {
  let loaded = () => {}
  const loading = new Promise<void>((resolve) => (loaded = resolve))
  const Link = lazyOf(
    (props: React.ComponentProps<"a">) => <a {...props} />,
    loading
  )
  const host = await mount(
    <React.Suspense fallback="Loading">
      <Button render={<Link href="/docs" />}>Docs</Button>
    </React.Suspense>
  )
  expect(host.textContent).toBe("Loading")
  await act(async () => loaded())
  const link = host.querySelector("a")!
  expect(link.getAttribute("href")).toBe("/docs")
  expect(link.getAttribute("data-slot")).toBe("button")
  expect(link.textContent).toBe("Docs")
})

test("an id on a lazy render element is the part's id", async () => {
  const Tab = lazyOf((props: React.ComponentProps<"button">) => (
    <button {...props} />
  ))
  const host = await mount(
    <Tabs defaultValue="account">
      <TabsList aria-label="Settings">
        <TabsTab value="account" render={<Tab id="account-tab" />}>
          Account
        </TabsTab>
      </TabsList>
      <TabsPanel value="account">Account</TabsPanel>
    </Tabs>
  )
  expect(
    host.querySelector('[role="tabpanel"]')!.getAttribute("aria-labelledby")
  ).toBe("account-tab")
})

test("a part that isn't in the page doesn't wait for its lazy render element", async () => {
  const Section = lazyOf(
    (props: React.ComponentProps<"section">) => <section {...props} />,
    new Promise(() => {})
  )
  const host = await mount(
    <React.Suspense fallback="Loading">
      <Tabs defaultValue="account">
        <TabsList aria-label="Settings">
          <TabsTab value="account">Account</TabsTab>
          <TabsTab value="billing">Billing</TabsTab>
        </TabsList>
        <TabsPanel value="account">Account settings</TabsPanel>
        <TabsPanel value="billing" render={<Section />}>
          Billing settings
        </TabsPanel>
      </Tabs>
    </React.Suspense>
  )
  expect(host.querySelector('[role="tabpanel"]')!.textContent).toBe(
    "Account settings"
  )
})

test("a description on a lazy render element stays ahead of the field's", async () => {
  const Input = lazyOf((props: React.ComponentProps<"input">) => (
    <input {...props} />
  ))
  const host = await mount(
    <Field>
      <FieldControl render={<Input aria-describedby="hint" />} />
      <FieldDescription>Shown on your profile.</FieldDescription>
    </Field>
  )
  expect(host.querySelector("input")!.getAttribute("aria-describedby")).toBe(
    `hint ${host.querySelector('[data-slot="field-description"]')!.id}`
  )
})
