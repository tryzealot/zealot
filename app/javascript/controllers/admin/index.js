import { zealotNewVersionEventer } from "./new_version"
import { addRestartSericeEventer } from "./restart_service"

$(document).on("turbo:load", () => {
  addRestartSericeEventer()
  zealotNewVersionEventer()
})