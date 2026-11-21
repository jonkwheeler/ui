import {
  Checkbox,
  CheckboxGroup,
  CheckboxIndicator,
} from "@ui-sdk/octane/checkbox"
import {
  Field,
  FieldControl,
  FieldDescription,
  FieldError,
  FieldLabel,
} from "@ui-sdk/octane/field"
import { Radio, RadioGroup, RadioIndicator } from "@ui-sdk/octane/radio"
import { Switch, SwitchThumb } from "@ui-sdk/octane/switch"
import { createRoot, useState } from "octane"
import {
  formsFixture as f,
  formsOptions,
  serialize,
} from "tests/fixtures/forms.ts"

type Details = { cancel: () => void; source: string }

function Topping({
  item,
}: {
  item: (typeof f.toppings.items)[number]
}) @{
  <label>
    <Checkbox className="checkbox" value={item.value}>
      <CheckboxIndicator className="checkbox-indicator" />
    </Checkbox>
    {item.label as string}
  </label>
}

function SwitchRow({
  item,
  report,
}: {
  item: (typeof f.switches)[number]
  report: (name: string, value: unknown, details: Details) => void
}) @{
  <label>
    <Switch
      className="switch"
      name={item.name}
      defaultChecked={item.defaultChecked}
      onCheckedChange={(checked, details) =>
        report(item.name, checked, details)
      }
    >
      <SwitchThumb className="switch-thumb" />
    </Switch>
    {item.label as string}
  </label>
}

function Plan({ item }: { item: (typeof f.plan.items)[number] }) @{
  <label>
    <Radio className="radio" value={item.value} disabled={item.disabled}>
      <RadioIndicator className="radio-indicator" />
    </Radio>
    {item.label as string}
  </label>
}

function Fixture() @{
  const options = formsOptions()
  const [action, setAction] = useState("")
  const [source, setSource] = useState("")
  const [submitted, setSubmitted] = useState("")
  const [terms, setTerms] = useState<boolean | "indeterminate">(false)
  const [shipping, setShipping] = useState(false)
  const all = f.toppings.items.map((item) => item.value)
  // Records a change, or cancels it when the URL asks.
  const report = (name: string, value: unknown, details: Details) => {
    if (options.cancel === name) {
      return details.cancel()
    }
    setAction(`${name}:${String(value)}`)
    setSource(details.source)
  }

  <div class="fixture">
    <button>Before</button>
    <form
      class="form"
      id={f.formId}
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serialize(event.currentTarget))
      }}
    >
      <Field>
        <div class="row">
          <Checkbox
            className="checkbox"
            name={f.terms.name}
            value={f.terms.value}
            required
            readOnly={options.readOnly}
            {...(options.controlled && { checked: terms })}
            onCheckedChange={(checked, details) => {
              report(f.terms.name, checked, details)
              if (!details.canceled) {
                setTerms(checked)
              }
            }}
          >
            <CheckboxIndicator className="checkbox-indicator" />
          </Checkbox>
          <FieldLabel>{f.terms.label as string}</FieldLabel>
        </div>
        <FieldDescription>{f.terms.description as string}</FieldDescription>
        <FieldError className="field-error" match="valueMissing">
          {f.terms.error as string}
        </FieldError>
      </Field>

      <fieldset>
        <legend id={f.toppings.legendId}>{f.toppings.legend as string}</legend>
        <CheckboxGroup
          className="form"
          aria-labelledby={f.toppings.legendId}
          name={f.toppings.name}
          defaultValue={f.toppings.defaultValue}
          allValues={all}
          required={options.toppingsRequired}
          onValueChange={(value, details) =>
            report(f.toppings.name, value.join(","), details)
          }
        >
          <label>
            <Checkbox className="checkbox" parent>
              <CheckboxIndicator className="checkbox-indicator" />
            </Checkbox>
            {f.toppings.parent as string}
          </label>
          @for (const item of f.toppings.items; key item.value) {
            <Topping item={item} />
          }
        </CheckboxGroup>
      </fieldset>

      @for (const item of f.switches; key item.name) {
        <SwitchRow item={item} report={report} />
      }

      <Field>
        <FieldLabel>{f.plan.label as string}</FieldLabel>
        <RadioGroup
          className="form"
          name={f.plan.name}
          required
          defaultValue={options.plan}
          readOnly={options.readOnly}
          disabled={options.disabled}
          loop={options.loop}
          onValueChange={(value, details) =>
            report(f.plan.name, value, details)
          }
        >
          @for (const item of f.plan.items; key item.value) {
            <Plan item={item} />
          }
        </RadioGroup>
        <FieldDescription>{f.plan.description as string}</FieldDescription>
        <FieldError className="field-error" />
      </Field>

      <Field invalid={options.invalid}>
        <FieldLabel>{f.email.label as string}</FieldLabel>
        <FieldControl type="email" name={f.email.name} required />
        <FieldDescription>{f.email.description as string}</FieldDescription>
        <FieldError className="field-error" />
      </Field>

      @if (options.nickname) {
        <Field>
          <FieldLabel>{f.nickname.label as string}</FieldLabel>
          <FieldControl name={f.nickname.name} required />
        </Field>
      }

      <fieldset disabled={shipping}>
        <legend>{f.shipping.legend as string}</legend>
        <label>
          <Checkbox className="checkbox" name={f.shipping.name}>
            <CheckboxIndicator className="checkbox-indicator" />
          </Checkbox>
          {f.shipping.label as string}
        </label>
      </fieldset>

      <div class="row">
        <button type="submit">Save</button>
        <button type="reset">Reset</button>
      </div>
    </form>
    <label>
      <Checkbox
        className="checkbox"
        form={f.formId}
        name={f.newsletter.name}
        value={f.newsletter.value}
      >
        <CheckboxIndicator className="checkbox-indicator" />
      </Checkbox>
      {f.newsletter.label as string}
    </label>
    <button type="button" onClick={() => setShipping((value) => !value)}>
      Toggle shipping
    </button>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Last source">{source as string}</output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
