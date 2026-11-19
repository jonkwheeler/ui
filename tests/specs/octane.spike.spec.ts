import type { Page } from "@playwright/test"
import { expect, test } from "../fixtures"

// Checks for Octane's memoized production builds: state read through a
// stable handle, and what a component keeps between one open and the next.

const item = (page: Page, tree: string, name: string) =>
  page
    .getByRole("tree", { name: tree })
    .getByRole("treeitem", { name, exact: true })

for (const tree of ["Composed", "Data"]) {
  test(`a ${tree.toLowerCase()} tree shows new children of an expanded item`, async ({
    page,
    open,
  }) => {
    await open("tree-children")
    await item(page, tree, "src").click()
    await expect(item(page, tree, "b.ts")).toBeVisible()
    await page.getByRole("button", { name: "Add file" }).click()
    await expect(item(page, tree, "c.ts")).toHaveAttribute("aria-posinset", "3")
    await expect(item(page, tree, "c.ts")).toHaveAttribute("aria-setsize", "3")
    await item(page, tree, "b.ts").focus()
    await page.keyboard.press("ArrowDown")
    await expect(item(page, tree, "c.ts")).toBeFocused()
  })
}

test("a popover returns focus to its trigger each time it closes", async ({
  page,
  open,
}) => {
  await open("popover")
  const trigger = page.getByRole("button", { name: "Profile" })
  const dialog = page.getByRole("dialog", { name: "Edit profile" })
  for (const close of ["Escape", "Close", "Escape"]) {
    await trigger.click()
    await expect(dialog).toBeVisible()
    if (close === "Escape") {
      await page.keyboard.press("Escape")
    } else {
      await dialog.getByRole("button", { name: close }).click()
    }
    await expect(dialog).toBeHidden()
    await expect(trigger).toBeFocused()
  }
})
