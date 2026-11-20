/** @jsxImportSource octane */
import {
  createColorScheme,
  createLocalStorage,
  createPreference,
} from "@ui-sdk/core"
import { Preferences, usePreference } from "../src/preferences"

const tones = ["default", "light", "medium", "dark"] as const

function setup(
  onValueChange?: (value: string, details: { cancel: () => void }) => void
) {
  const colorScheme = createColorScheme({
    storage: createLocalStorage("color-scheme"),
    global: true,
    onValueChange,
  })
  const skinTone = createPreference({
    values: tones,
    defaultValue: "default",
    attribute: "data-skin-tone",
    storage: createLocalStorage("skin-tone"),
    onValueChange,
  })
  const preferences = [colorScheme, skinTone]
  function Label() {
    return <p>{`Tone: ${usePreference(skinTone).value}`}</p>
  }
  function App() {
    return (
      <Preferences preferences={preferences}>
        <Label />
      </Preferences>
    )
  }
  function Bare() {
    return <Preferences preferences={preferences} />
  }
  return { colorScheme, skinTone, App, Bare }
}

export { setup }
