import {
  ColorPicker,
  ColorPickerArea,
  ColorPickerAreaCanvas,
  ColorPickerAreaThumb,
  ColorPickerChannelInput,
  ColorPickerEyeDropper,
  ColorPickerInput,
  ColorPickerSlider,
  ColorPickerSliderThumb,
  ColorPickerSwatch,
  ColorPickerSwatches,
  ColorPickerSwatchItem,
  createColorPickerController,
} from "@ui-sdk/octane/color-picker"
import { createRoot, useState } from "octane"
import { colorPickerFixture } from "tests/fixtures/color-picker.ts"
import { colorPickerOptions } from "tests/fixtures/page.ts"

const controller = createColorPickerController()

const entries = (form: HTMLFormElement) =>
  Array.from(new FormData(form), ([key, value]) => `${key}=${value}`).join("&")

function Fixture() @{
  const [action, setAction] = useState("")
  const [committed, setCommitted] = useState("")
  const [submitted, setSubmitted] = useState("")
  const { cancel, ...options } = colorPickerOptions()

  <form
    class="fixture"
    onSubmit={(event) => {
      event.preventDefault()
      setSubmitted(entries(event.currentTarget))
    }}
  >
    <button type="button">Before</button>
    <ColorPicker
      aria-label={colorPickerFixture.label}
      name={colorPickerFixture.name}
      controller={controller}
      {...options}
      onValueChange={(value, details) => {
        if (cancel) {
          return details.cancel()
        }
        setAction(`${value}:${details.reason}`)
      }}
      onValueCommit={(value, details) =>
        setCommitted(`${value}:${details.reason}`)
      }
    >
      <ColorPickerArea>
        @if (options.space === "oklch") {
          <ColorPickerAreaCanvas />
        }
        <ColorPickerAreaThumb />
      </ColorPickerArea>
      <ColorPickerSlider channel="hue">
        <ColorPickerSliderThumb />
      </ColorPickerSlider>
      <ColorPickerSlider channel="alpha">
        <ColorPickerSliderThumb />
      </ColorPickerSlider>
      <ColorPickerInput aria-label={colorPickerFixture.inputLabel} />
      <ColorPickerChannelInput channel="alpha" />
      <ColorPickerSwatch />
      <ColorPickerEyeDropper>Pick from screen</ColorPickerEyeDropper>
      <ColorPickerSwatches aria-label="Presets">
        @for (const swatch of colorPickerFixture.swatches; key swatch) {
          <ColorPickerSwatchItem value={swatch} />
        }
      </ColorPickerSwatches>
    </ColorPicker>
    <button type="button">After</button>
    <button type="submit">Save</button>
    <button type="reset">Reset</button>
    <button type="button" onClick={() => controller.setValue("rebeccapurple")}>
      Use purple
    </button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Committed">{committed as string}</output>
    <output aria-label="Submitted">{submitted as string}</output>
  </form>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
