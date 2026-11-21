import { Checkbox } from "@ui-sdk/octane/checkbox"
import { Label } from "@ui-sdk/octane/label"
import { NumberInput, NumberInputControl } from "@ui-sdk/octane/number-input"
import { Radio, RadioGroup } from "@ui-sdk/octane/radio"
import {
  Slider,
  SliderControl,
  SliderThumb,
  SliderTrack,
} from "@ui-sdk/octane/slider"
import { createRoot, useState, type ComponentProps } from "octane"
import { labelFixture } from "tests/fixtures/label.ts"

const { email, plan, volume, terms, region, delivery, quantity } = labelFixture

function Group({
  group,
  ...props
}: { group: typeof plan | typeof region } & ComponentProps<
  typeof RadioGroup
>) @{
  <RadioGroup id={group.id} className="radio-group" {...props}>
    @for (const item of group.items; key item.value) {
      <Radio className="radio" value={item.value}>
        {item.label as string}
      </Radio>
    }
  </RadioGroup>
}

function Fixture() @{
  const [shown, setShown] = useState(false)

  <div class="fixture">
    <button>Before</button>
    <Label htmlFor={email.id}>{email.label as string}</Label>
    <input id={email.id} />
    <Label htmlFor={plan.id}>{plan.label as string}</Label>
    <Group group={plan} defaultValue={plan.defaultValue} />
    <Label htmlFor={volume.id}>{volume.label as string}</Label>
    <Slider
      id={volume.id}
      className="slider"
      defaultValue={volume.defaultValue}
    >
      <SliderControl>
        <SliderTrack className="slider-track">
          <SliderThumb className="slider-thumb" />
        </SliderTrack>
      </SliderControl>
    </Slider>
    <Label>
      <Checkbox className="checkbox" />
      {terms.label as string}
    </Label>
    <Label htmlFor={region.id}>{region.label as string}</Label>
    <Group group={region} disabled />
    <Label htmlFor={delivery.id}>{delivery.label as string}</Label>
    <Group group={delivery} aria-label={delivery.name} />
    <Label htmlFor={quantity.id}>{quantity.label as string}</Label>
    @if (shown) {
      <NumberInput id={quantity.id} defaultValue={quantity.defaultValue}>
        <NumberInputControl />
      </NumberInput>
    } @else {
      <button onClick={() => setShown(true)}>
        {quantity.show as string}
      </button>
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
