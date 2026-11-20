import { defineConfig } from "@playwright/test"
import { countGates, kitchenSinks, specsThatSkip } from "./fixture-files"
import base from "./playwright.config"

// Fork-only. Upstream runs its portal project on React alone, and Octane's
// popups portal through Octane's own `createPortal`. The list is `portalSpecs`
// from playwright.config.ts, copied because that file doesn't export it.
const portalSpecs = [
  "alignment",
  "autocomplete",
  "combobox",
  "command",
  "date-picker",
  "dialog",
  "drawer",
  "hover-card",
  "list",
  "menu",
  "menubar",
  "navigation-menu",
  "popover",
  "popup",
  "presentation",
  "select",
  "toast",
  "token-input",
  "tooltip",
  "trigger-menu",
].map((component) => `**/${component}.*spec.ts`)

export default defineConfig<{
  playground: boolean
  framework: string
  fixtureOptions: Record<string, string>
}>(base, {
  projects: [
    {
      name: "octane-portal",
      use: {
        browserName: "chromium",
        framework: "octane",
        fixtureOptions: { container: "portal-root" },
      },
      testMatch: portalSpecs,
      testIgnore: [kitchenSinks, countGates, ...specsThatSkip("octane")],
    },
  ],
})
