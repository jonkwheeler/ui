import { octane } from "octane/compiler/vite"
import { defineConfig } from "vitest/config"

// Two projects: the DOM tests run Octane's client output in jsdom, and the SSR
// tests run its server output in Node, each compiled for that side.
export default defineConfig({
  test: {
    projects: [
      {
        plugins: [octane({ ssr: false })],
        test: {
          name: "dom",
          environment: "jsdom",
          include: ["test/**/*.test.{ts,tsx}"],
          exclude: ["test/**/*-ssr.test.{ts,tsx}"],
        },
      },
      {
        plugins: [octane({ ssr: true })],
        test: {
          name: "ssr",
          environment: "node",
          include: ["test/**/*-ssr.test.{ts,tsx}"],
        },
      },
    ],
  },
})
