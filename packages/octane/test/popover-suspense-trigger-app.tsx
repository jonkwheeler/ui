/** @jsxImportSource octane */
import * as React from "octane"
import { Popover, PopoverContent, PopoverTrigger } from "../src/popover"

const never = new Promise<never>(() => {})
function Gate({ server }: { server: boolean }) {
  if (server) {
    throw never
  }
  return null
}

const App = ({ server }: { server: boolean }) => (
  <Popover>
    <React.Suspense fallback={null}>
      <PopoverTrigger>Profile</PopoverTrigger>
      <Gate server={server} />
    </React.Suspense>
    <PopoverTrigger>Account</PopoverTrigger>
    <PopoverContent>Edit profile</PopoverContent>
  </Popover>
)

export { App }
