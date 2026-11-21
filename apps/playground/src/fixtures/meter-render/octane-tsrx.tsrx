import {
  Meter,
  MeterIndicator,
  MeterTrack,
  MeterValue,
} from "@ui-sdk/octane/meter"
import { createRoot, useState } from "octane"

// Parts rendered as other elements, and with functions of their state.
function Fixture() @{
  const [value, setValue] = useState(40)

  <div class="fixture">
    <button>Before</button>
    <Meter
      value={value}
      aria-label="Memory"
      render={<section />}
      className={(state) =>
        `gauge ${state.percent >= 80 ? "is-high" : "is-ok"}`
      }
    >
      <MeterValue>{(state) => `${state.text} used`}</MeterValue>
      <MeterTrack className="gauge-track">
        <MeterIndicator className="gauge-indicator" />
      </MeterTrack>
    </Meter>
    <button onClick={() => setValue(90)}>Fill</button>
    <button>After</button>
    <output role="status" aria-label="Last action" />
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
