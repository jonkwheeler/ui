import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
  SliderValue,
} from "@ui-sdk/octane/slider"
import { createRoot, useState } from "octane"
import {
  serialize,
  sliderFixture as f,
  sliderOptions,
} from "tests/fixtures/slider.ts"

function Fixture() @{
  const options = sliderOptions()
  const [action, setAction] = useState("")
  const [commits, setCommits] = useState<string[]>([])
  const [submitted, setSubmitted] = useState("")
  const [volume, setVolume] = useState(options.volume)
  // Records a change, or cancels it when the URL asks.
  const report = (
    name: string,
    value: number | number[],
    details: { cancel: () => void }
  ) => {
    if (options.cancel === name) {
      return details.cancel()
    }
    setAction(`${name}:${String(value)}`)
  }
  const commit = (name: string) => (value: number | number[]) =>
    setCommits((list) => [...list, `${name}:${String(value)}`])
  const shared = {
    orientation: options.orientation,
    disabled: options.disabled,
    largeStep: options.largeStep,
    locale: options.locale,
  }

  <div class="fixture">
    <button>Before</button>
    <form
      class="form"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serialize(event.currentTarget))
      }}
    >
      <Field>
        <FieldLabel>{f.volume.label as string}</FieldLabel>
        <Slider
          {...shared}
          name={f.volume.name}
          format={options.volumeFormat}
          {...(options.controlled
            ? { value: volume }
            : { defaultValue: options.volume })}
          onValueChange={(value, details) => {
            report(f.volume.name, value, details)
            if (!details.canceled) {
              setVolume(value)
            }
          }}
          onValueCommit={commit(f.volume.name)}
        >
          <SliderValue className="slider-value" />
          <SliderControl className="slider-control">
            <SliderTrack className="slider-track">
              <SliderIndicator className="slider-indicator" />
              <SliderThumb className="slider-thumb" />
            </SliderTrack>
          </SliderControl>
        </Slider>
        <FieldDescription>{f.volume.description as string}</FieldDescription>
      </Field>

      <Field>
        <FieldLabel>{f.price.label as string}</FieldLabel>
        <Slider
          {...shared}
          name={f.price.name}
          defaultValue={options.price}
          minStepsBetweenThumbs={options.minSteps}
          format={options.format}
          onValueChange={(value, details) =>
            report(f.price.name, value, details)
          }
          onValueCommit={commit(f.price.name)}
        >
          <SliderValue className="slider-value" />
          <SliderControl className="slider-control">
            <SliderTrack className="slider-track">
              <SliderIndicator className="slider-indicator" />
              @for (const label of f.price.thumbs; index position; key label) {
                <SliderThumb
                  index={position}
                  className="slider-thumb"
                  aria-label={label}
                />
              }
            </SliderTrack>
          </SliderControl>
        </Slider>
      </Field>

      <div class="row">
        <button type="submit">Save</button>
        <button type="reset">Reset</button>
      </div>
    </form>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Committed">
      {commits.join(" ") as string}
    </output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
