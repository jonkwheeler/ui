import { hydrateRoot } from "octane"
import { App } from "./app.tsrx"

hydrateRoot(document.getElementById("app") as HTMLElement, App)
