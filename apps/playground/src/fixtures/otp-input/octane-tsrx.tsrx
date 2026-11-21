import {
  createOTPInputController,
  OTPInput,
  OTPInputGroup,
  OTPInputSeparator,
  OTPInputSlot,
} from "@ui-sdk/octane/otp-input"
import { createRoot, useState } from "octane"
import {
  otpInputAction,
  otpInputFixture,
  otpInputOptions,
} from "tests/fixtures/otp-input.ts"

const controller = createOTPInputController()
const { code, recovery, form } = otpInputFixture
const groups = code.groups.map((size, group) => {
  const start = code.groups.slice(0, group).reduce((sum, n) => sum + n, 0)
  return Array.from({ length: size }, (_, n) => start + n)
})
const recoverySlots = Array.from({ length: recovery.length }, (_, n) => n)

function Fixture() @{
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const { cancel, ...options } = otpInputOptions()

  <div class="fixture">
    <button>Before</button>
    <form
      aria-label={form.label}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(String(new FormData(event.currentTarget).get(code.name)))
      }}
    >
      <OTPInput
        className="otp"
        aria-label={code.label}
        name={code.name}
        maxLength={code.length}
        controller={controller}
        {...options}
        onValueChange={(value, details) => {
          if (cancel && value.includes(cancel)) {
            return details.cancel()
          }
          setAction(otpInputAction.change(value, details.reason))
        }}
        onValueCommit={(value) => setAction(otpInputAction.complete(value))}
      >
        @for (const slots of groups; index group; key group) {
          <>
            @if (group > 0) {
              <OTPInputSeparator className="otp-separator">
                -
              </OTPInputSeparator>
            }
            <OTPInputGroup className="otp-group">
              @for (const slot of slots; key slot) {
                <OTPInputSlot index={slot} className="otp-slot" />
              }
            </OTPInputGroup>
          </>
        }
      </OTPInput>
      <button type="submit">{form.submit as string}</button>
      <button type="reset">{form.reset as string}</button>
    </form>
    <OTPInput
      className="otp"
      aria-label={recovery.label}
      maxLength={recovery.length}
      pattern="alphanumeric"
    >
      <OTPInputGroup className="otp-group">
        @for (const slot of recoverySlots; key slot) {
          <OTPInputSlot index={slot} className="otp-slot" />
        }
      </OTPInputGroup>
    </OTPInput>
    <button onClick={() => controller.setValue(otpInputFixture.filled)}>
      Fill code
    </button>
    <button onClick={() => controller.clear()}>Clear code</button>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Submitted">{submitted as string}</output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
