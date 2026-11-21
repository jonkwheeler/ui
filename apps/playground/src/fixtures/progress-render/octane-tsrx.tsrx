import { Avatar, AvatarFallback } from "@ui-sdk/octane/avatar"
import { OTPInput, OTPInputSlot } from "@ui-sdk/octane/otp-input"
import {
  Progress,
  ProgressIndicator,
  ProgressTrack,
  ProgressValue,
} from "@ui-sdk/octane/progress"
import { createRoot, useState } from "octane"

const slots = [0, 1, 2, 3]

// Parts rendered as other elements, and with functions of their state, for
// Progress, Avatar and OTP Input.
function Fixture() @{
  const [value, setValue] = useState(40)

  <div class="fixture">
    <button>Before</button>
    <Progress
      value={value}
      aria-label="Export"
      render={<section />}
      className={(state) => `gauge is-${state.status}`}
    >
      <ProgressValue>{(state) => `${state.percent}% done`}</ProgressValue>
      <ProgressTrack className="gauge-track">
        <ProgressIndicator className="gauge-indicator" />
      </ProgressTrack>
    </Progress>
    <Avatar className="avatar" render={<div />}>
      <AvatarFallback
        className={(state) => `avatar-fallback is-${state.loadingStatus}`}
      >
        RF
      </AvatarFallback>
    </Avatar>
    <OTPInput
      aria-label="PIN"
      maxLength={4}
      className="otp"
      render={<section />}
    >
      @for (const index of slots; key index) {
        <OTPInputSlot
          index={index}
          className={(state) =>
            `otp-slot${state.active ? " is-active" : ""}`
          }
        >
          {(state) => state.char ?? "·"}
        </OTPInputSlot>
      }
    </OTPInput>
    <button onClick={() => setValue(100)}>Finish</button>
    <button>After</button>
    <output role="status" aria-label="Last action" />
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
