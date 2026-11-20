import { renderToString } from "octane/server"
import { App } from "./app.tsrx"

function render() {
  return renderToString(App).html
}

export { render }
