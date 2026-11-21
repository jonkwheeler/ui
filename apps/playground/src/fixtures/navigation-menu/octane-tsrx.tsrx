import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuIndicator,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  NavigationMenuViewport,
} from "@ui-sdk/octane/navigation-menu"
import { createRoot, useState } from "octane"
import {
  navigationMenuAction,
  navigationMenuFixture as fixture,
  navigationMenuLayout,
  navigationMenuOptions,
} from "tests/fixtures/navigation-menu.ts"

type Layout = ReturnType<typeof navigationMenuLayout>

function Links({
  links,
}: {
  links: { href: string; label: string }[]
}) @{
  <ul>
    @for (const link of links; key link.href) {
      <li>
        <NavigationMenuLink href={link.href}>
          {link.label as string}
        </NavigationMenuLink>
      </li>
    }
  </ul>
}

function Nested() @{
  const nested = fixture.nested

  <NavigationMenu orientation="vertical">
    <NavigationMenuList className="nav-list vertical">
      <NavigationMenuItem value={nested.value}>
        <NavigationMenuTrigger className="nav-trigger">
          {nested.trigger as string}
        </NavigationMenuTrigger>
        <NavigationMenuContent className="nav-content narrow">
          <Links links={nested.links} />
        </NavigationMenuContent>
      </NavigationMenuItem>
    </NavigationMenuList>
  </NavigationMenu>
}

function Item({
  item,
  position,
  layout,
}: {
  item: (typeof fixture.items)[number]
  position: number
  layout: Layout
}) @{
  <NavigationMenuItem value={item.value}>
    <NavigationMenuTrigger className="nav-trigger">
      {item.trigger as string}
    </NavigationMenuTrigger>
    <NavigationMenuContent
      className={position === 0 ? "nav-content" : "nav-content narrow"}
      keepMounted={layout.keepMounted}
      hiddenUntilFound={layout.hiddenUntilFound}
      {...layout.placement}
    >
      <Links links={item.links} />
      @if (position === 1 && layout.nested) {
        <Nested />
      }
    </NavigationMenuContent>
  </NavigationMenuItem>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const options = navigationMenuOptions()
  const layout = navigationMenuLayout()

  <div class="fixture">
    <button>Before</button>
    <NavigationMenu
      {...options}
      aria-label={fixture.label}
      className="nav-menu"
      onValueChange={(value, { reason }) =>
        setAction(navigationMenuAction(value, reason))
      }
    >
      <NavigationMenuList
        className={
          options.orientation === "vertical" ? "nav-list vertical" : "nav-list"
        }
      >
        @for (const item of fixture.items; index position; key item.value) {
          <Item item={item} position={position} layout={layout} />
        }
        <NavigationMenuItem>
          <NavigationMenuLink
            className="nav-link"
            href={fixture.link.href}
            current
          >
            {fixture.link.label as string}
          </NavigationMenuLink>
        </NavigationMenuItem>
      </NavigationMenuList>
      <NavigationMenuIndicator className="nav-indicator" />
      @if (layout.viewport) {
        <NavigationMenuViewport
          className="nav-viewport"
          {...layout.placement}
        />
      }
    </NavigationMenu>
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
