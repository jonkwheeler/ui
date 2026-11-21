import { Checkbox, CheckboxIndicator } from "@ui-sdk/octane/checkbox"
import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import { createRoot, useEffect, useState } from "octane"
import {
  fieldChoiceCardFixture as f,
  fieldChoiceCardOptions,
} from "tests/fixtures/field.ts"

function Card({ card }: { card: (typeof f.cards)[number] }) @{
  <FieldLabel className="choice-card">
    <Field>
      <Checkbox className="checkbox" name={card.name}>
        <CheckboxIndicator className="checkbox-indicator" />
      </Checkbox>
      <span>{card.title as string}</span>
      <FieldDescription>{card.description as string}</FieldDescription>
    </Field>
  </FieldLabel>
}

function LaterCard() @{
  const [ready, setReady] = useState(false)
  useEffect(() => {
    const timer = setTimeout(() => setReady(true), f.later.delay)
    return () => clearTimeout(timer)
  }, [])

  <FieldLabel className="choice-card">
    <Field>
      @if (ready) {
        <Checkbox className="checkbox" name={f.later.name}>
          <CheckboxIndicator className="checkbox-indicator" />
        </Checkbox>
      }
      <span>{f.later.title as string}</span>
      <FieldDescription>{f.later.description as string}</FieldDescription>
    </Field>
  </FieldLabel>
}

function Fixture() @{
  const { alone, later } = fieldChoiceCardOptions()

  <div class="fixture">
    <button>Before</button>
    @for (const card of f.cards; key card.name) {
      <Card card={card} />
    }
    @if (later) {
      <LaterCard />
    }
    @if (alone) {
      <FieldLabel>{f.alone as string}</FieldLabel>
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
