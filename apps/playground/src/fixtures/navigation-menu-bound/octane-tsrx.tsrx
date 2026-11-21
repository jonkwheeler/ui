import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  NavigationMenuViewport,
} from "@ui-sdk/octane/navigation-menu"
import { createRoot, useState } from "octane"
import {
  exposeNavigationMenuValue,
  navigationMenuFixture as fixture,
  navigationMenuLayout,
} from "tests/fixtures/navigation-menu.ts"

function Item({ item }: { item: (typeof fixture.items)[number] }) @{
  <NavigationMenuItem value={item.value}>
    <NavigationMenuTrigger className="nav-trigger">
      {item.trigger as string}
    </NavigationMenuTrigger>
    <NavigationMenuContent className="nav-content">
      <ul>
        @for (const link of item.links; key link.href) {
          <li>
            <NavigationMenuLink href={link.href}>
              {link.label as string}
            </NavigationMenuLink>
          </li>
        }
      </ul>
    </NavigationMenuContent>
  </NavigationMenuItem>
}

function Fixture() @{
  const layout = navigationMenuLayout()
  const [value, setValue] = useState<string | null>(null)
  const [completed, setCompleted] = useState<boolean[]>([])
  exposeNavigationMenuValue(setValue)

  <div class="fixture">
    <button>Before</button>
    <NavigationMenu
      aria-label="Main"
      className="nav-menu"
      delay={0}
      closeDelay={0}
      value={value}
      onValueChange={setValue}
      onOpenChangeComplete={(open) => setCompleted((list) => [...list, open])}
    >
      <NavigationMenuList className="nav-list">
        @for (const item of fixture.items; key item.value) {
          <Item item={item} />
        }
      </NavigationMenuList>
      @if (layout.viewport) {
        <NavigationMenuViewport className="nav-viewport" />
      }
    </NavigationMenu>
    <button>After</button>
    <output role="status" aria-label="Completed">
      {completed.join(",") as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
