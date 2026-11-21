import {
  Pagination,
  PaginationItem,
  PaginationLink,
  PaginationList,
  PaginationNext,
  PaginationPrevious,
  type PaginationRangeItem,
} from "@ui-sdk/octane/pagination"
import { createRoot, useState, type ComponentProps } from "octane"

// A client-side router's link: it navigates without a page load, unless a
// handler before it prevented that.
function RouterLink({ onClick, ...props }: ComponentProps<"a">) @{
  <a
    {...props}
    onClick={(event) => {
      onClick?.(event)
      if (event.defaultPrevented) {
        return
      }
      event.preventDefault()
      history.pushState(null, "", props.href)
    }}
  />
}

function PageNumber({
  page,
  current,
}: {
  page: number
  current: boolean
}) @{
  <>
    {String(page)}
    @if (current) {
      <span aria-hidden="true">•</span>
    }
  </>
}

function Pages({ items }: { items: PaginationRangeItem[] }) @{
  <>
    <PaginationItem>
      <PaginationPrevious render={<RouterLink />} className="pagination-step">
        Previous
      </PaginationPrevious>
    </PaginationItem>
    @for (const item of items; key item) {
      <PaginationItem>
        <PaginationLink
          page={item as number}
          render={<RouterLink />}
          className={(state) =>
            `pagination-link ${state.current ? "is-active" : "is-inactive"}`
          }
        >
          {(state) => (
            <PageNumber page={state.page} current={state.current} />
          )}
        </PaginationLink>
      </PaginationItem>
    }
    <PaginationItem>
      <PaginationNext
        render={(props, state) => (
          <RouterLink {...props} data-target={state.page} />
        )}
        className="pagination-step"
      >
        Next
      </PaginationNext>
    </PaginationItem>
  </>
}

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Pagination
      aria-label="Results pages"
      pageCount={5}
      getHref={(page) => `#results-${page}`}
      onPageChange={(page, details) => {
        if (page === 4) {
          return details.cancel()
        }
        setAction(`page: ${page}`)
      }}
    >
      <PaginationList className="pagination-list">
        {({ items }) => <Pages items={items} />}
      </PaginationList>
    </Pagination>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
