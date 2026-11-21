import {
  NumberInput,
  NumberInputIncrement,
  NumberInputControl,
} from "@ui-sdk/octane/number-input"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
  SliderValue,
} from "@ui-sdk/octane/slider"
import { createRoot, useState } from "octane"

// Parts rendered as other elements, and from their state. One fixture covers
// Slider and Number Input.
function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Slider
      defaultValue={40}
      onValueChange={(value) => setAction(`brightness:${value}`)}
    >
      <SliderValue className="slider-value">
        {(state) => `Brightness ${state.text}`}
      </SliderValue>
      <SliderControl className="slider-control">
        <SliderTrack className="slider-track">
          <SliderIndicator
            className={(state) =>
              `slider-indicator ${state.dragging ? "is-dragging" : "is-idle"}`
            }
            style={(state) => ({ opacity: state.dragging ? 0.5 : 1 })}
          />
          <SliderThumb
            className="slider-thumb"
            aria-label="Brightness"
            render={<span />}
          >
            {(state) => (
              <span class="thumb-label">{String(state.thumbValue)}</span>
            )}
          </SliderThumb>
        </SliderTrack>
      </SliderControl>
    </Slider>
    <NumberInput defaultValue={8} max={9} aria-label="Count">
      <NumberInputControl aria-label="Count" />
      <NumberInputIncrement aria-label="Increase count">
        {(state) => (state.disabled ? "At most" : "More")}
      </NumberInputIncrement>
    </NumberInput>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
