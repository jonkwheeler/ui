import { Avatar, AvatarFallback, AvatarImage } from "@ui-sdk/octane/avatar"
import { createRoot, useState, type ComponentProps } from "octane"
import {
  avatarAction,
  avatarFixture,
  type AvatarFixtureItem,
} from "tests/fixtures/avatar.ts"

function Item({
  item,
  ...props
}: { item: AvatarFixtureItem } & Partial<
  ComponentProps<typeof Avatar>
>) @{
  <Avatar className="avatar" {...props}>
    @if (item.src !== undefined) {
      <AvatarImage
        className="avatar-image"
        src={item.src}
        alt={item.name}
        referrerPolicy={item.referrerPolicy}
        crossOrigin={item.crossOrigin}
      />
    }
    <AvatarFallback className="avatar-fallback" delay={item.delay}>
      {item.initials as string}
    </AvatarFallback>
  </Avatar>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [src, setSrc] = useState<string | undefined>(avatarFixture.items[0].src)
  const [mounts, setMounts] = useState(0)
  const [first, ...rest] = avatarFixture.items

  <div class="fixture">
    <button>Before</button>
    <Item
      key={mounts}
      item={{ ...first, src }}
      onLoadingStatusChange={(status, details) =>
        setAction(avatarAction(status, details.reason))
      }
    />
    @for (const item of rest; key item.name) {
      <Item item={item} />
    }
    <button onClick={() => setSrc(avatarFixture.nextSrc)}>Change image</button>
    <button onClick={() => setSrc(undefined)}>Remove image</button>
    <button onClick={() => setMounts((count) => count + 1)}>Remount</button>
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
