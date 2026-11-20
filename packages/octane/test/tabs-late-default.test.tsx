/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test, vi } from "vitest"
import { Tabs, TabsList, TabsPanel, TabsTab } from "../src/tabs"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

function lateTab(value: string) {
  let loaded = () => {}
  const loading = new Promise<{ default: React.ComponentType }>(
    (resolve) =>
      (loaded = () =>
        resolve({ default: () => <TabsTab value={value}>{value}</TabsTab> }))
  )
  return { Late: React.lazy(() => loading), loaded }
}

async function mount(node: React.ReactElement) {
  const host = document.createElement("div")
  document.body.append(host)
  root = createRoot(host)
  await act(async () => root!.render(node))
  return host
}

const selected = (host: HTMLElement) =>
  [...host.querySelectorAll('[role="tab"][aria-selected="true"]')].map(
    (tab) => tab.textContent
  )

test("the default tab is selected once it binds after the others", async () => {
  const { Late, loaded } = lateTab("billing")
  const onValueChange = vi.fn()
  const host = await mount(
    <Tabs defaultValue="billing" onValueChange={onValueChange}>
      <TabsList aria-label="Settings">
        <TabsTab value="general">general</TabsTab>
        <React.Suspense fallback={null}>
          <Late />
        </React.Suspense>
      </TabsList>
      <TabsPanel value="general">General panel</TabsPanel>
      <TabsPanel value="billing">Billing panel</TabsPanel>
    </Tabs>
  )
  expect(selected(host)).toEqual(["general"])
  await act(async () => loaded())
  expect(selected(host)).toEqual(["billing"])
  expect(
    host.querySelector('[role="tabpanel"]:not([hidden])')?.textContent
  ).toBe("Billing panel")
  expect(onValueChange).not.toHaveBeenCalled()
})

test("a tab picked before the default's tab binds stays selected", async () => {
  const { Late, loaded } = lateTab("billing")
  const host = await mount(
    <Tabs defaultValue="billing">
      <TabsList aria-label="Settings">
        <TabsTab value="general">general</TabsTab>
        <TabsTab value="team">team</TabsTab>
        <React.Suspense fallback={null}>
          <Late />
        </React.Suspense>
      </TabsList>
    </Tabs>
  )
  await act(async () =>
    host.querySelectorAll<HTMLElement>('[role="tab"]')[1]!.click()
  )
  await act(async () => loaded())
  expect(selected(host)).toEqual(["team"])
})

test("a tab picked and left before the default's tab binds keeps the pick", async () => {
  const { Late, loaded } = lateTab("billing")
  const host = await mount(
    <Tabs defaultValue="billing">
      <TabsList aria-label="Settings">
        <TabsTab value="general">general</TabsTab>
        <TabsTab value="team">team</TabsTab>
        <React.Suspense fallback={null}>
          <Late />
        </React.Suspense>
      </TabsList>
    </Tabs>
  )
  const tabs = host.querySelectorAll<HTMLElement>('[role="tab"]')
  await act(async () => tabs[1]!.click())
  await act(async () => tabs[0]!.click())
  await act(async () => loaded())
  expect(selected(host)).toEqual(["general"])
})
