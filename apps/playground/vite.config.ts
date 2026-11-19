import { svelte } from "@sveltejs/vite-plugin-svelte"
import react from "@vitejs/plugin-react"
import vue from "@vitejs/plugin-vue"
import solid from "@solidjs/vite-plugin"
import tailwind from "@tailwindcss/vite"
import { octane } from "octane/compiler/vite"
import { defineConfig } from "vite"
import { ssrFixtures } from "./ssr-plugin"
import { solidSsr } from "./solid-ssr.ts"

// Solid, Octane and React all compile .tsx, so each plugin takes its own files.
const solidFiles = [
  "**/packages/solid/**",
  "**/fixtures/*/solid*.tsx",
  "**/examples/*/solid/**",
  "**/examples/components/*/solid/**",
]
// Octane has no include option: with requireDirective it compiles a project
// file only when it opens with the octane jsxImportSource pragma.
const octaneFiles = [
  "**/packages/octane/**",
  "**/fixtures/*/octane*.tsx",
  "**/src/ssr/octane*",
]

export default defineConfig({
  plugins: [
    octane({ requireDirective: true }),
    react({ exclude: [...solidFiles, ...octaneFiles] }),
    vue(),
    svelte(),
    solid({ include: solidFiles, ssr: true }),
    solidSsr(),
    tailwind(),
    ssrFixtures(),
  ],
})
